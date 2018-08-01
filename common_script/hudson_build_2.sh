#!/bin/bash

#if [ ! -d $MSM_ENV ];then echo "$MSM_ENV do not exist"; exit 1;fi
#touch $MSM_SHARE/_temp_msm_building

echo -e "Process Start at`date +%Y.%m.%d-%H.%M`"
echo -e "========================================="
cd ${SCRIPT_DIR}
cp -vf build.sh $MSM_ENV
cp -vf class_jar_list.txt $MSM_ENV
cp -vf make_classes_jar.sh $MSM_ENV

if [ -d $IMG_PATH ]
then
	cd $IMG_PATH
	echo "rm out file ..."
fi

cd ${SCRIPT_DIR}

if [ "$REBUILDTYPE" = "Clean" ]
then
     if [ "$ISFACTORY" = "FALSE" ] ; then
     export VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PRO_VARIANT}_Clean
     else
     export VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PRO_VARIANT}_Clean_Factory
     fi
else
     if [ "$ISFACTORY" = "FALSE" ] ; then
     export  VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PRO_VARIANT}
     else
     export  VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PRO_VARIANT}_Factory
     fi
fi
echo -e "\n===VERSION_DIR:${VERSION_DIR}======="

echo -e "\n============Begin to build==============="
cd ${MSM_ENV}
echo -e "\n PROJECT_NAME=$PROJECT_NAME"
echo -e "\n HW_VER=$HW_VERSION"
echo -e "\n PRO_VARIANT=$PRO_VARIANT"
#echo $BUILD_MODULE
echo -e "\n UPDATE_API=$UPDATE_API"
echo -e "\n ISFACTORY=${ISFACTORY}"

#clean build.prop

OK_BUILD=`grep "Install system fs image: out/target/product/${PROJECT_NAME}/system.img" ${PROJECT_NAME}.log`
#OK_BUILD=1

#start:zhoumin1 add to record last sync time
YMD_BUILD_TIME=`date +%Y-%m-%d-%H-%M`
BUILD_TIME=`date +%s`

if [ -f $SCRIPT_DIR/build_time.txt ] ; then
mv $SCRIPT_DIR/build_time.txt $SCRIPT_DIR/build_time_back.txt
fi

echo "YMD_BUILD_TIME:$YMD_BUILD_TIME" > $SCRIPT_DIR/build_time.txt
echo "BUILD_TIME:$BUILD_TIME" >> $SCRIPT_DIR/build_time.txt
#end:zhoumin1 add to record last sync time

cd ${SCRIPT_DIR}
./hudson_copy_result.sh  amss_not_error

echo -e "\n========================================="
echo  "Process end at`date +%Y.%m.%d-%H.%M`"
echo -e "\n========================================="

