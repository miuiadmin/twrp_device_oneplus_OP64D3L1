# Release 治理与回滚

## 当前唯一推荐 TWRP 资产

```text
TWRP-3.7.1-16-OP64D3L1-2026-10-10-1619-rtyu-integration-v2-clean.img
SHA256 ec390fcfb5fd44e761ebb5f34df813d2c2c007b6b26c5b631a2cdc57cc4c1527
SIZE   104857600
```

发布位置：

```text
https://github.com/miuiadmin/twrp_device_oneplus_OP64D3L1/releases/tag/v0.2.0-rtyu-integration
```

## v0.0.1 归档清理

`v0.0.1` 不再提供早期 TWRP 实验 image，包括 v17-v23 解密失败版本、旧 `recovery.img` 和对应 sidecar/checksum。仓库保留 `docs/v0.0.1-assets.sha256` 作为历史审计记录。

仍在 `v0.0.1` 保留的回滚/非 TWRP 资产：

- 官方 `boot.img`、`vendor_boot.img`、`init_boot.img`、`dtbo.img`
- 官方 `vbmeta*.img`
- 原有 AK3 kernel archive
- 重新生成的 `SHA256SUMS` 和 `SUMMARY.md`

当前唯一可下载的 TWRP 入口是 `v0.2.0-rtyu-integration`。

## 发布原则

1. 100MB 镜像只放 GitHub Release asset，不进 git 历史。
2. 每个 image 必须同时上传 `.sha256`。
3. Release notes 必须写清：
   - upstream commit；
   - 本地增强；
   - 真机验证结果；
   - 已知问题；
   - 回滚方式。
4. 历史失败实验镜像不得继续作为 Release asset 提供，避免误刷。
5. 官方分区备份资产可与 TWRP 分开保留，但不能与实验 TWRP 混在同一个推荐入口。
6. 每次清理 Release 后必须重新列举 assets 并核对 digest。

## 验证 Release 资产

```bash
curl -L -o recovery.img URL
shasum -a 256 recovery.img
```

或使用 `gh`：

```bash
gh release view v0.2.0-rtyu-integration \
  --repo miuiadmin/twrp_device_oneplus_OP64D3L1 \
  --json assets
```

GitHub asset JSON 的 `digest` 应与本地 SHA256 一致。

## 刷入

```bash
IMG=TWRP-3.7.1-16-OP64D3L1-2026-10-10-1619-rtyu-integration-v2-clean.img

fastboot flash recovery_a "$IMG"
fastboot flash recovery_b "$IMG"
fastboot reboot recovery
```

## 回滚到 rtyu upstream 可解密版

本地归档：

```text
/Users/80417957/Documents/code/test/turbo6v/builds/rtyutechstudio-20261010/TWRP-3.7.1-16-OP64D3L1-2026-10-10-1526-rtyutechstudio-main-clean.img
SHA256 b532dc9360f604fcea4347266f07215ed16838313017cc10122f50fa6be76cc1
```

如 recovery 中 ADB 可用：

```bash
adb reboot bootloader
```

如无 USB，手动强制重启后进入 fastboot，再执行：

```bash
fastboot flash recovery_a ROLLBACK.img
fastboot flash recovery_b ROLLBACK.img
fastboot reboot recovery
```

## 回滚到早期不解密稳定版

仅用于 recovery GUI 应急：

```text
TWRP-3.7.1-16-OP64D3L1-2026-07-03-143959-no-timeout-no-otg.img
SHA256 293150a8d0e71c3213d6a70d7fdc982b423f679353081c73485ab76f2f83e0b3
```

该版本不能解 `/data`，只作为最后回滚路径，不再作为公开推荐 Release asset。

## 故障处置

- ADB/fastboot 均无设备：长按电源 + 音量上强制重启，再进 fastboot 回滚。
- 卡第一屏：至少等 90 秒，再判断。
- ADB 在但 `crypto.ready=0`：查 prepdecrypt、persist 挂载和 RC import。
- 安全服务不运行：查 QSEE 二进制、库、VINTF 和 service contexts。
- metadata 解密成功但用户文件乱码：输入锁屏 PIN，检查 `twrp.user.0.decrypt`。
