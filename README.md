# OnePlus Turbo 6V / OP64D3L1 TWRP 设备树

这是 OnePlus Turbo 6V 的 TWRP 设备树和刷机资产整理仓库。仓库源码用于构建 TWRP；体积较大的 `boot.img`、`vendor_boot.img`、`vbmeta*.img`、官方 `recovery.img` 和已验证 TWRP 镜像统一放在 GitHub Release 里下载。

## 设备信息

| 项目 | 内容 |
| --- | --- |
| 设备 | OnePlus Turbo 6V |
| 型号 | PLY110 / OP64D3L1 |
| 平台 | Qualcomm SM7635 / volcano |
| Bootloader product | pineapple |
| 已知官方底包 | PLY110_16.0.8.300(CN01)_0370 |
| Recovery 镜像格式 | Android boot image v4，lz4 recovery ramdisk，无 kernel payload |

## v0.0.1 下载

Release 页面：[v0.0.1](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/tag/v0.0.1)

| 文件 | 用途 | SHA256 |
| --- | --- | --- |
| [TWRP-3.7.1-16-OP64D3L1-2026-07-03-1915-data-decrypt-keystore-iface-v17.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/TWRP-3.7.1-16-OP64D3L1-2026-07-03-1915-data-decrypt-keystore-iface-v17.img) | `/data` 解密实验版 v17，补充 keystore2 AIDL interface 注册 | `f4476564ca4d5034ca4775b0555ec11d392d85e6000c06478c23c123ed702d5e` |
| [TWRP-3.7.1-16-OP64D3L1-2026-07-03-143959-no-timeout-no-otg.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/TWRP-3.7.1-16-OP64D3L1-2026-07-03-143959-no-timeout-no-otg.img) | 已验证可用的 TWRP v0.0.1 | `293150a8d0e71c3213d6a70d7fdc982b423f679353081c73485ab76f2f83e0b3` |
| [boot.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/boot.img) | 官方 boot 分区 | `44901063653fb1094cb758f255a08f96601dff6a7059f4c03fdbe2ea60e224d9` |
| [vendor_boot.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/vendor_boot.img) | 官方 vendor_boot 分区 | `90a2fb3a065eea375b696ed81cf0659a28ffe77430d2c326f25b3940a6b8f70c` |
| [init_boot.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/init_boot.img) | 官方 init_boot 分区 | `924e8cc8609080b5953b6c0b4d0c94895e36e93c7de9bed30825d9b74d528bcd` |
| [dtbo.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/dtbo.img) | 官方 dtbo 分区 | `963e47a775e8e7bee94d2591a06138c4fe5a47b1941afd7c7b348d3b6951d3d3` |
| [recovery.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/recovery.img) | 官方 recovery，用于恢复原厂 recovery | `f54ce772331b162d4f1774452032b409b0195233454bdb7e7a0a8770b7d22398` |
| [vbmeta.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/vbmeta.img) | 官方 vbmeta | `ac71a0440cccb8fc018a61877e03ba7719ce16cb0f444b4d740fc7019f559f92` |
| [vbmeta_system.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/vbmeta_system.img) | 官方 vbmeta_system | `74c375f461fce415c224e250a4078d77fd2e2d156430af159ea1b35c4a556144` |
| [vbmeta_vendor.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/vbmeta_vendor.img) | 官方 vbmeta_vendor | `56e1a6ac03184349203aa3a6cc9fd618bf5742971113b7e3012a2c444711d2fe` |
| [vbmeta_disabled_flags3.img](https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/download/v0.0.1/vbmeta_disabled_flags3.img) | 本地生成的禁用校验 vbmeta，仅在需要关闭 AVB 校验时使用 | `09cf4724789687a721edc3f3f57988fc50b4bf520cf10c3bbc187dc2ee70b545` |

完整校验清单见：[docs/v0.0.1-assets.sha256](docs/v0.0.1-assets.sha256)。

说明：

- 上表的官方分区镜像来自 `PLY110_16.0.8.300(CN01)_0370` 官方包提取结果。
- 本仓库没有单独发布 `vendor.img`；该机型的完整 vendor 动态分区在官方 OTA/super 体系内。这里整理的是刷 recovery/恢复原厂常用的 `vendor_boot.img` 和 `vbmeta_vendor.img`。
- 原始官方完整包约 7.3GB，不适合作为 GitHub Release 单个资产上传；本仓库只发布已提取的常用分区镜像。

## v0.0.1 状态

已在 OnePlus Turbo 6V / PLY110 上验证，测试刷入位置为 `recovery_b`，随后也可按需刷入两个 recovery 槽位。

- 触控使用官方 OPlus Touch AIDL 服务和 Prado 触控资源。
- 默认语言为简体中文，并提高 recovery 亮度。
- 禁用 TWRP 屏幕超时、锁屏遮罩和震动，避免 recovery 内 UI 响应变慢。
- 临时禁用通用 OTG/可移动存储自动扫描，避免把内部 UFS LUN 误识别成 `/usb_otg-*`。
- 包含 TWRP GUI 输入延迟补丁：`patches/0001-twrp-gui-input-latency-frame-timeout.patch`。

已知取舍：v0.0.1 暂时不启用 USB OTG 存储，后续确认 Turbo 6V 准确 USB 块设备路径后再恢复。

## `/data` 解密实验版

`TWRP-3.7.1-16-OP64D3L1-2026-07-03-1915-data-decrypt-keystore-iface-v17.img` 是基于 v0.0.1 继续排查 `/data` 解密的实验镜像。它加入 QCOM FBE/metadata decrypt 配置、KeyMint/Gatekeeper/QSEE 依赖、早期 `/odm` 挂载，以及 `keystore2` 的 `android.system.keystore2.IKeystoreService/default` AIDL interface 声明。

该版本用于验证解密链路，不代表已经完整解决 `/data` 解密；需要稳定使用 recovery 时，优先使用上表中已验证的 `no-timeout-no-otg` 镜像。

## 构建 TWRP

```bash
repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
repo sync
git clone --depth=1 https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1 device/oneplus/OP64D3L1
git apply device/oneplus/OP64D3L1/patches/0001-twrp-gui-input-latency-frame-timeout.patch
source build/envsetup.sh
lunch twrp_OP64D3L1
m recoveryimage
```

设备树来源于公开的 OPlus Android 16 TWRP sm87xx 设备树，并按 Turbo 6V 调整为 `volcano`、`OP64D3L1`、`PLY110` 和 `ro.boot.prjname=25811`。

## 常用 fastboot 命令

刷入 TWRP：

```bash
fastboot flash recovery_a TWRP-3.7.1-16-OP64D3L1-2026-07-03-143959-no-timeout-no-otg.img
fastboot flash recovery_b TWRP-3.7.1-16-OP64D3L1-2026-07-03-143959-no-timeout-no-otg.img
fastboot reboot recovery
```

恢复官方 recovery：

```bash
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
fastboot reboot recovery
```

恢复官方 boot / vendor_boot / init_boot / dtbo：

```bash
fastboot flash boot_a boot.img
fastboot flash boot_b boot.img
fastboot flash vendor_boot_a vendor_boot.img
fastboot flash vendor_boot_b vendor_boot.img
fastboot flash init_boot_a init_boot.img
fastboot flash init_boot_b init_boot.img
fastboot flash dtbo_a dtbo.img
fastboot flash dtbo_b dtbo.img
```

恢复官方 vbmeta：

```bash
fastboot flash vbmeta_a vbmeta.img
fastboot flash vbmeta_b vbmeta.img
fastboot flash vbmeta_system_a vbmeta_system.img
fastboot flash vbmeta_system_b vbmeta_system.img
fastboot flash vbmeta_vendor_a vbmeta_vendor.img
fastboot flash vbmeta_vendor_b vbmeta_vendor.img
```

仅在明确需要关闭 AVB 校验时，才考虑刷入 `vbmeta_disabled_flags3.img`：

```bash
fastboot flash vbmeta_a vbmeta_disabled_flags3.img
fastboot flash vbmeta_b vbmeta_disabled_flags3.img
```

## 注意事项

- 刷机前确认自己的系统版本和上面的官方底包版本一致或足够接近，跨版本混刷 boot、vendor_boot、vbmeta 有变砖风险。
- `vbmeta_disabled_flags3.img` 不是官方原始文件，只适合需要禁用校验的场景；想恢复官方状态请刷回 `vbmeta.img`。
- 刷入任何分区前，建议先确认当前槽位：`fastboot getvar current-slot`。
- 本仓库用于 OnePlus Turbo 6V / OP64D3L1，不要直接用于其他 OnePlus/OPlus 机型。
