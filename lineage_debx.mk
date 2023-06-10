#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit applicable common Lineage product configuration
$(call inherit-product, vendor/lineage/config/common_mini_tablet_wifionly.mk)

# Inherit Lineage telephony configuration
$(call inherit-product, vendor/lineage/config/telephony.mk)

# Inherit common AOSP configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit device-specific configuration
$(call inherit-product, $(LOCAL_PATH)/device.mk)

# Shipping API
$(call inherit-product, vendor/lineage/build/target/product/product_launched_with_j_mr2.mk)

## Device identifiers - These must come after all inclusions
PRODUCT_BRAND := google
PRODUCT_DEVICE := debx
PRODUCT_MANUFACTURER := asus
PRODUCT_MODEL := Nexus 7
PRODUCT_NAME := lineage_debx

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=razorg \
    PRIVATE_BUILD_DESC="razorg-user 6.0.1 MOB30X 3036618 release-keys"

BUILD_FINGERPRINT := google/razorg/deb:6.0.1/MOB30X/3036618:user/release-keys
