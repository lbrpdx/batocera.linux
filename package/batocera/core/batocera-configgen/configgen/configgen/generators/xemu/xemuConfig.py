from __future__ import annotations

from typing import TYPE_CHECKING

from ...batoceraPaths import ensure_parents_and_open
from ...utils.configparser import CaseSensitiveConfigParser
from .xemuPaths import XEMU_CONFIG

if TYPE_CHECKING:
    from ...controller import ControllerMapping
    from ...Emulator import Emulator
    from ...types import Resolution


def writeIniFile(system: Emulator, rom: str, playersControllers: ControllerMapping, gameResolution: Resolution) -> None:
    iniConfig = CaseSensitiveConfigParser(interpolation=None)

    if XEMU_CONFIG.exists():
        try:
            iniConfig.read(XEMU_CONFIG, encoding='utf_8_sig')
        except:
            pass

    createXemuConfig(iniConfig, system, rom, playersControllers, gameResolution)
    # save the ini file
    with ensure_parents_and_open(XEMU_CONFIG, 'w') as configfile:
        iniConfig.write(configfile)

def createXemuConfig(iniConfig: CaseSensitiveConfigParser, system: Emulator, rom: str, playersControllers: ControllerMapping, gameResolution: Resolution) -> None:
    # Create INI sections
    if not iniConfig.has_section("general"):
        iniConfig.add_section("general")
    if not iniConfig.has_section("sys"):
        iniConfig.add_section("sys")
    if not iniConfig.has_section("sys.files"):
        iniConfig.add_section("sys.files")
    if not iniConfig.has_section("audio"):
        iniConfig.add_section("audio")
    if not iniConfig.has_section("display"):
        iniConfig.add_section("display")
    if not iniConfig.has_section("display.quality"):
        iniConfig.add_section("display.quality")
    if not iniConfig.has_section("display.window"):
        iniConfig.add_section("display.window")
    if not iniConfig.has_section("display.ui"):
        iniConfig.add_section("display.ui")
    if not iniConfig.has_section("input.bindings"):
        iniConfig.add_section("input.bindings")
    if not iniConfig.has_section("net"):
        iniConfig.add_section("net")
    if not iniConfig.has_section("net.udp"):
        iniConfig.add_section("net.udp")


    # Boot Animation Skip
    if system.isOptSet("xemu_bootanim"):
        iniConfig.set("general", "skip_boot_anim", system.config["xemu_bootanim"])
    else:
        iniConfig.set("general", "skip_boot_anim", "false")

    # Disable welcome screen on first launch
    iniConfig.set("general", "show_welcome", "false")

    # Set Screenshot directory
    iniConfig.set("general", "screenshot_dir", '"/userdata/screenshots"')

    # Fill sys sections
    if system.isOptSet("xemu_memory"):
        iniConfig.set("sys", "mem_limit", f'"{system.config["xemu_memory"]}"')
    else:
        iniConfig.set("sys", "mem_limit", '"64"')

    if system.name == "chihiro":
        iniConfig.set("sys", "mem_limit", '"128"')
        iniConfig.set("sys.files", "flashrom_path", '"/userdata/bios/cerbios.bin"')
    else:
        iniConfig.set("sys.files", "flashrom_path", '"/userdata/bios/Complex_4627.bin"')

    iniConfig.set("sys.files", "bootrom_path", '"/userdata/bios/mcpx_1.0.bin"')
    iniConfig.set("sys.files", "hdd_path", '"/userdata/saves/xbox/xbox_hdd.qcow2"')
    iniConfig.set("sys.files", "eeprom_path", '"/userdata/saves/xbox/xemu_eeprom.bin"')
    iniConfig.set("sys.files", "dvd_path", f'"{rom}"')

    # Audio quality
    if system.isOptSet("xemu_use_dsp"):
        iniConfig.set("audio", "use_dsp", system.config["xemu_use_dsp"])
    else:
        iniConfig.set("audio", "use_dsp", "false")

    # API
    if system.isOptSet("xemu_api"):
        iniConfig.set("display", "renderer", f'"{system.config["xemu_api"]}"')
    else:
        iniConfig.set("display", "renderer", '"OPENGL"')

    # Rendering resolution
    if system.isOptSet("xemu_render"):
        iniConfig.set("display.quality", "surface_scale", system.config["xemu_render"])
    else:
        iniConfig.set("display.quality", "surface_scale", "1") #render scale by default

    # start fullscreen
    iniConfig.set("display.window", "fullscreen_on_startup", "true")

    # Window size
    window_res = f'{gameResolution["width"]}x{gameResolution["height"]}'
    iniConfig.set("display.window", "startup_size", f'"{window_res}"')

    # Vsync
    if system.isOptSet("xemu_vsync"):
        iniConfig.set("display.window", "vsync", system.config["xemu_vsync"])
    else:
        iniConfig.set("display.window", "vsync", "true")

    # don't show the menubar
    iniConfig.set("display.ui", "show_menubar", "false")

    # Scaling
    if system.isOptSet("xemu_scaling"):
        iniConfig.set("display.ui", "fit", f'"{system.config["xemu_scaling"]}"')
    else:
        iniConfig.set("display.ui", "fit", '"scale"')

    # Aspect ratio
    if system.isOptSet("xemu_aspect"):
        iniConfig.set("display.ui", "aspect_ratio", f'"{system.config["xemu_aspect"]}"')
    else:
        iniConfig.set("display.ui", "aspect_ratio", '"auto"')

    # Fill input section
    # first, clear
    for i in range(1,5):
        iniConfig.remove_option("input.bindings", f"port{i}")
    nplayer = 1
    for playercontroller, pad in sorted(playersControllers.items()):
        if nplayer <= 4:
            iniConfig.set("input.bindings", f"port{nplayer}", f'"{pad.guid}"')
        nplayer = nplayer + 1

    # Network
    # Documentation: https://github.com/xemu-project/xemu/blob/master/config_spec.yml
    if system.isOptSet("xemu_networktype"):
        iniConfig.set("net", "enable", "true")
        iniConfig.set("net", "backend", f'"{system.config["xemu_networktype"]}"')
    else:
        iniConfig.set("net", "enable", "false")
    # Additionnal settings for udp: if nothing is entered in these fields, the xemu.toml is untouched
    if system.isOptSet("xemu_udpremote"):
        iniConfig.set("net.udp", "remote_addr", f'"{system.config["xemu_udpremote"]}"')
    if system.isOptSet("xemu_udpbind"):
        iniConfig.set("net.udp", "bind_addr", f'"{system.config["xemu_udpbind"]}"')
