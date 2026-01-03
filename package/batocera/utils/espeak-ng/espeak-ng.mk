################################################################################
#
# ESPEAK_NG
#
################################################################################

# Last release on Dec 12,2024
ESPEAK_NG_VERSION = 1.51.1
ESPEAK_NG_SITE = https://github.com/espeak-ng/espeak-ng.git
ESPEAK_NG_SITE_METHOD = git
ESPEAK_NG_GIT_VERSION = v$(ESPEAK_NG_VERSION)
ESPEAK_NG_LICENSE = GPL-3.0+, zlib
ESPEAK_NG_LICENSE_FILES = LICENSE.md src/zlib/LICENSE.zlib
ESPEAK_NG_AUTORECONF = YES

ESPEAK_NG_DEPENDENCIES = \
    pcre \
    libunistring \
    zlib \
    host-pkgconf

ESPEAK_NG_ADD_CFLAGS += -fPIC
ESPEAK_NG_ADD_CXXFLAGS += -fPIC

ESPEAK_NG_CONF_OPTS = \
    --disable-pulseaudio \
    --disable-mbrola \
    --disable-data-compilation

define ESPEAK_NG_CREATE_DUMMY_FILES
	touch $(@D)/AUTHORS
	touch $(@D)/NEWS
endef

define ESPEAK_NG_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) src/espeak-ng src/libespeak-ng.la
endef


ESPEAK_NG_QEMU_WRAPPER = $(HOST_DIR)/bin/qemu-x86_64 

# The QEMU sysroot is the entire staging dir
ESPEAK_NG_QEMU_SYSROOT = $(STAGING_DIR)

# The CORRECT path to the Buildroot dynamic linker (MUST be right, check lib/ or lib64!)
# Assuming lib64 based on previous path hints:
ESPEAK_NG_TARGET_LINKER = $(HOST_DIR)/x86_64-buildroot-linux-gnu/sysroot/lib/ld-linux-x86-64.so.2

# 2. Update POST_BUILD_DATA_COMPILATION
define ESPEAK_NG_POST_BUILD_DATA_COMPILATION
	# 1. Create the QEMU wrapper
	mv $(@D)/src/espeak-ng $(@D)/src/espeak-ng.bin
	echo '#!/bin/sh' > $(@D)/src/espeak-ng
	# Execute QEMU:
	# 1. -L $(STAGING_DIR) sets the library search root.
	# 2. $(TOOLCHAIN_LINKER) is the program to execute.
	# 3. $(TARGET_BINARY) is passed as the first argument to the linker.
	echo '$(ESPEAK_NG_QEMU_WRAPPER) -L $(ESPEAK_NG_QEMU_SYSROOT) $(ESPEAK_NG_TARGET_LINKER) $(@D)/src/espeak-ng.bin "$$@"' >> $(@D)/src/espeak-ng
	chmod +x $(@D)/src/espeak-ng

	# 2. Manually run the compilation.
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		ESPEAK_DATA_PATH="$(@D)"/espeak-ng-data \
		phsource/phonemes.stamp
endef



ESPEAK_NG_POST_EXTRACT_HOOKS += ESPEAK_NG_CREATE_DUMMY_FILES
ESPEAK_NG_POST_BUILD_HOOKS += ESPEAK_NG_POST_BUILD_DATA_COMPILATION

$(eval $(autotools-package))
