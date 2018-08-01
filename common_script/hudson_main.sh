#!/bin/bash
# fix gerrit bug

function usage {
  echo -e "\n   Check changes on the branch of product"
  echo  "   usage $0 [-cbfwmh]"
  echo  "   -c: call script."
  echo  "   -b: Release branch name."
  echo  "   -f: Release folder name."
  echo  "   -h: display help information."
  echo  "   -m: build module."
  echo  "   [Clean] means rebuild after removed all folders"
  echo  " "
  exit 2
}

while  getopts c:b:f:w:m:h opt
do
   case $opt in
   c) export CALL_SCRIPT="${OPTARG}";;
   b) export BRANCH="${OPTARG}";;
   f) export FOLDER="${OPTARG}";;
   w) export WORKPLACE="${OPTARG}";;
   m) export BUILD_MODULE="${OPTARG}";;
   h) usage ;;
   *) echo "option do not exist."
      usage ;;
   esac
done

#export USE_CCACHE=1
#export CCACHE_DIR=/home/system1/system1_work/.ccache
export SCRIPT_DIR=`pwd`
export BUILD_PARAMETERS=$SCRIPT_DIR/../${BRANCH}/temp/_temp_build_parameters.txt
export LOG_PARAMETERS=$SCRIPT_DIR/../${BRANCH}/temp/_temp_log_parameters.txt
export LOG_AMSS=$SCRIPT_DIR/../${BRANCH}/temp/amss_build_log.txt
export VERSION_NUM_FILE=$SCRIPT_DIR/../${BRANCH}/temp/_temp_version_num.txt
source $SCRIPT_DIR/coolyota_build_script/version_number.sh
if [ $BRANCH ] && [ $FOLDER ] && [ $WORKPLACE ]
then
    echo "========================================="        | tee $LOG_PARAMETERS
    echo "**check product branch changeset**"               | tee -a $LOG_PARAMETERS
    echo "BRANCH    : $BRANCH"                              | tee -a $LOG_PARAMETERS
    echo "FOLDER    : $FOLDER"                              | tee -a $LOG_PARAMETERS
    echo "WORKPLACE : $WORKPLACE"                           | tee -a $LOG_PARAMETERS
    echo "=========================================" 
else
    usage
fi

export PROJECT_NAME=`grep '^PROJECT_NAME' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export REBUILDTYPE=`grep '^REBUILDTYPE' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export UPDATE_API=`grep '^UPDATE_API' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export PRO_VARIANT=`grep '^PRO_VARIANT' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export ISFACTORY=`grep '^ISFACTORY' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export PRO_MAKETAG=`grep '^PRO_MAKETAG' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export HW_VERSION=`grep '^HW_VERSION' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export BRANCH_NAME=`grep '^BRANCH_NAME' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export MANIFEST_XML=`grep '^MANIFEST_XML' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export VERSION_DATE=`grep '^VERSION_DATE' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export CHANGE_VARIANT=`grep '^CHANGE_VARIANT' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export MAKE_OTA=`grep '^MAKE_OTA' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export VERSION_NUM=`grep '^VERSION_NUM' $VERSION_NUM_FILE | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
#zhangwensheng 20170614
export BUILD_SPECIAL_VERSION=`grep '^BUILD_SPECIAL_VERSION' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export BUILD_BS_THRID_APPS=`grep '^BUILD_BS_THRID_APPS' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`

export JV_BRANCH_NAME=$BRANCH_NAME
echo "PROJECT_NAME : $PROJECT_NAME"                         | tee -a $LOG_PARAMETERS
echo "REBUILDTYPE : $REBUILDTYPE"                           | tee -a $LOG_PARAMETERS
echo "UPDATE_API : $UPDATE_API"                             | tee -a $LOG_PARAMETERS
echo "PRO_VARIANT : $PRO_VARIANT"                           | tee -a $LOG_PARAMETERS
echo "ISFACTORY : $ISFACTORY"                               | tee -a $LOG_PARAMETERS
echo "PRO_MAKETAG : $PRO_MAKETAG"                           | tee -a $LOG_PARAMETERS
echo "HW_VERSION : $HW_VERSION"                             | tee -a $LOG_PARAMETERS
#echo "BRANCH_NAME : $BRANCH_NAME"                           | tee -a $LOG_PARAMETERS
echo "MANIFEST_XML :$MANIFEST_XML"                          | tee -a $LOG_PARAMETERS
#zhangwensheng 20170614
echo "BUILD_SPECIAL_VERSION :$BUILD_SPECIAL_VERSION"                | tee -a $LOG_PARAMETERS
echo "BUILD_BS_THRID_APPS :$BUILD_BS_THRID_APPS"                | tee -a $LOG_PARAMETERS



if [ $ISFACTORY = "true" ] ; then
PRO_VARIANT="eng"
echo "======because ISFACTORY=true,so I force PRO_VARIANT=eng====="
fi

export PRO_PARAMETERS=$SCRIPT_DIR/projects/$PROJECT_NAME/PRO_Parameters.txt
if [ ! -f $PRO_PARAMETERS ]
then
    echo -e "\n not find PRO_Parameters.txt ,error! \n"
    exit 1
fi

export MANIFEST_BRANCH=`grep '^MANIFEST_BRANCH' $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
export QCOM_PLATFORM=`grep '^QCOM_PLATFORM' $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
export BASE_VER=`grep '^BASE_VER' $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
export CPB_NAME=`grep '^CPB_NAME' $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
export SSH_URL=`grep '^SSH_URL' $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
export Ori_Env_File=`grep '^Ori_Env_File'  $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
export OUT_SERVER=`grep '^OUT_SERVER' $PRO_PARAMETERS | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`

export TIMESTAMP=`date +%Y.%m.%d-%H.%M`
export TIMELOG=`date +%y%m%d-%H%M`
export DATE=`date +%y%m%d`


echo -e "\n=====================================Get Project Parameters=================================\n"  | tee -a $LOG_PARAMETERS
echo "SCRIPT_DIR         : $SCRIPT_DIR"               | tee -a $LOG_PARAMETERS
echo "MANIFEST_BRANCH    : $MANIFEST_BRANCH"          | tee -a $LOG_PARAMETERS
echo "QCOM_PLATFORM      : $QCOM_PLATFORM"            | tee -a $LOG_PARAMETERS
echo "BASE_VER           : $BASE_VER"                 | tee -a $LOG_PARAMETERS
echo "CPB_NAME           : $CPB_NAME"                 | tee -a $LOG_PARAMETERS
echo "SSH_URL            : $SSH_URL"                  | tee -a $LOG_PARAMETERS
echo "Ori_Env_File       : $Ori_Env_File"             | tee -a $LOG_PARAMETERS
echo "OUT_SERVER         : $INT_SERVER"               | tee -a $LOG_PARAMETERS

export PRJ_ENV=${WORKPLACE}
export BUILD_ENV=${PRJ_ENV}/${FOLDER}
export MSM_ENV=${BUILD_ENV}/mydroid
export BSP_ENV=${MSM_ENV}/AMSS
export MSM_SHARE=${BUILD_ENV}/share_win
export MSM_OUT_DIR=${BUILD_ENV}/version_out
export REPO_CMD=~/repo/repo
export RMT_URL=${SSH_URL}/COOLYOTA/.repo/manifests
export MAINFEST_CONFIG=coolyota/${BRANCH}.xml
export IMG_PATH=$MSM_ENV/out/target/product/${PROJECT_NAME}
export RELEASE_VER=${VERSION_DATE}${VERSION_NUM}
export JV_BUILD_ID=${BASE_VERSION}${RELEASE_VER}
export BUILD_RESULT=$MSM_SHARE/_temp_build_result
export MANIFEST_TAG=${PROJECT_NAME}_${BASE_VER}_V${RELEASE_VER}_${TIMESTAMP}
export BASELINE=Baseline_${MANIFEST_TAG}.txt
if [ $MANIFEST_XML ] ; then
export MAINFEST_CONFIG=coolyota/$MANIFEST_XML
fi
echo "PRJ_ENV            : $PRJ_ENV"              | tee -a $LOG_PARAMETERS
echo "MSM_ENV            : $MSM_ENV"              | tee -a $LOG_PARAMETERS
echo "MSM_SHARE          : $MSM_SHARE"            | tee -a $LOG_PARAMETERS
echo "REPO_CMD           : $REPO_CMD"             | tee -a $LOG_PARAMETERS
echo "RMT_URL            : $RMT_URL"              | tee -a $LOG_PARAMETERS
echo "MAINFEST_CONFIG    : $MAINFEST_CONFIG"      | tee -a $LOG_PARAMETERS
echo "IMG_PATH           : $IMG_PATH"             | tee -a $LOG_PARAMETERS
echo "MANIFEST_TAG       : $MANIFEST_TAG"         | tee -a $LOG_PARAMETERS
echo "JV_BUILD_ID        : $JV_BUILD_ID"

if [ ! -d $MSM_ENV ];then mkdir -p $MSM_ENV ;fi
if [ ! -d $YL_ENV ];then mkdir -p $YL_ENV ;fi
if [ ! -d $MSM_SHARE ];then mkdir -p $MSM_SHARE ;fi
if [ ! -d $COMM_REPO ];then mkdir -p $COMM_REPO ;fi
if [ ! -d $MSM_OUT_DIR ];then mkdir -p $MSM_OUT_DIR ;fi
if [ ! -f $SCRIPT_DIR/$CALL_SCRIPT ];then echo "$CALL_SCRIPT do not exist"; exit 1;fi

echo "bash ./$CALL_SCRIPT"
bash ./$CALL_SCRIPT
