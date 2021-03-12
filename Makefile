export ARCHS = arm64 arm64e

export DEBUG=0
export FINALPACKAGE=1

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ADockX

ADockX_FILES = $(wildcard *.x) $(wildcard *.m) $(wildcard *.xm)
ADockX_CFLAGS = -fobjc-arc
ADockX_LIBRARIES = rocketbootstrap sparkcolourpicker
ADockX_PRIVATE_FRAMEWORKS = AppSupport Preferences
ADockX_LDFLAGS = -Wl,-U,_showCopypastaWithNotification

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += dockxprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
