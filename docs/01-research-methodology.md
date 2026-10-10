# 研究方法论

## 目标

在 OnePlus Turbo 6V 上获得一个同时满足以下条件的 TWRP：

1. 能稳定进入 GUI，不卡第一屏。
2. 触控延迟可接受。
3. 能解 FBE v2 + inlinecrypt + wrapped key + metadata encryption 的 `/data`。
4. 能访问 `/data/media/0` 和 MTP。
5. 保留 A/B 槽位切换、WiFi、震动、电池信息等实用功能。
6. 构建和回滚过程可复现，不依赖某一次手工状态。

## 基本约束

- `/data` 只读验证，不wipe、不format、不resize。
- 每轮测试前保留一个已知可启动镜像。
- recovery 分区同时刷 `recovery_a` 和 `recovery_b`，避免槽位差异干扰结论。
- 电脑无法看到设备时不立即判定变砖，先区分：
  - recovery 仍在启动/解密；
  - USB/adbd 未启动；
  - 真正卡死需要强制重启。
- 解密测试至少等待 90 秒。实测 rtyu 原版约 77 秒，整合 v2 约 54 秒。

## 变量控制

每次只改变一个主变量：

- 启动顺序：qseecomd -> KeyMint -> Gatekeeper -> keystore2。
- VINTF 声明与 service contexts。
- fstab 加密参数。
- APEX / 平台版本 / security patch。
- adbd 实现。
- WiFi、震动、电池等外设服务单独验证，不和解密变量混在一起。

失败时记录四类信息：

1. `adb devices` / `fastboot devices`。
2. `getprop init.svc.*`。
3. `/tmp/recovery.log` 中服务启动和解密段落。
4. 打包 ramdisk 中的实际文件、mode 和 RC 内容。

## 验收门禁

### 静态门禁

- 镜像大小必须为 `104857600` 字节。
- `prepdecrypt.sh`、KeyMint、Gatekeeper、qseecomd、boot HAL、vibrator、wpa_supplicant 必须存在。
- 关键可执行文件在 cpio 中必须是 `-rwxr-xr-x`。
- `init.recovery.qcom_decrypt.rc` 必须存在 `post-fs-data -> prepdecrypt -> crypto.ready=1` 链路。
- 设备树不得包含 v17 风格 `interface aidl android.system.keystore2.IKeystoreService/default` 覆盖。
- 本地增强 `7za`、`zstd` 必须实际进入 ramdisk。

### 动态门禁

- ADB 在 120 秒内出现并保持在线。
- `crypto.ready=1`。
- `vendor.qseecomd`、`vendor.keymint-qti`、`vendor.gatekeeper_default` 均为 `running`。
- 输入锁屏 PIN 后 `twrp.user.0.decrypt=1`。
- `/data/media/0` 显示明文目录，而不是加密文件名。
- MTP 能添加 `/data/media/0`。
- WiFi、boot HAL、vibrator、health 服务运行。

## 方法论复盘

早期失败的主要原因是把问题当成“缺一个声明/缺一个库”的静态问题处理。实际_recovery 解密是时序问题：`persist`、QSEE、Gatekeeper、KeyMint、synthetic password 和 TWRP 解密页必须按正确顺序就绪。

rtyutechstudio 的关键贡献是提供了一个已经跑通的 Qualcomm 时序算法。我们不是继续堆 VINTF 假设，而是整体吸收该链路，再用本地触控和工具增强叠加，最后通过真机回归验证。
