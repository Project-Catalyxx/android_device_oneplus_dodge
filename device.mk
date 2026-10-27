#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxxhdpi

# Alert slider, and Oscar's Device Settings (hardware/oplus/packages/DeviceSettings;
# its KeyHandler takes the slider over from hardware/oplus's: overlay-lineage/lineage-sdk)
PRODUCT_PACKAGES += \
    DeviceSettings \
    tri-state-key-calibrate

# Audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_sun/audio_effects_config.xml \
    $(LOCAL_PATH)/configs/audio/audio_module_config_primary.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/audio_module_config_primary.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    $(LOCAL_PATH)/configs/audio/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml

# Boot animation
TARGET_SCREEN_HEIGHT := 3168
TARGET_SCREEN_WIDTH := 1440

# Display
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/display/displayconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630946756802996883.xml

# LiveDisplay
$(call soong_config_set_bool,OPLUS_LINEAGE_LIVEDISPLAY_HAL,ENABLE_AF,true)

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_PACKAGES += \
    EuiccPolicyResTarget \
    FrameworksResTargetEuicc \
    OPlusFrameworksResTarget \
    OPlusSettingsProviderResTarget \
    OPlusSettingsResTarget \
    OPlusSystemUIResTarget

# Media: sm8750-common's codec2 audio list plus the Dolby AC3/E-AC3/E-AC3-JOC
# decoders. Listed here, ahead of the common makefile's inherit, so this copy
# is the one installed.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media/media_codecs_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2_audio.xml

# NFC
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/nfc/libnfc-mtp-SN220.conf_23821:$(TARGET_COPY_OUT_ODM)/etc/libnfc-mtp-SN220.conf_23821 \
    $(LOCAL_PATH)/configs/nfc/libnfc-mtp-SN220.conf_23893:$(TARGET_COPY_OUT_ODM)/etc/libnfc-mtp-SN220.conf_23893 \
    $(LOCAL_PATH)/configs/nfc/libnfc-nci.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-nci.conf

# PowerShare
PRODUCT_PACKAGES += \
    vendor.lineage.powershare-service.oplus

# Regional properties
REGIONAL_PROP_FILES := $(wildcard $(LOCAL_PATH)/properties/*/*.prop)

PRODUCT_COPY_FILES += $(foreach f,$(REGIONAL_PROP_FILES), \
    $(f):$(TARGET_COPY_OUT_ODM)/etc/$(patsubst $(LOCAL_PATH)/properties/%,%,$(f)) \
    $(f):$(TARGET_COPY_OUT_RECOVERY)/root/vendor/odm/etc/$(patsubst $(LOCAL_PATH)/properties/%,%,$(f)))

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Telephony
PRODUCT_PACKAGES += \
    OplusEsimSwitcher \
    OplusEuicc

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.euicc.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.euicc.xml

# Touch features
$(call soong_config_set_bool,OPLUS_LINEAGE_TOUCH_HAL,ENABLE_GM,true)
$(call soong_config_set,OPLUS_LINEAGE_TOUCH_HAL,HTPR_ENABLE_NODE,REPORT_RATE_NODE)
$(call soong_config_set,OPLUS_LINEAGE_TOUCH_HAL,HTPR_ENABLE_VALUE,6)

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service.oplus

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

$(call soong_config_set_bool,OPLUS_LINEAGE_VIBRATOR_HAL,USE_EFFECT_STREAM,true)

# ProXDR / HDR photo pipeline.
#
# Read off stock CPH2653 16.0.9.402 with getprop; all four are absent here, which
# is why Gallery's ultra_hdr / local_hdr / hdr_vision_brighten / edr_listener
# feature checks stay false and photos render SDR even though the panel reports
# ro.surface_flinger.has_HDR_display=true.
#
# Note the panel advertises supportedHdrTypes=INVALID even on stock, so ProXDR
# does not ride the standard Android HDR types -- it is Oplus's own localhdr/uhdr
# path, gated purely on these props.
#
# Dolby Vision is deliberately NOT enabled here (stock also sets
# persist.sys.feature.dolby_vision{,_app} and ro.vendor.oplus.dolby_vision_dpu{,.dvs}).
# Dolby on this device is a separate, flash-verified port that lives on its own
# branch; turning the UI on without that backend just offers a broken toggle.
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.feature.hdr_vision_app=1 \
    persist.sys.feature.localhdr_version=2 \
    persist.sys.feature.uhdr.support=true \
    persist.sys.feature.support.edrlistener=true

# The camera's vendor public libraries: stock's list, which sm8750-common's
# vendor ships, plus the ArcSoft/QNN libraries OplusCamera dlopen()s and
# libapsfixup, an /odm lib that libAlgoProcess now needs and that the camera's
# namespace can't otherwise reach. On Rising this is a blob fixup in
# sm8750-common's extract-files.py; LineageOS's sm8750-common is unforked here.
# Like the 1080p120 override below, it has to come before the inherit it
# overrides (sm8750-common's): inherit-product's marker is expanded in place,
# and the first copy of a destination wins.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/linker/public.libraries.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt

# Inherit from the common OEM chipset makefile.
$(call inherit-product, device/oneplus/sm8750-common/common.mk)

# Real-time 1080p120: override the stock odm camera feature blob.
# This has to be declared *before* inheriting dodge-vendor.mk. inherit-product
# only appends an @inherit: marker that gets expanded after this file is parsed,
# so a filter-out here never sees (let alone removes) the vendor entries.
# Duplicate PRODUCT_COPY_FILES destinations are resolved first-one-wins, so
# listing ours ahead of the inherit is what actually makes the override stick.
#
# oplus_camera_config is deliberately NOT copied here any more. extract-files.py
# now decrypts it and sets the 120fps vendor tags directly on the vendor blob,
# and because this list wins first-one-wins, a static copy here would silently
# override those values with the older, narrower ones (main.only.support=1,
# zoom.range 1,3.5, max.zoom.list 1,2.9,10) and undo the patch.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/camera/camera_unit_feature_config.protobuf:$(TARGET_COPY_OUT_ODM)/etc/camera/config/camera_unit_feature_config.protobuf

# Inherit from the proprietary files makefile.
$(call inherit-product, vendor/oneplus/dodge/dodge-vendor.mk)

# Dolby Atmos (DAP) and the LunarisDolby app. Inherited makefiles are read
# after the common makefile's body, so its DEVICE_MANIFEST_FILE := cannot drop
# the HIDL fragments this one appends.
$(call inherit-product, vendor/oneplus/dolby/config.mk)

# Camera
$(call inherit-product-if-exists, vendor/oplus/camera/opluscamera.mk)
