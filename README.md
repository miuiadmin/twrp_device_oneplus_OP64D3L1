# OnePlus OP64D3L1 / Turbo 6V TWRP integration

This branch integrates the working recovery stack from
[rtyutechstudio/android_device_OnePlus_OP64D3L1-twrp](https://github.com/rtyutechstudio/android_device_OnePlus_OP64D3L1-twrp)
with the enhancements and release documentation maintained in this repository.

## Integrated upstream fixes

- FBE/metadata userdata decryption using `prepdecrypt`, QSEE, KeyMint, and Gatekeeper
- Qualcomm A/B boot HAL support for TWRP slot switching
- OPlus vibrator HAL and haptic firmware
- Health/charger service and battery reporting
- QCA6750 WiFi driver, firmware, and wpa_supplicant stack
- Backlight configuration
- Touch HAL payload and firmware

## Retained local enhancements

- TWRP GUI input-latency/frame-timeout source patch:
  `patches/0001-twrp-gui-input-latency-frame-timeout.patch`
- Local release checksums and asset notes under `docs/`
- Data-decryption experiment notes for regression tracking
- Rollback image procedures and SHA-256 verification workflow
- Stable default adbd configuration. Do not enable `TW_USE_NEW_MINADBD` here; it caused
  a first recovery boot with no USB/ADB/fastboot device in on-device testing.

The failed v17 device-tree `keystore2.rc` override is intentionally absent. The
base TWRP source supplies its normal `keystore2.rc`; this device tree relies on
the proven QCOM `prepdecrypt` sequence instead.

## Verified on device

A clean build from this upstream tree was flashed to both recovery slots and
verified to decrypt user 0 successfully. `/data/media/0` was mounted read-write,
MTP was enabled, and KeyMint, Gatekeeper, QSEE, boot, vibrator, health, and
WiFi services were running.

Do not format or wipe `/data` while testing decryption.
