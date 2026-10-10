# /data 解密算法与设计

## 加密形态

官方 userdata 是 FBE v2 + metadata encryption + inlinecrypt + wrapped key：

```text
contents encryption: aes-256-xts
filenames encryption: aes-256-cts:v2
inlinecrypt_optimized
wrappedkey_v0
metadata encryption: aes-256-xts:wrappedkey_v0
key directory: /metadata/vold/metadata_encryption
```

这意味着只改 `TW_INCLUDE_CRYPTO` 或只补 fstab 参数不可能完成解密。TWRP 必须能访问硬件信任服务，并解开用户 synthetic password。

## 错误方向：直接补 keystore2 interface

v17 在设备树中加入了：

```rc
interface aidl android.system.keystore2.IKeystoreService/default
```

现象：

- 刷入后长时间停在第一屏。
- TWRP 主进程等待在 `futex_wait_queue`。
- `keystore2` 进程存在，但没有注册目标 interface。
- v18-v23 继续调整启动时间、用户、fstab 旧参数、平台版本等，均未解决。

结论：缺 interface 声明是表象。真正卡住的是 recovery 中 QSEE/Gatekeeper/KeyMint 时序和信任链没有就绪。手动把声明加到 `keystore2.rc` 只会让服务管理器等待一个永远不会完成的注册。

该错误覆盖已从当前树移除。base TWRP 源码自己的 `keystore2.rc` 保留，设备树不再覆盖它。

## 正确算法：prepdecrypt 触发 Qualcomm 安全链

### 1. fstab 声明加密形态

`recovery/root/system/etc/recovery.fstab` 的 `/data` 条目携带完整官方参数，TWRP 识别为 metadata encrypted data。

### 2. post-fs-data 启动 prepdecrypt

`init.recovery.qcom_decrypt.rc`：

```rc
on init
    chmod 0755 /system/bin/prepdecrypt.sh

service prepdecrypt /system/bin/prepdecrypt.sh
    oneshot
    disabled
    user root
    seclabel u:r:recovery:s0

on post-fs-data
    start prepdecrypt
```

### 3. prepdecrypt 挂载 persist 并发布 ready 标记

`prepdecrypt.sh` 的核心流程：

```sh
mkdir /mnt/vendor/persist
mount -t ext4 /dev/block/by-name/persist /mnt/vendor/persist
mkdir /persist
mkdir /persist/TWRP/
cp /system/bin/twrp_settings /persist/TWRP/.twrp_settings
setprop crypto.ready 1
```

`twrp_settings` 不是普通配置文件。它被放到 persist 下的固定位置，供 TWRP/解密组件读取恢复设置和状态。

### 4. crypto.ready 触发 Gatekeeper 与 KeyMint

```rc
on property:crypto.ready=1
    start vendor.gatekeeper_default
    start vendor.keymint-qti
```

### 5. QSEE 提供硬件信任服务

ramdisk 内置：

- `vendor/bin/qseecomd`
- `vendor.qti.hardware.qseecom@1.0-service`
- QSEECom API 库
- KeyMint / Gatekeeper service 和私有库
- RPMB / SPSS / TEE 相关依赖

### 6. TWRP 解 synthetic password

日志中的关键路径：

```text
Attempting to decrypt user
Attempting to decrypt user's synthetic password
using secdis to decrypt spblob
GateKeeper status ok
User 0 Decrypted Successfully!
```

### 7. 存储路径切换

解密前：

```text
/data/media
```

解密后：

```text
/data/media/0
```

随后 MTP 添加 `/data/media/0` 为内部存储。

## 算法伪代码

```text
if recovery.post_fs_data:
    mount persist
    install twrp_settings
    crypto.ready = 1

if crypto.ready:
    start QSEE dependencies
    start Gatekeeper
    start KeyMint

when TWRP requires credential:
    show PIN page
    derive credential secret
    secdis decrypt spblob
    Gatekeeper verifies / supplies device secret
    KeyMint supplies key operations
    unwrap FBE keys
    map userdata to /dev/block/mapper/userdata
    mount /data
    switch storage to /data/media/0
```

## 成功证据

必须同时满足：

```text
crypto.ready=1
init.svc.vendor.qseecomd=running
init.svc.vendor.keymint-qti=running
init.svc.vendor.gatekeeper_default=running
twrp.user.0.decrypt=1
```

日志：

```text
I:Successfully decrypted metadata encrypted data partition with new block device: '/dev/block/mapper/userdata'
User 0 Decrypted Successfully!
I:New storage path after decryption: /data/media/0
```

文件系统：

```text
/dev/block/dm-25 on /data type f2fs (rw,...,inlinecrypt,...)
```

用户存储必须看到 `Download`、`DCIM`、`Pictures` 等明文目录。
