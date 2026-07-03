# TWRP device tree for OnePlus Turbo 6V

Device: OnePlus Turbo 6V / PLY110 / OP64D3L1  
Platform: SM7635 / volcano  
Bootloader product: pineapple  
Recovery image layout: Android boot image v4, lz4 recovery ramdisk, no kernel payload  
Known stock build used for extraction: PLY110_16.0.8.300(CN01)

## Build

```bash
repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
repo sync
git clone --depth=1 https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1 device/oneplus/OP64D3L1
git apply device/oneplus/OP64D3L1/patches/0001-twrp-gui-input-latency-frame-timeout.patch
source build/envsetup.sh
lunch twrp_OP64D3L1
m recoveryimage
```

This tree was derived from the public OPlus Android 16 TWRP sm87xx tree, but the Turbo 6V-specific parts are set to `volcano`, `OP64D3L1`, `PLY110`, and `ro.boot.prjname=25811`.

## v0.0.1 status

Validated on OnePlus Turbo 6V / PLY110, slot `recovery_b`.

- Uses the stock OPlus touch AIDL service from `/odm` with the Prado touch resources.
- Defaults to Chinese language and higher panel brightness.
- Disables TWRP screen timeout/lock overlay and haptics to avoid slow UI response in recovery.
- Disables generic removable-storage auto scan for now because it mis-detects internal UFS LUNs as `/usb_otg-*`.
- Includes a TWRP GUI input-latency patch under `patches/`.

Known trade-off: USB OTG storage is intentionally disabled in v0.0.1 until the exact Turbo 6V USB block path is mapped.
