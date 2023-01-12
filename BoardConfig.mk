#
# Copyright (C) 2011 The Android Open-Source Project
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

TARGET_BOOTLOADER_BOARD_NAME := deb
TARGET_BOOTLOADER_NAME := deb
TARGET_BOARD_INFO_FILE := device/asus/debx/board-info.txt

TARGET_RELEASETOOLS_EXTENSIONS := device/asus/debx

TARGET_SYSTEM_PROP += \
    device/asus/flox/system.prop \
    device/asus/debx/system.prop

TARGET_RECOVERY_FSTAB = device/asus/debx/rootdir/etc/fstab.debx

BOARD_SEPOLICY_DIRS += device/asus/debx/sepolicy

-include vendor/asus/debx/BoardConfigVendor.mk
include device/asus/flox/BoardConfigCommon.mk
