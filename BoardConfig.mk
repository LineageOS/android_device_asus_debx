#
# Copyright (C) 2011 The Android Open-Source Project
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Common Configuration
include device/asus/flox/BoardConfigCommon.mk

# Inherit Proprietary Configurations
include vendor/asus/debx/BoardConfigVendor.mk

# Defined Paths
DEVICE_PATH := device/asus/debx

# Board Info
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := deb
TARGET_BOOTLOADER_NAME := deb

# Manifests
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Properties
TARGET_SYSTEM_PROP += \
    $(COMMON_PATH)/system.prop \
    $(DEVICE_PATH)/system.prop

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(DEVICE_PATH)

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.debx

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
