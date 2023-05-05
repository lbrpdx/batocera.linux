#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Download U-Boot mainline
wget "https://ftp.denx.de/pub/u-boot/u-boot-2023.01.tar.bz2"
tar xf u-boot-2023.01.tar.bz2
cd u-boot-2023.01

# Apply patches
PATCHES="${BR2_EXTERNAL_BATOCERA_PATH}/board/batocera/amlogic/s922x/patches/uboot/*.patch"
for patch in $PATCHES
do
echo "Applying patch: $patch"
patch -p1 < $patch
done

# Make config
make odroid-n2_defconfig

# Build it
ARCH=aarch64 CROSS_COMPILE="${HOST_DIR}/bin/aarch64-buildroot-linux-gnu-" make -j$(nproc)
mkdir -p ../../uboot-odroidn2plus

# Clone LibreElec Amlogic FIP
git clone --depth 1 https://github.com/LibreELEC/amlogic-boot-fip

# Build and put to appropriate place
cd amlogic-boot-fip && ./build-fip.sh odroid-n2-plus ../u-boot.bin ../../../uboot-odroidn2plus/