ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DockXPrefs

DockXPrefs_FILES = $(wildcard *.m) $(wildcard *.mm) ../PrefsManager.x ../ShortcutsGenerator.x ../DockXHelper.x
DockXPrefs_INSTALL_PATH = /Library/PreferenceBundles
DockXPrefs_FRAMEWORKS = UIKit
DockXPrefs_PRIVATE_FRAMEWORKS = Preferences AppSupport
DockXPrefs_CFLAGS = -fobjc-arc
DockXPrefs_LIBRARIES = rocketbootstrap colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DockXPrefs.plist$(ECHO_END)
