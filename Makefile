ARCHS = arm64 arm64e
DEBUG=0
FINALPACKAGE=1

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ADockX

ADockX_FILES = $(wildcard *.x) $(wildcard *.m) $(wildcard *.xm)
ADockX_CFLAGS = -fobjc-arc
ADockX_LIBRARIES = rocketbootstrap colorpicker
ADockX_PRIVATE_FRAMEWORKS = AppSupport Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += dockxprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
