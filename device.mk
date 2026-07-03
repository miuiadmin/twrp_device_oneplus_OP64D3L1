#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Configure base.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Configure core_64_bit_only.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Configure virtual_ab compression.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)

# Configure emulated_storage.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Configure twrp common.mk
$(call inherit-product, vendor/twrp/config/common.mk)

# Shipping/vendor API level observed from stock PLY110_16.0.8.300(CN01).
BOARD_SHIPPING_API_LEVEL    := 34
PRODUCT_SHIPPING_API_LEVEL  := 34
PRODUCT_TARGET_VNDK_VERSION := 34

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION  := false

# Kernel
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS   := false
PRODUCT_ENABLE_UFFD_GC                          := true

# Recovery root files
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery.fstab:recovery/root/system/etc/recovery.fstab \
    $(DEVICE_PATH)/recovery/root/system/etc/twrp.flags:recovery/root/system/etc/twrp.flags \
    $(DEVICE_PATH)/recovery/root/init.recovery.qcom.rc:recovery/root/init.recovery.qcom.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.usb.rc:recovery/root/init.recovery.usb.rc \
    $(DEVICE_PATH)/recovery/root/ueventd.qcom.rc:recovery/root/ueventd.qcom.rc \
    $(DEVICE_PATH)/recovery/root/system/bin/twrp-touch-hal-init.sh:recovery/root/system/bin/twrp-touch-hal-init.sh \
    $(DEVICE_PATH)/recovery/root/vendor/manifest.xml:recovery/root/vendor/manifest.xml

# USB in recovery
PRODUCT_PROPERTY_OVERRIDES += \
    ro.recovery.usb.vid=18D1 \
    ro.recovery.usb.adb.pid=D001 \
    ro.recovery.usb.fastboot.pid=4EE0 \
    persist.sys.usb.config=adb

# OTA certs
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(DEVICE_PATH)/security/local_OTA \
    $(DEVICE_PATH)/security/special_OTA

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)
