# /data 解密实验记录

## 当前结论

v0.0.1 稳定版为了优先解决启动、触控和 UI 卡顿，关闭了 userdata 解密：

- `BoardConfig.mk` 使用 `TW_EXCLUDE_CRYPTO := true`
- 根 `recovery.fstab` 的 `/data` 条目没有带官方 `fileencryption` 和 `metadata_encryption` 参数
- recovery ramdisk 中缺少 KeyMint/Gatekeeper/qseecomd 运行文件
- `/vendor/manifest.xml` 只有 OPlus touch HAL，没有安全 HAL 声明

当前 TWRP 日志中的关键错误：

```text
I:FBE contents 'aes-256-xts', filenames 'aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0'
I:setting Key_Directory to: /metadata/vold/metadata_encryption
I:Metadata contents 'aes-256-xts', filenames 'wrappedkey_v0'
I:Unable to find vendor manifest on the device, and no default value set. Checking the ramdisk manifest
I:Keymaster_Ver::Using keymaster version '' for decryption
I:Unable to mount '/data'
Failed to mount '/data' (Invalid argument)
```

所以 `/data` 解密的下一步不是只改 fstab，而是让 TWRP 能启动并发现安全 HAL。

## 官方 /data 加密参数

来自 `PLY110_16.0.8.300(CN01)_0370` 官方 fstab：

```text
fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0
keydirectory=/metadata/vold/metadata_encryption
metadata_encryption=aes-256-xts:wrappedkey_v0
```

## 实验补丁内容

- 打开 TWRP crypto/FBE：
  - `TW_INCLUDE_CRYPTO := true`
  - `TW_INCLUDE_FBE := true`
  - `TW_INCLUDE_FBE_METADATA_DECRYPT := true`
  - `TW_USE_FSCRYPT_POLICY := 2`
  - `TW_INCLUDE_OMAPI := true`
- 根 `recovery.fstab` 恢复官方 `/data` 加密参数。
- 补齐 KeyMint/Gatekeeper/qseecomd/ssgtzd 服务文件和 vendor 私有库。
- 在 `/vendor/manifest.xml` 和 `/vendor/etc/vintf/manifest.xml` 声明：
  - `android.hardware.gatekeeper`
  - `android.hardware.security.keymint`
  - `android.hardware.security.secureclock`
  - `android.hardware.security.sharedsecret`
  - `vendor.oplus.hardware.touch`
- `init.recovery.qcom.rc` 在 recovery init 阶段启动 `vendor.qseecomd`、`vendor.keymint-qti`、`vendor.gatekeeper_default`。

## 刷测验收

刷入实验镜像后，先不要格式化 data，按下面顺序查：

```bash
adb shell getprop init.svc.vendor.qseecomd
adb shell getprop init.svc.vendor.keymint-qti
adb shell getprop init.svc.vendor.gatekeeper_default
adb shell grep -iE "keymint|gatekeeper|keymaster|decrypt|fscrypt|metadata|Unable to mount|Failed to mount" /tmp/recovery.log
adb shell mount | grep " /data "
adb shell ls /data/media/0
```

成功标准：

- KeyMint/Gatekeeper 服务状态是 `running`
- recovery 日志里不再出现 `keymaster_ver=` 空值
- 输入锁屏密码/PIN 后，`/data/media/0` 能列出用户文件

如果仍然卡启动或解密失败，优先回查：

- `vendor.keymint-qti` 是否缺库或崩溃
- `/vendor/manifest.xml` 是否被识别
- `qseecomd` 是否成功访问 QSEE/RPMB
- 是否需要去掉 `ssgtzd`，只保留 qseecomd/keymint/gatekeeper 的最小链路
