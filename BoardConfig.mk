#
# Copyright (C) 2011 The Android Open-Source Project
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Inherit from flox
include device/asus/flox/BoardConfigCommon.mk

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := deb
TARGET_BOOTLOADER_NAME := deb
TARGET_BOARD_INFO_FILE := device/asus/debx/board-info.txt

# Properties
TARGET_SYSTEM_PROP := \
    device/asus/flox/system.prop \
    device/asus/debx/system.prop

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := device/asus/debx

# Recovery
TARGET_RECOVERY_FSTAB = device/asus/debx/rootdir/etc/fstab.debx

# Sepolicy
BOARD_SEPOLICY_DIRS += device/asus/debx/sepolicy

# Inherit the proprietary files
include vendor/asus/debx/BoardConfigVendor.mk