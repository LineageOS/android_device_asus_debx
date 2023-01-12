#
# Copyright 2013 The Android Open-Source Project
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from flox
$(call inherit-product, device/asus/flox/device-common.mk)

# Inherit the proprietary files
$(call inherit-product, vendor/asus/debx/debx-vendor.mk)

# Camera
PRODUCT_PACKAGES += \
    camera.debx

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    device/asus/debx/overlay \
    device/asus/flox/overlay-lineage

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml

# Ramdisk
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.debx:$(TARGET_COPY_OUT_RAMDISK)/fstab.flox \
    $(LOCAL_PATH)/rootdir/etc/fstab.debx:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.flox

# Rild
PRODUCT_PACKAGES += \
    rild \
    CarrierConfig \
    BasicSmsReceiver

# Wifi
PRODUCT_PACKAGES += \
    hostapd_default.conf
