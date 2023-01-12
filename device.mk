#
# Copyright 2013 The Android Open-Source Project
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# rild
PRODUCT_PACKAGES := \
    rild \
    CarrierConfig \
    BasicSmsReceiver

# Features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml

# Camera
PRODUCT_PACKAGES += \
    camera.debx

PRODUCT_PACKAGES += \
    hostapd_default.conf

# the actual meat of the device-specific product definition
$(call inherit-product, device/asus/flox/device-common.mk)

# inherit from the non-open-source side, if present
$(call inherit-product-if-exists, vendor/asus/debx/debx-vendor.mk)

DEVICE_PACKAGE_OVERLAYS += \
    device/asus/debx/overlay \
    device/asus/flox/overlay-lineage

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.debx:$(TARGET_COPY_OUT_RAMDISK)/fstab.flox \
    $(LOCAL_PATH)/rootdir/etc/fstab.debx:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.flox
