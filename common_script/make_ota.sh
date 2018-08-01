#! /bin/bash

#get source version and dst version
function usage {
   echo -e "use $0 [-sdw]"
   echo -e "-s : source version path"
   echo -e "-d : dst version path"
   exit 2
}


while getopts "s:d:w:" opt
do
  case $opt in
    s) export SOURCE_PATH=${OPTARG};;
    d) export DST_PATH=${OPTARG};;
    w) export WORK_PLACE=${OPTARG};;
    h) usage;;
    *) echo opt not exist
       usage
  esac
done

ROOT_PATH="/home/release/y3/coolyota_msm8953_newint"
OTA_OUT_PATH="/home/release/y3/ota"

if [ $SOURCE_PATH ] && [ $DST_PATH ]  && [ $WORK_PLACE ]; then

  if [ -d $ROOT_PATH/$SOURCE_PATH ] && [ -d $ROOT_PATH/$DST_PATH ] ; then
     if [ -f $ROOT_PATH/$SOURCE_PATH/ota/Y3-target*.zip ] && [ -f $ROOT_PATH/$DST_PATH/ota/Y3-target*.zip ] ; then
      SOURCE_NUM=`echo $SOURCE_PATH | awk -F _  '{print $2}' | tr -d " "| tr -d "\r"`
      DST_NUM=`echo $DST_PATH | awk -F _  '{print $2}' | tr -d " "| tr -d "\r"`
      mkdir -p $OTA_OUT_PATH/ota_${SOURCE_NUM}_${DST_NUM}
      cd $WORK_PLACE
      export TMPDIR="/home/system1/system1_work/tmp"
      $WORK_PLACE/build/tools/releasetools/ota_from_target_files --block -v -n -i  $ROOT_PATH/$SOURCE_PATH/ota/Y3-target*.zip  $ROOT_PATH/$DST_PATH/ota/Y3-target*.zip $OTA_OUT_PATH/ota_${SOURCE_NUM}_${DST_NUM}/ota_${SOURCE_NUM}_${DST_NUM}.zip
      if [ $? != 0 ] ; then
       echo "======make ota fail=========="
       exit 1
      else
       echo "======make ota sucess ======="
       exit 0
      fi
     else
       echo "=====ota package don't exist==========="
     fi
  else
    echo "==========path don't exist========="
  fi
else
echo "=======source_path or dst_path don't fill,please check======="
exit 1
fi
