#!/usr/bin/env bash
# Inspect a recovery image without flashing it, using magiskboot from the
# currently running TWRP.
set -Eeuo pipefail
export LC_ALL=C

[[ $# == 1 ]] || { echo "Usage: $0 RECOVERY.img" >&2; exit 2; }
IMAGE=$1
[[ -f "$IMAGE" ]] || { echo "ERROR: not a file: $IMAGE" >&2; exit 2; }
[[ $(adb get-state 2>/dev/null || true) == recovery ]] || {
    echo "ERROR: a running TWRP ADB connection is required" >&2
    exit 2
}

remote_image=/tmp/op64d3l1-inspect-$$.img
remote_dir=/tmp/op64d3l1-inspect-$$
adb shell "mkdir -p '$remote_dir'"
adb push "$IMAGE" "$remote_image" >/dev/null

echo '=== boot image header ==='
adb shell "cd '$remote_dir' && /system/bin/magiskboot unpack -h '$remote_image'"

executables=(
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
)
failures=0
for path in "${executables[@]}"; do
    line=$(adb shell "cd '$remote_dir' && /system/bin/magiskboot cpio ramdisk.cpio 'ls -r $path'" 2>/dev/null | tail -n 1 | tr -d '\r')
    case "$line" in
        -rwxr-xr-x*)
            printf 'PASS %s\n' "$line"
            ;;
        *)
            printf 'FAIL %s\n' "$line" >&2
            failures=$((failures + 1))
            ;;
    esac
done

required_files=(
    init.recovery.qcom_decrypt.rc
    system/etc/init/keystore2.rc
    system/etc/init/android.hardware.boot-service.qti.rc
    system/etc/init/android.hardware.health-service.qti.rc
    system/etc/init/vibrator-default.rc
    vendor/lib64/libboot_control_qti.so
)
for path in "${required_files[@]}"; do
    line=$(adb shell "cd '$remote_dir' && /system/bin/magiskboot cpio ramdisk.cpio 'ls -r $path'" 2>/dev/null | tail -n 1 | tr -d '\r')
    if [[ $line == -* ]]; then
        printf 'PASS %s\n' "$line"
    else
        printf 'FAIL missing %s\n' "$path" >&2
        failures=$((failures + 1))
    fi
done

adb shell "cd '$remote_dir' && /system/bin/magiskboot cpio ramdisk.cpio 'extract system/etc/init/keystore2.rc $remote_dir/keystore2.rc'" >/dev/null
if adb shell "grep -q 'interface aidl android.system.keystore2.IKeystoreService/default' '$remote_dir/keystore2.rc'" >/dev/null 2>&1; then
    echo 'FAIL v17 keystore interface override is present' >&2
    failures=$((failures + 1))
else
    echo 'PASS v17 keystore interface override absent'
fi

if (( failures )); then
    echo "IMAGE INSPECTION FAILED: $failures failure(s)" >&2
    exit 1
fi
echo 'IMAGE INSPECTION PASSED'
