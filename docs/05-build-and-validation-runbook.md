# 构建与验证 Runbook

## 1. 准备 TWRP source

示例：

```bash
repo init --depth=1 \
  -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git \
  -b twrp-16.0
repo sync

git clone --branch rtyu-integration \
  https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1.git \
  device/oneplus/OP64D3L1
```

## 2. 构建

推荐脚本：

```bash
cd device/oneplus/OP64D3L1
tools/build-integration.sh
```

脚本会持有 `out/.op64d3l1-build-integration.lock`：同一 source tree 同时只允许一个 integration build，避免第二个实例删除正在构建的 target output。

可配置：

```bash
TWRP_SRC=/path/to/twrp/source
ARTIFACT_DIR=/path/to/artifacts
BUILD_SUFFIX=mytest
JOBS=32
tools/build-integration.sh
```

脚本做以下事情：

1. 检查 bootable TWRP GUI 低延迟补丁，未应用则应用。
2. 强制删除目标产品输出，避免旧 ramdisk 污染或 `odm/firmware` 目录/符号链接形态冲突。
3. 先构建 `system/etc/task_profiles.json`，规避本次发现的 Ninja 竞态。
4. 构建 `recoveryimage`。
5. 检查镜像大小和关键 staged 文件。
6. 检查设备树中没有 v17 keystore interface 覆盖。
7. 导出镜像和 `.sha256`。

## 3. 必须清理 target product output

一次 `CLEAN=0` 烟测在 restage recovery root 时失败：

```text
could not make way for new symlink: root/odm/firmware
cannot delete non-empty directory: root/odm/firmware
```

这是旧输出中的目录/符号链接形态与新设备树不一致导致的。该脚本始终删除
`out/target/product/OP64D3L1`，不提供增量构建旁路。

## 4. task_profiles.json 构建竞态

症状：

```text
cp: bad 'out/target/product/OP64D3L1/system/etc/task_profiles.json': No such file or directory
ninja: build stopped: subcommand failed.
```

原因是 recovery ramdisk timestamp 规则与该 prebuilt 的安装目标存在并行调度竞态。解决方式是先显式构建：

```bash
m out/target/product/OP64D3L1/system/etc/task_profiles.json
m recoveryimage
```

该顺序已固化到 `tools/build-integration.sh`。

## 5. 静态检查镜像

不刷机，借用当前 TWRP 内的 `magiskboot`：

```bash
tools/inspect-recovery-image.sh TWRP-*.img
```

必须确认：

- header v4，ramdisk `lz4_legacy`。
- `prepdecrypt.sh`、WiFi/ADSP 脚本、KeyMint、Gatekeeper、qseecomd、boot HAL、vibrator、wpa_supplicant 存在。
- 关键可执行文件为 `0755`。
- `keystore2.rc` 没有 v17 interface 覆盖。
- `7za` 和 `zstd` 存在。

## 7. 刷入前检查

```bash
shasum -a 256 IMAGE.img
adb devices
adb shell 'getprop crypto.ready'
```

确认手机在已知可用的 recovery 中，再进入 bootloader：

```bash
adb reboot bootloader
fastboot devices
fastboot getvar current-slot
```

## 7. 刷入

```bash
IMG=/path/to/TWRP-3.7.1-16-OP64D3L1-2026-10-10-1619-rtyu-integration-v2-clean.img

fastboot flash recovery_a "$IMG"
fastboot flash recovery_b "$IMG"
fastboot reboot recovery
```

## 8. 等待完整启动

至少等待 90 秒。验收命令：

```bash
tools/verify-recovery-device.sh
```

手动检查：

```bash
adb shell 'getprop crypto.ready'
adb shell 'getprop init.svc.vendor.qseecomd'
adb shell 'getprop init.svc.vendor.keymint-qti'
adb shell 'getprop init.svc.vendor.gatekeeper_default'
adb shell 'getprop twrp.user.0.decrypt'
adb shell 'mount | grep " /data "'
adb shell 'ls -la /data/media/0'
adb shell 'grep -E "Successfully decrypted|User 0 Decrypted|New storage path|MTP" /tmp/recovery.log'
```

## 9. 保存证据

```bash
adb pull /tmp/recovery.log recovery-success.log
shasum -a 256 IMAGE.img > IMAGE.img.sha256
```

发布前将关键日志结论写入 `docs/logs/`，不要只保留聊天记录。

## 10. 回滚

见 [07-release-and-rollback.md](07-release-and-rollback.md)。任何 USB 消失、卡第一屏或核心服务不运行的情况，先回滚已知可用镜像，再定位差异。
