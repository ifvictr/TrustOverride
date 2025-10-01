TARGET := iphone:clang:14.5:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TrustOverridePrefs

TrustOverridePrefs_FILES = TORootListController.m
TrustOverridePrefs_FRAMEWORKS = UIKit
TrustOverridePrefs_PRIVATE_FRAMEWORKS = Preferences
TrustOverridePrefs_INSTALL_PATH = /Library/PreferenceBundles
TrustOverridePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
