# rtyutechstudio integration v2

- Date: 2026-10-10
- Branch: `rtyu-integration`
- Upstream: `rtyutechstudio/android_device_OnePlus_OP64D3L1-twrp@6b35fd1cb827e2f74c7e1831f16ddcf9af49b204`
- Image: `TWRP-3.7.1-16-OP64D3L1-2026-10-10-1619-rtyu-integration-v2-clean.img`
- SHA-256: `ec390fcfb5fd44e761ebb5f34df813d2c2c007b6b26c5b631a2cdc57cc4c1527`
- Size: `104857600` bytes

## Integrated upstream fixes

- FBE/metadata userdata decryption through `prepdecrypt`, QSEE, KeyMint, and Gatekeeper.
- Qualcomm A/B boot HAL for TWRP slot switching.
- OPlus vibrator HAL, haptic libraries, and firmware.
- Health/charger service and battery reporting.
- QCA6750 WiFi modules, firmware, supplicant, and configuration.
- Backlight path and default brightness.
- Touch HAL payload and firmware.

## Local enhancements retained

- TWRP GUI input-latency/frame-timeout source patch.
- `TW_FRAMERATE := 60`.
- All partition tools, `7za`, and `zstd`.
- Local documentation, experiment notes, and release checksum history.

## On-device verification

The v2 image was flashed to both recovery slots. ADB appeared after 54 seconds
and remained online. After entering the device PIN, TWRP logged:

```text
I:Successfully decrypted metadata encrypted data partition with new block device: '/dev/block/dm/userdata'
User 0 Decrypted Successfully!
I:New storage path after decryption: /data/media/0
MTP 已启用
```

Verified running services included ADB, QSEE, KeyMint, Gatekeeper, Qualcomm
boot HAL, OPlus vibrator, health/charger, and wpa_supplicant. The QCA6750,
mac80211, cfg80211, and ICNSS modules were loaded. `/data/media/0` listed the
expected plaintext user directories.

## Regression note

The first integration build enabled `TW_USE_NEW_MINADBD := true`. Its first
recovery boot exposed no USB, ADB, or fastboot device for over 150 seconds.
After a manual reboot ADB worked, but the setting was removed in v2 to keep the
already-proven adbd stack. Do not re-enable it without a dedicated USB-reliability
test across multiple cold recovery boots.
