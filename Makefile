TARGET := iphone:clang:14.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TrustOverride

TrustOverride_FILES = Tweak.x
TrustOverride_CFLAGS = -fobjc-arc
TrustOverride_PRIVATE_FRAMEWORKS = FrontBoardServices
TrustOverride_EXTRA_FRAMEWORKS = AltList

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += TrustOverridePrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
