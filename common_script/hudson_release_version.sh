#! /bin/bash

VERSION_ROOT_PATH="/home/system1/system1_work/Version_Out"
SCRIPT_PATH=`pwd`
REMOTE_SCRIPT_PATH=$SCRIPT_PATH/coolyota_build_script
#check test_file exist or not
if [ -f TEST_FILE ] ; then
 mv TEST_FILE ../$BRANCH_NAME
else
 echo "=======don't update smoke_test,please update======"
 exit 1
fi

#judge whether need to increase version num
if [ $ADD_VERSION = "add" ] ; then
  source $REMOTE_SCRIPT_PATH/version_number.sh
  let VERSION_NUM=10#${VERSION_NUM}+1
  if [ $VERSION_NUM -ge 10 ] ; then
     VERSION_NUM="0${VERSION_NUM}"
  else
     VERSION_NUM="00${VERSION_NUM}"
  fi
  cd $REMOTE_SCRIPT_PATH
  git reset --hard
  echo -e "\n #! /bin/bash" > coolyota_build_script/version_number.sh
  echo -e "export VERSION_NUM=${VERSION_NUM}" >> coolyota_build_script/version_number.sh
#  cd $REMOTE_SCRIPT_PATH
  git add .
  git commit -s -m "system_sys_fix: add version num to $VERSION_NUM"
  git push origin HEAD:default
  if [ $? != 0 ] ; then
   echo "push version num to gerrit server error"
   exit 1
  else
   echo "version num is ${VERSION_NUM}"
  fi  
fi


#judge the source version isn't ok
if [ ${VERSION_PATH} = "" ] ; then
 echo "========don't fill version path,please fill======"
 exit 1
else
 ISUSE=`echo ${VERSION_PATH} | grep "user"`
 ISUSEDEBUG=`echo ${VERSION_PATH} | grep "userdebug"`
 if [ $ISUSE != "" ] && [ $ISUSEDEBUG != "" ] ; then
  VERSION_PATH=${VERSION_PATH//\\/\/}
  SOURCE_VERSION=${VERSION_ROOT_PATH}/${VERSION_PATH}
  echo $SOURCE_VERSION
  if [ -d $SOURCE_VERSION ] ; then
   echo "=========find source version========="
  else
   echo "=========not find source version======"
   exit 1
  fi
 else
  echo "==========source version not user========"
  exit 1
 fi
fi

#generate version name
DATE=`date +%Y-%m-%d`
VERSION__NAME=${PRODUCT_NAME}_V${VERSION_NUM}_${HW_VERSION}
mkdir -p $VERSION_ROOT_PATH/Release_Version_Out/$VERSION__NAME
cp -rvf $SOURCE_VERSION/* $VERSION_ROOT_PATH/Release_Version_Out/$VERSION__NAME
cp -rvf  $SCRIPT_PATH/../TEST_FILE $VERSION_ROOT_PATH/Release_Version_Out/$VERSION__NAME/冒烟测试报告.xlsx


