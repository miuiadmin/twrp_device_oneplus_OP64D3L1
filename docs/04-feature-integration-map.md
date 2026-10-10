# rtyutechstudio 修复映射与合并策略

上游基线：

```text
https://github.com/rtyutechstudio/android_device_OnePlus_OP64D3L1-twrp
commit 6b35fd1cb827e2f74c7e1831f16ddcf9af49b204
```

本地合并保留上游完整历史，形成双父 merge commit，并在其上叠加本地增强。

## Commit 映射

| Upstream commit | 主题 | 关键结果 |
|---|---|---|
| `77c386d` | 初始设备树 | 引入 prebuilt kernel/dtb、fstab、QSEE/KeyMint/Gatekeeper/boot/vibrator 基础文件 |
| `437a8ec` | Fix touch | 试验性加载 focaltech 模块，后续被替换 |
| `1f5e355` | fixed touch screen | 移除 focaltech 模块，改用 OPlus Touch AIDL payload |
| `f238c9a` | vibrator / shared objects | 修正 vibrator 服务路径，补 haptic 和 boot control 共享库，亮度上限调到 4096 |
| `99aafe8` | fixed | 加入 haptic 固件、health service、CPU 温度路径 |
| `222339e` | fixed brightness | 切换到 `panel0-backlight`，设置默认亮度 |
| `3602fd8` | Fix decryption | 引入完整 QSEE/vendor firmware/touch 库和 ueventd 规则，修正解密链 |
| `677281d` | Fix wifi | 加入 QCA6750 模块、firmware、wpa_supplicant、busybox 和 WiFi 初始化脚本 |
| `392f05d` | Fix battery info | 加入 health AIDL manifest/库，启动 ADSP 相关模块 |
| `9867787` / `6b35fd1` | fixed | 最终修正 `twrp_settings` 安装路径和目标文件名 |

## 解密

文件组：

- `recovery/root/init.recovery.qcom_decrypt.rc`
- `recovery/root/system/bin/prepdecrypt.sh`
- `recovery/root/system/bin/twrp_settings`
- `recovery/root/system/etc/twrp.flags`
- QSEE / KeyMint / Gatekeeper 二进制和库

机制详见 [03-data-decryption-design.md](03-data-decryption-design.md)。

## A/B 槽位切换

文件组：

- `vendor/bin/hw/android.hardware.boot-service.qti`
- `vendor/lib64/libboot_control_qti.so`
- `system/etc/init/android.hardware.boot-service.qti.rc`
- VINTF boot manifest

真机状态：

```text
init.svc.vendor.boot-qti=running
ro.boot.slot_suffix=_a
```

TWRP 槽位切换依赖该 HAL，不再只靠分区名猜测。

## WiFi

文件组：

- `system/bin/init.recovery.wifi.sh`
- `vendor/lib/modules/{cfg80211,mac80211,icnss2,qca_cld3_qca6750,...}.ko`
- `vendor/firmware_mnt/image/qca6750/*`
- `vendor/etc/wifi/*`
- `vendor/bin/wpa_supplicant`
- `system/bin/wpa_cli` 和 busybox

加载顺序：

```text
rfkill
libarc4
cfg80211
cnss_nl
cnss_utils
cnss_prealloc
q6_pdr_dlkm
snd_event_dlkm
wlan_firmware_service
icnss2
mac80211
qca_cld3_qca6750
```

脚本会等待 firmware 和 `wlan0`，生成 wpa_supplicant 配置和 DHCP 脚本，再启动 supplicant。

## 震动

文件组：

- `vendor/bin/hw/vendor.oplus.hardware.vibrator-service`
- `vendor/etc/init/vibrator-default.rc`
- `vendor/etc/vintf/manifest/vibrator-default.xml`
- `libaacvibrator.so`、`liboplusvibratoreffect.so`、`libtfavib.so` 等
- `vendor/firmware/aw8697_haptic*.bin`

服务路径从错误的 `/odm/bin/hw/...` 改为 `/vendor/bin/hw/...`。

## 电池 / 充电

文件组：

- `system/bin/android.hardware.health-service.qti_recovery`
- `system/etc/init/android.hardware.health-service.qti.rc`
- Health V2 NDK 库和 VINTF manifest
- `init.recovery.adsp.sh`

ADSP 模块加载顺序：

```text
q6_pdr_dlkm
q6_notifier_dlkm
snd_event_dlkm
gpr_dlkm
spf_core_dlkm
adsp_loader_dlkm
```

然后写入：

```text
/sys/kernel/boot_adsp/boot = 1
```

## 触控

文件组：

- `system/bin/vendor-oplus-hardware-touch-V2-hbp5-service`
- `vendor.oplus.hardware.touch-V2-ndk.so`
- OLC / TensorFlow Lite / touch 算法库
- `odm/firmware/tp/prado/*`

当前触控可用，但 `init.svc.touch-aidl` 有时显示 `restarting`。这是后续优化项，不影响当前解密和主 UI。

## 本地增强

- GUI 输入延迟补丁。
- `TW_FRAMERATE := 60`。
- `TW_ENABLE_ALL_PARTITION_TOOLS := true`。
- `TW_INCLUDE_7ZA := true`。
- `TW_INCLUDE_ZSTD := true`。
- 完整研发文档和验证脚本。
