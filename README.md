# OnePlus OP64D3L1 / Turbo 6V TWRP

This repository contains the TWRP device tree for OnePlus Turbo 6V
(`OP64D3L1` / `PLY110`). The current `rtyu-integration` lineage integrates the
working Qualcomm recovery stack from
[rtyutechstudio/android_device_OnePlus_OP64D3L1-twrp](https://github.com/rtyutechstudio/android_device_OnePlus_OP64D3L1-twrp)
at commit `6b35fd1cb827e2f74c7e1831f16ddcf9af49b204`, while retaining local
input-latency and tooling enhancements.

## Current capabilities

- Stable recovery GUI with 60 fps input cadence
- FBE v2 / metadata encrypted `/data` decryption
- User 0 synthetic-password decryption after PIN entry
- `/data/media/0` and MTP access
- Qualcomm A/B boot HAL for slot switching
- QCA6750 WiFi driver, firmware, and wpa_supplicant stack
- OPlus vibrator HAL and haptic firmware
- Health/charger service for battery reporting
- Touch HAL payload and Prado touch firmware
- All partition tools, `7za`, and `zstd`

## Recommended image

```text
TWRP-3.7.1-16-OP64D3L1-2026-10-10-1619-rtyu-integration-v2-clean.img
SHA256 ec390fcfb5fd44e761ebb5f34df813d2c2c007b6b26c5b631a2cdc57cc4c1527
SIZE   104857600
```

Release: [v0.2.0-rtyu-integration](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/tag/v0.2.0-rtyu-integration)

Old v17-v23 experiment images are documented for audit history but are no longer
published as downloadable Release assets. The only recommended TWRP download is
the verified v2 image above.

## Documentation

The full research, adaptation, algorithm, build, validation, pitfall, and
release history is indexed in [docs/README.md](docs/README.md). Start there.

Key entries:

- [Research methodology](docs/01-research-methodology.md)
- [Device adaptation](docs/02-device-adaptation.md)
- [Data decryption design](docs/03-data-decryption-design.md)
- [Upstream feature map](docs/04-feature-integration-map.md)
- [Build and validation runbook](docs/05-build-and-validation-runbook.md)
- [Pitfall log](docs/06-pitfall-log.md)
- [Release and rollback](docs/07-release-and-rollback.md)

## Build

On a Linux TWRP build host:

```bash
tools/build-integration.sh
```

Set `TWRP_SRC` if the device tree is not already located at
`$TWRP_SRC/device/oneplus/OP64D3L1`.

## Validate

Inspect an image without flashing it:

```bash
tools/inspect-recovery-image.sh RECOVERY.img
```

Validate a running recovery:

```bash
tools/verify-recovery-device.sh
```

## Flash

```bash
fastboot flash recovery_a RECOVERY.img
fastboot flash recovery_b RECOVERY.img
fastboot reboot recovery
```

Wait at least 90 seconds before declaring a boot failure. The verified v2 image
exposed ADB after 54 seconds and completed user decryption after PIN entry.

## Important safety rules

- Do not wipe, format, or resize `/data`.
- Always keep a rollback recovery available locally.
- Do not re-enable `TW_USE_NEW_MINADBD`; the first integration build lost USB,
  ADB, and fastboot for over 150 seconds on cold recovery boot.
- Do not restore the failed v17 device-tree `keystore2.rc` interface override.
