#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oneplus/OP64D3L1

# Building with minimal manifest
ALLOW_MISSING_DEPENDENCIES                      := true
BUILD_BROKEN_DUP_RULES                          := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES    := true

BUILD_BROKEN_NINJA_USES_ENV_VARS    += RTIC_MPGEN
BUILD_BROKEN_PLUGIN_VALIDATION      := soong-libaosprecovery_defaults soong-libguitwrp_defaults soong-libminuitwrp_defaults soong-vold_defaults

# Architecture
TARGET_ARCH                 := arm64
TARGET_ARCH_VARIANT         := armv8-a
TARGET_CPU_ABI              := arm64-v8a
TARGET_CPU_VARIANT          := kryo
TARGET_CPU_VARIANT_RUNTIME  := kryo
TARGET_USES_64_BIT_BINDER   := true

# A/B
AB_OTA_PARTITIONS := \
    boot \
    init_boot \
    vendor_boot \
    recovery \
    dtbo \
    odm \
    product \
    system \
    system_ext \
    system_dlkm \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_dlkm

# A/B dynamic partitions for OPlus
AB_OTA_PARTITIONS += \
    my_bigball \
    my_carrier \
    my_company \
    my_engineering \
    my_heytap \
    my_manifest \
    my_preload \
    my_product \
    my_region \
    my_stock

# Bootloader/platform
BOARD_VENDOR                    := oneplus
PRODUCT_PLATFORM                := volcano
TARGET_BOARD_PLATFORM           := volcano
TARGET_BOOTLOADER_BOARD_NAME    := volcano
TARGET_OTA_ASSERT_DEVICE        := OP64D3L1,PLY110,pineapple
QCOM_BOARD_PLATFORMS            += volcano

# Crypto
# OPlus Android 16 FBE/KeyMint currently hangs this target at the TWRP splash.
# Keep metadata visible, but skip userdata decryption for the first bootable build.
BOARD_USES_METADATA_PARTITION       := true
TW_EXCLUDE_CRYPTO                   := true

# Debug
TARGET_USES_LOGD                := true
TWRP_INCLUDE_LOGCAT             := true
TARGET_RECOVERY_DEVICE_MODULES  += debuggerd
TARGET_RECOVERY_DEVICE_MODULES  += strace
RECOVERY_BINARY_SOURCE_FILES    += $(TARGET_OUT_EXECUTABLES)/debuggerd
RECOVERY_BINARY_SOURCE_FILES    += $(TARGET_OUT_EXECUTABLES)/strace

# File systems
TARGET_USERIMAGES_USE_F2FS := true
TW_USE_DMCTL               := true

# Init
TARGET_INIT_VENDOR_LIB          := //$(DEVICE_PATH):libinit_oplus_op64d3l1
TARGET_RECOVERY_DEVICE_MODULES  += libinit_oplus_op64d3l1

# Kernel/recovery image layout. Stock recovery.img is boot image v4,
# lz4 ramdisk-only, without an embedded kernel payload.
BOARD_KERNEL_IMAGE_NAME                 := Image
BOARD_BOOT_HEADER_VERSION               := 4
BOARD_KERNEL_PAGESIZE                   := 4096
BOARD_FLASH_BLOCK_SIZE                  := 262144
BOARD_MKBOOTIMG_ARGS                    += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS                    += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_RAMDISK_USE_LZ4                   := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

# Partitions
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED  := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE      := 0x6400000
BOARD_BOOTIMAGE_PARTITION_SIZE          := 100663296
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE    := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE   := 100663296
BOARD_DTBOIMG_PARTITION_SIZE            := 25165824
BOARD_VBMETAIMAGE_PARTITION_SIZE        := 65536

BOARD_SUPER_PARTITION_SIZE                  := 16508780544
BOARD_SUPER_PARTITION_GROUPS                := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE           := 16441671680
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext system_dlkm product vendor vendor_dlkm odm
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST += my_bigball my_carrier my_company my_engineering my_heytap my_manifest my_preload my_product my_region my_stock

BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_ODM             := odm
TARGET_COPY_OUT_VENDOR          := vendor

# Recovery
TARGET_RECOVERY_FSTAB                       := $(DEVICE_PATH)/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT                := RGBX_8888
TW_INCLUDE_FASTBOOTD                        := true

# Tool
TW_ENABLE_ALL_PARTITION_TOOLS := true
TW_INCLUDE_7ZA                := true
TW_INCLUDE_REPACKTOOLS        := true
TW_INCLUDE_RESETPROP          := true
TW_USE_NEW_MINADBD            := true
TW_USE_TOOLBOX                := true
TW_INCLUDE_ZSTD               := true

# TWRP display
TW_BRIGHTNESS_PATH      := /sys/class/backlight/panel0-backlight/brightness
TW_DEFAULT_BRIGHTNESS   := 1638
TW_FRAMERATE            := 60
TW_MAX_BRIGHTNESS       := 4094
TW_THEME                := portrait_hdpi

# TWRP file system
RECOVERY_SDCARD_ON_DATA     := true
TARGET_USES_MKE2FS          := true
TW_ENABLE_FS_COMPRESSION    := true
TW_INCLUDE_FUSE_EXFAT       := true
TW_INCLUDE_FUSE_NTFS        := true
TW_INCLUDE_NTFS_3G          := true
TW_NO_EXFAT_FUSE            := true
TW_DEFAULT_LANGUAGE         := zh_CN

# Version
PLATFORM_VERSION                := 99.87.36
PLATFORM_VERSION_LAST_STABLE    := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH         := 2099-12-31
VENDOR_SECURITY_PATCH           := $(PLATFORM_SECURITY_PATCH)
TW_DEVICE_VERSION               := OnePlus_Turbo_6V_nodecrypt

# Verified Boot
BOARD_AVB_ENABLE := true

# Vibrator
TW_NO_HAPTICS := true

# Other TWRP configurations
TARGET_RECOVERY_QCOM_RTC_FIX            := true
TW_CUSTOM_CPU_TEMP_PATH                 := "/sys/class/thermal/thermal_zone45/temp"
TW_EXCLUDE_APEX                         := true
TW_EXCLUDE_DEFAULT_USB_INIT             := true
TW_EXTRA_LANGUAGES                      := true
TW_NO_SCREEN_BLANK                      := true
TW_NO_SCREEN_TIMEOUT                    := true
TW_LOAD_VENDOR_MODULES                  := "adsp_loader_dlkm.ko stm_st54se_gpio.ko nxp-nci.ko"
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI      := true
TW_NO_NETWORK                           := true
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID  := true
