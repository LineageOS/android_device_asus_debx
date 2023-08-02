#
# Copyright (C) 2013 The Android Open-Source Project
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Common Configuration
$(call inherit-product, device/asus/flox/device-common.mk)

# Inherit Proprietary Configuration
$(call inherit-product, vendor/asus/debx/debx-vendor.mk)

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += \
    $(LOCAL_PATH)/overlay/packages/apps/Bluetooth

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml

# Ramdisk
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.debx:$(TARGET_COPY_OUT_RAMDISK)/fstab.flox \
    $(LOCAL_PATH)/rootdir/etc/fstab.debx:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.flox

# RIL
PRODUCT_PACKAGES += \
    CarrierConfig \
    BasicSmsReceiver \
    rild

# Soong
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Wi-Fi
PRODUCT_PACKAGES += \
    hostapd_default.conf
