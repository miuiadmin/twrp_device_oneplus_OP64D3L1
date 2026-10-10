# 全过程踩坑日志

## 时间线总览

| 阶段 | 试验 | 结果 | 结论 |
|---|---|---|---|
| 2026-07-02 | 首次 TWRP 设备树 | 能构建，但触控/UI 不理想 | 先解决基础启动和输入 |
| 2026-07-03 早期 | ODM touch service、亮度、电池线程、OTG 扫描 | 得到 no-timeout/no-otg 稳定版 | 稳定 GUI 与解密分开处理 |
| 2026-07-03 v1-v17 | 补 VINTF、QSEE、KeyMint、Gatekeeper、ODM、APEX、keystore interface | 多数卡启动或无法解密 | 不能靠静态声明堆料 |
| 2026-07-07 v18-v23 | 启动时序、用户、fstab 旧参数、additional fstab、平台版本 | 全部未成功 | keystore2 不是根因 |
| 2026-10-10 | 分析 rtyutechstudio | 找到 prepdecrypt/persist/crypto.ready 算法 | 方向正确 |
| 2026-10-10 | rtyu clean build | 真机解密成功 | upstream 基线可用 |
| 2026-10-10 | 本地整合 v1 | 解密成功但冷启动 USB 消失 | `TW_USE_NEW_MINADBD` 不可靠 |
| 2026-10-10 | 移除 new minadbd，整合 v2 | 54 秒 ADB，解密和服务全通过 | 当前推荐版 |

## 1. 只改 fstab 无法解密

现象：

```text
Keymaster_Ver::Using keymaster version '' for decryption
Unable to mount '/data'
Failed to mount '/data' (Invalid argument)
```

原因：完整 FBE/wrapped key 需要 TEE 服务和用户凭证解密，不只是 mount option。

教训：fstab 是必要条件，不是充分条件。

## 2. v17 keystore interface 覆盖导致等待

改动：

```rc
interface aidl android.system.keystore2.IKeystoreService/default
```

现象：

- 第一屏卡住。
- recovery 主进程 futex wait。
- keystore2 进程存在但 interface 不注册。

结论：服务存在不等于服务可用。VINTF/interface 声明必须与实际实现和启动时序一致。

## 3. v18-v23 广撒网无效

| 变体 | 假设 | 结果 |
|---|---|---|
| v18 | keystore2 延后 | 失败 |
| v19 | keystore 用户权限 | 失败 |
| v20 | `ice,wrappedkey` 旧参数 | 失败 |
| v21 | additional fstab | 失败 |
| v22 | 官方 OS 版本/补丁级别 | 失败 |
| v23 | v18 + v22 | 失败 |

教训：当多个系统性假设都失败时，应寻找完整可运行参考实现，而不是继续增加排列组合。

## 4. stale ramdisk 污染

曾有一个 rtyu 构建产物仍然包含 v17 interface 覆盖。源码替换不等于输出干净，旧 product output 可能残留。

处理：

- 备份旧设备树。
- 整体替换 upstream 树。
- 删除 `out/target/product/OP64D3L1` 后 clean build。
- 用 `magiskboot` 检查最终 cpio。

原则：以打包产物为准，不以编辑器状态为准。

## 5. source 可执行位与 cpio mode 不一致

源码中多个脚本/二进制是 `0644`。Android 构建会归一化到 recovery root 的 `0755`，但肉眼检查源码会误判。

处理：发布前必须检查 cpio：

```text
-rwxr-xr-x system/bin/prepdecrypt.sh
-rwxr-xr-x vendor/bin/hw/android.hardware.security.keymint-service-qti
```

## 6. 第一屏不一定是死机

rtyu 原版约 77 秒完成启动/解密，整合 v2 约 54 秒。早期 10-20 秒的“卡第一屏”不能作为失败结论。

## 7. task_profiles.json 构建竞态

clean build 91% 时 copy 目标尚未生成，Ninja 之后才开始构建该 prebuilt。显式预构建目标解决。已固化到构建脚本。

## 8. TW_USE_NEW_MINADBD 冷启动风险

整合 v1 加入：

```make
TW_USE_NEW_MINADBD := true
```

首次启动 150 秒无 USB/ADB/fastboot。手动重启后 ADB 可用且解密正常，但该行为不可接受。

处理：

- 回滚 rtyu 原版。
- v2 移除该开关。
- v2 从 fastboot 直进 recovery，54 秒 ADB 出现并保持在线。

规则：USB 连接是最高优先级验收项，不能为了新 adbd 功能牺牲回滚能力。

## 9. 解密成功前后目录不同

解密前 `/data/media` 下可能看到无意义加密名。输入 PIN 后必须检查：

```text
twrp.user.0.decrypt=1
/data/media/0
```

只看 `crypto.ready=1` 不够。

## 10. touch-aidl 显示 restarting

当前触控可用，但服务状态可能显示 `restarting`。暂不阻塞发布。后续应采集：

```bash
adb shell 'getprop init.svc.touch-aidl'
adb shell 'ps -A | grep touch'
adb shell 'grep -i touch /tmp/recovery.log'
```

再对比 ODM 挂载和 VINTF 状态。

## 11. 数据安全

所有实验遵守：

- 不 wipe `/data`。
- 不 format `/data`。
- 不修改 userdata 分区表。
- 只刷 recovery 分区。
- 保留本地和 Release 回滚镜像。

## 12. 增量构建的 odm/firmware 形态冲突

尝试用 `CLEAN=0` 做构建脚本烟测时失败：

```text
could not make way for new symlink: root/odm/firmware
cannot delete non-empty directory: root/odm/firmware
```

原因：旧 target output 中 `recovery/root/odm/firmware` 的目录/符号链接形态与当前设备树不一致，rsync restage 无法安全替换。

处理：构建脚本始终删除 `out/target/product/OP64D3L1`。这同时降低 stale ramdisk 和 v17 覆盖残留风险。
