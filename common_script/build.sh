#!/bin/bash
#
# Copyright (c) 2012, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

set -o errexit

usage() {
cat <<USAGE

Usage:
    bash $0 <TARGET_PRODUCT> [OPTIONS]

Description:
    Builds Android tree for given TARGET_PRODUCT

OPTIONS:
    -c, --clean_build
        Clean build - build from scratch by removing entire out dir

    -d, --debug
        Enable debugging - captures all commands while doing the build

    -h, --help
        Display this help message

    -i, --image
        Specify image to be build/re-build (bootimg/sysimg/usrimg)

    -j, --jobs
        Specifies the number of jobs to run simultaneously (Default: 8)

    -k, --kernel_defconf
        Specify defconf file to be used for compiling Kernel

    -l, --log_file
        Log file to store build logs (Default: <TARGET_PRODUCT>.log)

    -m, --module
        Module to be build

    -p, --project
        Project to be build

    -s, --setup_ccache
        Set CCACHE for faster incremental builds (true/false - Default: true)

    -u, --update-api
        Update APIs

    -v, --build_variant
        Build variant (Default: userdebug)

    -r, --carrier_region
        Carrier region to be build

    -b, --board_version
        HARDWARE_VER to be build

    -f, --isfactory
        whether to build factory version
    -o, --otapackage
        build otapackage

USAGE
}

clean_build() {
    echo -e "\nINFO: Removing entire out dir. . .\n"
    make clobber
}

build_android() {
    echo $ISFACTORY
    echo -e "\nINFO: Build yota sdk"
    make YotaDevicesSDK -j48
    if [ "$ISFACTORY" = "FALSE" ] ; then
    echo -e "\nINFO: Build Android tree for $TARGET\n"
	echo "All parameter is $@"
    make $@ -j48 2>&1 | tee $LOG_FILE.log
    else
    echo -e "\nINFO: Build Android tree factory img for $TARGET\n"
    make $@ -j48 FACTORY_IMAGE=true 2>&1 | tee $LOG_FILE.log
    fi
#    if [ $? = 0 ] ; then
 #   echo "========copy eink so start=========="
 #   if [ -f vendor/eink/hwcomposer.msm8953.so ] ; then
 #   cp -rvf vendor/eink/hwcomposer.msm8953.so $MSM_ENV/out/target/product/${PROJECT_NAME}/system/lib64/hw
 #   fi
    
  #  if [ -f vendor/eink/libsurfaceflinger.so ] ; then
   # cp -rvf vendor/eink/libsurfaceflinger.so $MSM_ENV/out/target/product/${PROJECT_NAME}/system/lib64
    #fi

    #if [ -f vendor/eink/libsdmcore.so ] ; then
   # cp -rvf vendor/eink/libsdmcore.so $MSM_ENV/out/target/product/${PROJECT_NAME}/system/lib64
   # fi

   # if [ -f vendor/eink/libtcon_eink/libtcon_eink.so ] ; then
  #  cp -rvf vendor/eink/libtcon_eink/libtcon_eink.so $MSM_ENV/out/target/product/${PROJECT_NAME}/system/lib64
  #  fi
  #  echo "========copy eink so end============"
  #  make snod -j48
  #  fi
   # if [ -f make_classes_jar.sh ]; then source ./make_classes_jar.sh ; fi
   # if [ -f vendor/eink/hwcomser.msm8953.so ] ; then
}

build_bootimg() {
    echo -e "\nINFO: Build bootimage for $TARGET\n"
    make bootimage $@ | tee $LOG_FILE.log
}

build_sysimg() {
    echo -e "\nINFO: Build systemimage for $TARGET\n"
    make systemimage $@ | tee $LOG_FILE.log
}

build_usrimg() {
    echo -e "\nINFO: Build userdataimage for $TARGET\n"
    make userdataimage $@ | tee $LOG_FILE.log
}

build_module() {
    echo -e "\nINFO: Build $MODULE for $TARGET\n"
    make $MODULE $@ | tee $LOG_FILE.log
}

build_project() {
    echo -e "\nINFO: Build $PROJECT for $TARGET\n"
    mmm $PROJECT | tee $LOG_FILE.log
}

update_api() {
    echo -e "\nINFO: Updating APIs\n"
    make update-api -j48 | tee $LOG_FILE.log
}

setup_ccache() {
    export CCACHE_DIR=../.ccache
    export USE_CCACHE=1
}

delete_ccache() {
    prebuilts/misc/linux-x86/ccache/ccache -C
    rm -rf $CCACHE_DIR
}

create_ccache() {
    echo -e "\nINFO: Setting CCACHE with 10 GB\n"
    setup_ccache
    delete_ccache
    prebuilts/misc/linux-x86/ccache/ccache -M 10G
}

setup_date() {
    DATE=`date +%y%m%d`
    export BUILDDATE=$DATE
}

# Set PRO_NAME for lk, maybe remove later...
setup_proname() {
    declare -u proname=$TARGET
    export PRO_NAME=$proname
}

setup_carr_reg() {
    export CARR_REG=$CARRIER_REGION
}

setup_hardware_version() {
#    declare -l hardware_ver=$HW_VER
    declare hardware_ver=$HW_VER
    export HARDWARE_VER=$hardware_ver
    echo "HARDWARE_VER=$hardware_ver"
}

prepare_ylenv() {
    setup_date
    setup_proname
    setup_hardware_version
    setup_carr_reg
}

# Set defaults
VARIANT="userdebug"
JOBS=16
CCACHE="true"
HW_VER="P0"
OTAPACKAGE="false"

# Setup getopt.
long_opts="clean_build,debug,help,image:,jobs:,kernel_defconf:,log_file:,module:,"
long_opts+="project:,setup_ccache:,update-api,build_variant,carrier_region:"
getopt_cmd=$(getopt -o cdhoi:j:k:l:m:p:s:uv:r:b:f: --long "$long_opts" \
            -n $(basename $0) -- "$@") || \
            { echo -e "\nERROR: Getopt failed. Extra args\n"; usage; exit 1;}

eval set -- "$getopt_cmd"

while true; do
    case "$1" in
        -c|--clean_build) CLEAN_BUILD="true";;
        -d|--debug) DEBUG="true";;
        -h|--help) usage; exit 0;;
        -o|--otapackage) OTAPACKAGE="true";;
        -i|--image) IMAGE="$2"; shift;;
        -j|--jobs) JOBS="$2"; shift;;
        -k|--kernel_defconf) DEFCONFIG="$2"; shift;;
        -l|--log_file) LOG_FILE="$2"; shift;;
        -m|--module) MODULE="$2"; shift;;
        -p|--project) PROJECT="$2"; shift;;
        -u|--update-api) UPDATE_API="true";;
        -s|--setup_ccache) CCACHE="$2"; shift;;
        -v|--build_variant) VARIANT="$2"; shift;;
        -r|--carrier_region) CARRIER_REGION="$2"; shift;;
        -b|--board_version) HW_VER="$2"; shift;;
        -f|--isfactory) ISFACTORY="$2"; shift;;
        --) shift; break;;
    esac
    shift
done
# Mandatory argument
if [ $# -eq 0 ]; then
    echo -e "\nERROR: Missing mandatory argument: TARGET_PRODUCT\n"
    usage
    exit 1
fi
if [ $# -gt 1 ]; then
    echo -e "\nERROR: Extra inputs. Need TARGET_PRODUCT only\n"
    usage
    exit 1
fi
TARGET="$1"; shift

if [ -z $LOG_FILE ]; then
    LOG_FILE=$TARGET
fi

CMD="-j $JOBS"
if [ "$DEBUG" = "true" ]; then
    CMD+=" showcommands"
fi
if [ -n "$DEFCONFIG" ]; then
    CMD+=" KERNEL_DEFCONFIG=$DEFCONFIG"
fi

if [ "$CCACHE" = "true" ]; then
    setup_ccache
fi

#add by zhangwensheng 20170715 for cta
set -x
echo "zhangwensheng modify for CTA compiling "
export BUILD_PARAMETERS=/home/system1/build_script_HBZ/${BRANCH}/temp/_temp_build_parameters.txt
echo "BUILD_PARAMETERS=$BUILD_PARAMETERS"
export BUILD_SPECIAL_VERSION=`grep '^BUILD_SPECIAL_VERSION' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export BUILD_BS_THRID_APPS=`grep '^BUILD_BS_THRID_APPS' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
echo "BUILD_SPECIAL_VERSION=$BUILD_SPECIAL_VERSION"
echo "BUILD_BS_THRID_APPS=$BUILD_BS_THRID_APPS"
#setup yulong build env.by shaojunjun
prepare_ylenv

source build/envsetup.sh
lunch $TARGET-$VARIANT

if [ "$CLEAN_BUILD" = "true" ]; then
    clean_build
    if [ "$CCACHE" = "true" ]; then
        create_ccache
    fi
fi

if [ "$UPDATE_API" = "true" ]; then
    update_api
fi

if [ -n "$MODULE" ]; then
    build_module "$CMD"
fi

if [ -n "$PROJECT" ]; then
    build_project
fi

if [ -n "$IMAGE" ]; then
    build_$IMAGE "$CMD"
fi
#BaoliYota modify begin
#add interface of make otapackage.zhoumin1@coolpad.com,2017-04-26
#echo $OTAPACKAGE
if [ $OTAPACKAGE = "true" ] ; then
export TMPDIR=/home/system1/tmp
make otapackage -j32
else
#echo fail =====
build_android "$CMD"
fi
#BaoliYota modify end
