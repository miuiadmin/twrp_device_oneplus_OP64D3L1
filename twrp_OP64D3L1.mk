#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oneplus/OP64D3L1

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier
PRODUCT_DEVICE          := OP64D3L1
PRODUCT_NAME            := twrp_OP64D3L1
PRODUCT_BRAND           := OnePlus
PRODUCT_MANUFACTURER    := OnePlus
PRODUCT_MODEL           := PLY110
PRODUCT_RELEASE_NAME    := OnePlus_Turbo_6V

# Theme
TW_STATUS_ICONS_ALIGN   := center
TW_Y_OFFSET             := 111
TW_H_OFFSET             := -111
