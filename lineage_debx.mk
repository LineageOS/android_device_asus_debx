# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_mini_tablet_wifionly.mk)

# Inherit telephony stuff
$(call inherit-product, vendor/lineage/config/telephony.mk)

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit device configuration
$(call inherit-product, device/asus/debx/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := debx
PRODUCT_NAME := lineage_debx
PRODUCT_BRAND := google
PRODUCT_MODEL := Nexus 7
PRODUCT_MANUFACTURER := asus

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=razorg \
    PRIVATE_BUILD_DESC="razorg-user 6.0.1 MOB30X 3036618 release-keys"

BUILD_FINGERPRINT := google/razorg/deb:6.0.1/MOB30X/3036618:user/release-keys