################################################################################
#
# Batocera Emulation Station
#
################################################################################

RETROPIE_EMULATIONSTATION_VERSION = 8878cb0b4c2865ff28abaacec12f31507c18c1d5
RETROPIE_EMULATIONSTATION_SITE = https://github.com/RetroPie/EmulationStation
RETROPIE_EMULATIONSTATION_SITE_METHOD = git
RETROPIE_EMULATIONSTATION_GIT_SUBMODULES = YES
RETROPIE_EMULATIONSTATION_LICENSE = MIT
RETROPIE_EMULATIONSTATION_DEPENDENCIES = sdl2 sdl2_mixer boost libfreeimage freetype eigen alsa-lib \
	libcurl openssl vlc rapidjson

# ifeq ($(BR2_PACKAGE_KODI),y)
# 	RETROPIE_EMULATIONSTATION_CONF_OPTS += -DDISABLE_KODI=0
# else
# 	RETROPIE_EMULATIONSTATION_CONF_OPTS += -DDISABLE_KODI=1
# endif

# ifeq ($(BR2_PACKAGE_XORG7),y)
# 	BATOCERA_EMULATIONSTATION_CONF_OPTS += -DENABLE_FILEMANAGER=1
# else
# 	BATOCERA_EMULATIONSTATION_CONF_OPTS += -DENABLE_FILEMANAGER=0
# endif

ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
	RETROPIE_EMULATIONSTATION_DEPENDENCIES += libgl
endif

ifeq ($(BR2_PACKAGE_HAS_LIBGLES),y)
	RETROPIE_EMULATIONSTATION_DEPENDENCIES += libgles
endif

define RETROPIE_EMULATIONSTATION_RPI_FIXUP
	$(SED) 's|/opt/vc/include|$(STAGING_DIR)/usr/include|g' $(@D)/CMakeLists.txt
	$(SED) 's|/opt/vc/lib|$(STAGING_DIR)/usr/lib|g' $(@D)/CMakeLists.txt
	$(SED) 's|/usr/lib|$(STAGING_DIR)/usr/lib|g' $(@D)/CMakeLists.txt
endef

define RETROPIE_EMULATIONSTATION_RESOURCES
	$(INSTALL) -m 0755 -d $(TARGET_DIR)/usr/share/batocera/datainit/system/.emulationstation/resources/help
	$(INSTALL) -m 0644 -D $(@D)/resources/*.* $(TARGET_DIR)/usr/share/batocera/datainit/system/.emulationstation/resources
	$(INSTALL) -m 0644 -D $(@D)/resources/help/*.* $(TARGET_DIR)/usr/share/batocera/datainit/system/.emulationstation/resources/help
endef

RETROPIE_EMULATIONSTATION_PRE_CONFIGURE_HOOKS += RETROPIE_EMULATIONSTATION_RPI_FIXUP
RETROPIE_EMULATIONSTATION_POST_INSTALL_TARGET_HOOKS += RETROPIE_EMULATIONSTATION_RESOURCES

$(eval $(cmake-package))
