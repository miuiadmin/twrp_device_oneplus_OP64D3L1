# 机型适配过程

## 设备身份

- 产品：OnePlus Turbo 6V
- 项目：`OP64D3L1`
- 型号：`PLY110`
- 平台：Qualcomm `volcano`
- UFS bootdevice：`1d84000.ufshc`
- 屏幕：1272x2772，portrait UI
- A/B：是，recovery 有 `recovery_a` / `recovery_b`

## 启动镜像形态

适配初期从官方镜像和 fastboot 分区确认：

- recovery image 是 boot header v4。
- pagesize `4096`。
- ramdisk 使用 `lz4_legacy`。
- recovery 分区大小 `0x6400000`，即 `104857600` 字节。
- recovery image 不嵌入内核 payload，kernel/dtb 由设备树预编译文件提供。

关键配置：

```make
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_USE_LZ4 := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
```

## userdata / super

官方 `/data` 条目保留了完整加密参数：

```text
fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0
keydirectory=/metadata/vold/metadata_encryption
metadata_encryption=aes-256-xts:wrappedkey_v0
```

super 动态分区包含 system、vendor、product、odm 以及 OPlus `my_*` 分区。TWRP fstab 中保留 slotselect 和 logical 标记，保证 A/B 镜像选择和槽位切换不受影响。

## 触控与显示

本地早期适配经历了三条路线：

1. 直接加载 focaltech kernel module：不稳定，后续移除。
2. 挂载官方 ODM，再启动 OPlus Touch AIDL 服务：能工作，但脚本和服务管理复杂。
3. rtyutechstudio 直接内置 touch service、NDK 库和 Prado 固件：当前采用。

本地保留 GUI 输入延迟补丁，把事件等待时间从最长 500ms 绑定到渲染节拍，并配置 `TW_FRAMERATE := 60`。

亮度路径最终为：

```make
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 4096
TW_DEFAULT_BRIGHTNESS := 2600
```

## USB / OTG

早期 TWRP 会把内部 UFS LUN 误识别成 USB OTG，并引起存储扫描等待。v0.0.1 曾禁用 OTG 扫描保证启动。rtyutechstudio 树保留 `/usb_otg` 条目；当前验收重点是不让 OTG 探测阻塞主流程。

## 外设服务

当前树内置：

- Qualcomm boot HAL：A/B 槽位切换。
- OPlus vibrator HAL 和 haptic 固件。
- Health AIDL service：电池/充电状态。
- QCA6750 WiFi 模块、firmware 和 wpa_supplicant。
- OPlus touch payload 与 Prado 固件。

## 适配新版本的建议

1. 先提取官方 fstab、boot image header、dtbo 和 super 分区表。
2. 保持 recovery image 大小和 header 版本不变。
3. 单独验证触控和显示，不先启用 crypto。
4. 引入 crypto 前保存可启动镜像。
5. 使用 `tools/inspect-recovery-image.sh` 检查实际 cpio，而不是只看源码。
6. 使用 `tools/verify-recovery-device.sh` 做统一真机验收。
