#!/bin/bash
SCRIPT_PATH=`pwd`
WORK_PLACE=/home/system1/system1_work/JV_Y3

echo -e "\n"
echo "check compling status ... ${SCRIPT_PATH}/../${BRANCH_NAME}/build_is_work"
#if [ -e $SCRIPT_PATH/build_is_work ]; then
if [ -e  ${SCRIPT_PATH}/../${BRANCH_NAME}/build_is_work ]; then
echo -e "\n======build task is working or pre build task abnormal end. please check! ========"
exit 1
fi
#touch build_is_work
touch  ${SCRIPT_PATH}/../${BRANCH_NAME}/build_is_work

#SCRIPT_PATH=`pwd`
TEMP_BUILD_PARAMETER=${SCRIPT_PATH}/../$BRANCH_NAME/temp
if [ ! -d ${TEMP_BUILD_PARAMETER} ] ; then
mkdir -p ${TEMP_BUILD_PARAMETER}
fi

cd ${TEMP_BUILD_PARAMETER}
touch _temp_build_parameters.txt

TEMP_BUILD_PARAMETER=${TEMP_BUILD_PARAMETER}/_temp_build_parameters.txt

#create new version num
TEMP_VERSION_NUM=${SCRIPT_PATH}/../$BRANCH_NAME/temp/_temp_version_num.txt
VERSION_DATE=`date +%y%m%d`
OLD_VERSION_DATE=`grep '^VERSION_DATE' $TEMP_BUILD_PARAMETER | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
if [ ! $OLD_VERSION_DATE  ] || [ $OLD_VERSION_DATE != $VERSION_DATE ] ; then
echo "VERSION_NUM=1" > ${TEMP_VERSION_NUM}
echo $VERSION_NUM step 1
else
VERSION_NUM=`grep '^VERSION_NUM' $TEMP_VERSION_NUM | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
let VERSION_NUM=VERSION_NUM+1
echo "VERSION_NUM=$VERSION_NUM" > ${TEMP_VERSION_NUM}
echo $VERSION_NUM step 2
fi

CHANGE_VARIANT=`grep '^PRO_VARIANT' $TEMP_BUILD_PARAMETER | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
if [ $PRO_VARIANT != $CHANGE_VARIANT ] ; then
CHANGE_VARIANT=true
else
CHANGE_VARIANT=false
fi

if [ $1 = "simple" ] ; then
echo "PROJECT_NAME=Y3" > ${TEMP_BUILD_PARAMETER}
echo "REBUILDTYPE=$REBUILDTYPE" >> ${TEMP_BUILD_PARAMETER}
echo "UPDATE_API=TRUE" >> ${TEMP_BUILD_PARAMETER}
echo "PRO_VARIANT=$PRO_VARIANT" >> ${TEMP_BUILD_PARAMETER}
echo "ISFACTORY=$ISFACTORY" >> ${TEMP_BUILD_PARAMETER}
echo "PRO_MAKETAG=FALSE" >> ${TEMP_BUILD_PARAMETER}
echo "HW_VERSION=$HW_VERSION" >> ${TEMP_BUILD_PARAMETER}
echo "BRANCH_NAME=$BRANCH_NAME" >> ${TEMP_BUILD_PARAMETER}
echo "MANIFEST_XML=" >> ${TEMP_BUILD_PARAMETER}
echo "VERSION_DATE=$VERSION_DATE" >> ${TEMP_BUILD_PARAMETER}
echo "MAKE_OTA=$MAKE_OTA">>${TEMP_BUILD_PARAMETER}
echo "CHANGE_VARIANT=$CHANGE_VARIANT">>${TEMP_BUILD_PARAMETER}
echo "BUILD_SPECIAL_VERSION=$BUILD_SPECIAL_VERSION">>${TEMP_BUILD_PARAMETER}
echo "BUILD_BS_THRID_APPS=$BUILD_BS_THRID_APPS">>${TEMP_BUILD_PARAMETER}
else

echo "PROJECT_NAME=Y3" > ${TEMP_BUILD_PARAMETER}
echo "REBUILDTYPE=$REBUILDTYPE" >> ${TEMP_BUILD_PARAMETER}
echo "UPDATE_API=TRUE" >> ${TEMP_BUILD_PARAMETER}
echo "PRO_VARIANT=$PRO_VARIANT" >> ${TEMP_BUILD_PARAMETER}
echo "ISFACTORY=$ISFACTORY" >> ${TEMP_BUILD_PARAMETER}
echo "PRO_MAKETAG=$PRO_MAKETAG" >> ${TEMP_BUILD_PARAMETER}
echo "HW_VERSION=$HW_VERSION" >> ${TEMP_BUILD_PARAMETER}
echo "BRANCH_NAME=$BRANCH_NAME" >> ${TEMP_BUILD_PARAMETER}
echo "MANIFEST_XML=$MANIFEST_XML" >> ${TEMP_BUILD_PARAMETER}
echo "VERSION_DATE=$VERSION_DATE" >> ${TEMP_BUILD_PARAMETER}
echo "MAKE_OTA=$MAKE_OTA">>${TEMP_BUILD_PARAMETER}
echo "CHANGE_VARIANT=$CHANGE_VARIANT">>${TEMP_BUILD_PARAMETER}
echo "BUILD_SPECIAL_VERSION=$BUILD_SPECIAL_VERSION">>${TEMP_BUILD_PARAMETER}
echo "BUILD_BS_THRID_APPS=$BUILD_BS_THRID_APPS">>${TEMP_BUILD_PARAMETER}
fi

echo -e "\n=====get parameter sucess,start other build task========="

cd $SCRIPT_PATH
