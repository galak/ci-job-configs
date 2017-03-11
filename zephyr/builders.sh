#!/bin/bash

sudo apt-get -q=2 update
sudo apt-get -q=2 -y install git g++ libc6-dev-i386 g++-multilib python3-ply python3-yaml gcc-arm-none-eabi python-requests rsync device-tree-compiler

set -ex

git clone --depth 1 -b ${BRANCH} https://github.com/zephyrproject-rtos/zephyr.git ${WORKSPACE}
git clean -fdx
echo "GIT_COMMIT=$(git rev-parse --short=8 HEAD)" > env_var_parameters

head -5 Makefile

# Toolchains are pre-installed and come from:
# https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/6_1-2017q1/gcc-arm-none-eabi-6-2017-q1-update-linux.tar.bz2
# https://nexus.zephyrproject.org/content/repositories/releases/org/zephyrproject/zephyr-sdk/0.9/zephyr-sdk-0.9-setup.run
# To install Zephyr SDK: ./zephyr-sdk-0.9-setup.run --quiet --nox11 -- <<< "${HOME}/srv/toolchain/zephyr-sdk-0.9"

case "${ZEPHYR_GCC_VARIANT}" in
  gccarmemb)
    export GCCARMEMB_TOOLCHAIN_PATH="${HOME}/srv/toolchain/gcc-arm-none-eabi-6-2017-q1-update"
  ;;
  zephyr)
    export ZEPHYR_SDK_INSTALL_DIR="${HOME}/srv/toolchain/zephyr-sdk-0.9"
  ;;
esac

# Set build environment variables
LANG=C
ZEPHYR_BASE=${WORKSPACE}
PATH=${ZEPHYR_BASE}/scripts:${PATH}
OUTDIR=${HOME}/srv/zephyr/${ZEPHYR_GCC_VARIANT}/${PLATFORM}
export LANG ZEPHYR_BASE PATH
CCACHE_DIR="${HOME}/srv/ccache"
CCACHE_UNIFY=1
CCACHE_SLOPPINESS=file_macro,include_file_mtime,time_macros
USE_CCACHE=1
export CCACHE_DIR CCACHE_UNIFY CCACHE_SLOPPINESS USE_CCACHE
env |grep '^ZEPHYR'

echo ""
echo "########################################################################"
echo "    sanitycheck"
echo "########################################################################"

time sanitycheck \
  --platform ${PLATFORM} \
  --inline-logs \
  --build-only \
  --outdir ${OUTDIR} \
  --no-clean \
  --enable-slow \
  --ccache

cd ${WORKSPACE}
find ${OUTDIR} -type f -name '.config' -exec rename 's/.config/zephyr.config/' {} +
rsync -avm \
  --include=zephyr.bin \
  --include=zephyr.config \
  --include=zephyr.elf \
  --include='*/' \
  --exclude='*' \
  ${OUTDIR}/ out/
find ${OUTDIR} -type f -name 'zephyr.config' -delete

CCACHE_DIR=${CCACHE_DIR} ccache -M 30G
CCACHE_DIR=${CCACHE_DIR} ccache -s
