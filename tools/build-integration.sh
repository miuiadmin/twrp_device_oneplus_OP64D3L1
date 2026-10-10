#!/usr/bin/env bash
# Build and statically validate the OP64D3L1 integration recovery image.
set -Eeuo pipefail
export LC_ALL=C

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DEVICE_TREE=$(cd -- "$SCRIPT_DIR/.." && pwd)
DEFAULT_SRC=$(cd -- "$SCRIPT_DIR/../../../.." && pwd)
TWRP_SRC=${TWRP_SRC:-$DEFAULT_SRC}
ARTIFACT_DIR=${ARTIFACT_DIR:-$(cd -- "$TWRP_SRC/.." && pwd)/rtyu-integration-build}
JOBS=${JOBS:-32}
CLEAN=${CLEAN:-1}
BUILD_SUFFIX=${BUILD_SUFFIX:-v2}
STAMP=$(date +%Y-%m-%d-%H%M)

if [[ ! -f "$TWRP_SRC/build/envsetup.sh" ]]; then
    echo "ERROR: TWRP source not found: $TWRP_SRC" >&2
    echo "Set TWRP_SRC to the Android/TWRP source root." >&2
    exit 2
fi
if [[ ! -f "$TWRP_SRC/device/oneplus/OP64D3L1/AndroidProducts.mk" ]]; then
    echo "ERROR: device tree is not installed at $TWRP_SRC/device/oneplus/OP64D3L1" >&2
    exit 2
fi

GUI_SOURCE=$TWRP_SRC/bootable/recovery/gui/gui.cpp
GUI_PATCH=$DEVICE_TREE/patches/0001-twrp-gui-input-latency-frame-timeout.patch
if ! grep -q 'Keep input handling tied to the render cadence' "$GUI_SOURCE"; then
    echo "Applying local GUI input-latency patch"
    patch --dry-run -p1 -d "$TWRP_SRC" < "$GUI_PATCH" >/dev/null
    patch -p1 -d "$TWRP_SRC" < "$GUI_PATCH"
else
    echo "Local GUI input-latency patch already applied"
fi

mkdir -p "$ARTIFACT_DIR"
cd "$TWRP_SRC"

if [[ "$CLEAN" == 1 ]]; then
    echo "Cleaning target product output"
    # Keep the clean operation portable across Linux build hosts.
    python3 - <<PY
from pathlib import Path
import shutil
base = Path("$TWRP_SRC") / "out/target/product/OP64D3L1"
if base.exists():
    shutil.rmtree(base)
PY
fi

# Enter the Android build environment after path and option validation.
set +u
source build/envsetup.sh
lunch twrp_OP64D3L1
set -u

# Build this prebuilt before recoveryimage. In a parallel clean build, the
# recovery ramdisk timestamp rule can otherwise race its install target.
m -j"$JOBS" out/target/product/OP64D3L1/system/etc/task_profiles.json
m -j"$JOBS" recoveryimage

IMAGE=$TWRP_SRC/out/target/product/OP64D3L1/recovery.img
ROOT=$TWRP_SRC/out/target/product/OP64D3L1/recovery/root
[[ -s "$IMAGE" ]]
[[ $(stat -c '%s' "$IMAGE") == 104857600 ]]

required_staged_files=(
    system/bin/prepdecrypt.sh
    system/bin/twrp_settings
    system/bin/init.recovery.wifi.sh
    system/bin/init.recovery.adsp.sh
    system/bin/7za
    system/bin/zstd
    vendor/bin/hw/android.hardware.security.keymint-service-qti
    vendor/bin/hw/android.hardware.gatekeeper-service-qti
    vendor/bin/hw/android.hardware.boot-service.qti
    vendor/bin/hw/vendor.oplus.hardware.vibrator-service
    vendor/bin/qseecomd
    vendor/bin/wpa_supplicant
    vendor/lib64/libboot_control_qti.so
)
for file in "${required_staged_files[@]}"; do
    [[ -f "$ROOT/$file" ]] || { echo "Missing staged file: $file" >&2; exit 1; }
done

if grep -R -q 'interface aidl android.system.keystore2.IKeystoreService/default' "$DEVICE_TREE"; then
    echo "Unexpected v17 keystore interface override in device tree" >&2
    exit 1
fi

DEST=$ARTIFACT_DIR/TWRP-3.7.1-16-OP64D3L1-${STAMP}-rtyu-integration-${BUILD_SUFFIX}.img
cp -f "$IMAGE" "$DEST"
sha256sum "$DEST" | tee "$DEST.sha256"
stat -c 'SIZE=%s' "$DEST"
file "$DEST" || true
printf 'DEST=%s\n' "$DEST"
