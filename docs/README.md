# OP64D3L1 / Turbo 6V TWRP 研发文档索引

本文档记录 OnePlus Turbo 6V（`OP64D3L1` / `PLY110`）TWRP 从首次适配、触控优化、`/data` 解密失败实验，到引入 rtyutechstudio 可用算法并完成本地增强的全过程。

## 当前推荐版本

- 分支：`main` / `rtyu-integration`
- Release：`v0.2.0-rtyu-integration`
- 镜像 SHA-256：`ec390fcfb5fd44e761ebb5f34df813d2c2c007b6b26c5b631a2cdc57cc4c1527`
- 当前能力：FBE/metadata `/data` 解密、MTP、WiFi 驱动栈、A/B 槽位服务、震动、电池/充电服务、60fps UI、7za/zstd、全分区工具。

## 文档地图

| 文档 | 内容 |
|---|---|
| [01-research-methodology.md](01-research-methodology.md) | 研发流程、变量控制、验收门禁和回滚原则 |
| [02-device-adaptation.md](02-device-adaptation.md) | 机型适配过程：板级、启动镜像、fstab、触控、显示、USB 和分区 |
| [03-data-decryption-design.md](03-data-decryption-design.md) | `/data` FBE/metadata 解密算法、服务链路、失败假设和最终方案 |
| [04-feature-integration-map.md](04-feature-integration-map.md) | rtyutechstudio 每个修复的 commit、文件组和运行机制 |
| [05-build-and-validation-runbook.md](05-build-and-validation-runbook.md) | 从源码同步、打补丁、构建、静态检查、刷机到真机验收 |
| [06-pitfall-log.md](06-pitfall-log.md) | 全过程踩坑日志和结论 |
| [07-release-and-rollback.md](07-release-and-rollback.md) | Release 治理、资产清理、校验、刷入和回滚 |
| [rtyu-integration-v2.md](rtyu-integration-v2.md) | v2 集成版验证报告 |
| [data-decryption-notes.md](data-decryption-notes.md) | 早期解密实验原始结论，保留作历史记录 |
| [logs/README.md](logs/README.md) | 关键日志索引和摘录说明 |
| [release-notes/v0.2.0-rtyu-integration.md](release-notes/v0.2.0-rtyu-integration.md) | 当前推荐镜像的发布说明 |
| [release-notes/v0.0.1-archive.md](release-notes/v0.0.1-archive.md) | 旧实验资产清理后的归档说明 |

## 快速入口

```bash
# Linux 构建服务器上，设备树位于 TWRP source 时
tools/build-integration.sh

# 已进入 TWRP 的真机验收
tools/verify-recovery-device.sh

# 不刷机，借用当前 TWRP 的 magiskboot 检查镜像
tools/inspect-recovery-image.sh IMAGE.img
```

## 安全原则

- 不格式化、不擦除 `/data`。
- 每次试验前确认本地和 Release 中都有可回滚镜像。
- 解密相关改动必须同时通过静态 ramdisk 检查和真机服务检查。
- Recovery 启动至少观察 90 秒；本机完整解密启动约 54-77 秒。
