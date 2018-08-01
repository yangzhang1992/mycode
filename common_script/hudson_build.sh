#!/bin/bash

#if [ ! -d $MSM_ENV ];then echo "$MSM_ENV do not exist"; exit 1;fi
#touch $MSM_SHARE/_temp_msm_building

echo -e "Process Start at`date +%Y.%m.%d-%H.%M`"
echo -e "========================================="
cd ${SCRIPT_DIR}
cp -vf build.sh $MSM_ENV
cp -vf class_jar_list.txt $MSM_ENV
cp -vf make_classes_jar.sh $MSM_ENV
#这里表示有GMS包，详情需要咨询xushiming
 export BAOLIYOTA_FEATURE_0524_VERSION_CONTROL_APK_INTEGRATE=true

if [ -d $IMG_PATH ]
then
	cd $IMG_PATH
	echo "rm out file ..."
	rm -rf $MSM_ENV/*.log
	rm -v  system/build.prop
	#rm -rf system/app/* system/priv-app/* system/lib* system/presetapp/* 
	rm -rf obj/PACKAGING/target_files_intermediates/*
        rm -rf *ota*.zip
	rm -rf obj/KERNEL_OBJ/arch/arm64/boot/dts/*
	#rm -rf obj/APPS
	rm -v  obj/ETC/system_build_prop_intermediates/build.prop
fi

cd ${SCRIPT_DIR}

if [ "$REBUILDTYPE" = "Clean" ]
then
     if [ "$ISFACTORY" = "FALSE" ] ; then
     export VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PROPERTIES}_${PRO_VARIANT}_Clean
     else
     export VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PROPERTIES}_${PRO_VARIANT}_Clean_Factory
     fi
else
     if [ "$ISFACTORY" = "FALSE" ] ; then
     export  VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PROPERTIES}_${PRO_VARIANT}
     else
     export  VERSION_DIR=${CPB_NAME}_V${RELEASE_VER}_${HW_VERSION}_${PROPERTIES}_${PRO_VARIANT}_Factory
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

echo "build android ==> ${BUILD_OPERATOR}"
if [ x${BUILD_OPERATOR} == x"07" ] ; then
echo "build android ==> BUILD_OPERATOR = 07"
echo "{MSM_ENV} : ${MSM_ENV}"
sed -i  's/BAOLIYOTA_FEATURE_0524_VERSION_CONTROL_APK_INTEGRATE =.*/BAOLIYOTA_FEATURE_0524_VERSION_CONTROL_APK_INTEGRATE = true/g' ${MSM_ENV}/device/zeusis/Y3/productfeature/product_feature
fi
#clean build.prop
rm -rvf ${MSM_ENV}/out/target/product/$PROJECT_NAME/system/build.*
rm -rvf ${MSM_ENV}/out/target/product/$PROJECT_NAME/ETC/system_build_prop_intermediates


if [ $UPDATE_API = "TRUE" ] ; then
./build.sh $PROJECT_NAME -b $HW_VERSION -v $PRO_VARIANT -f $ISFACTORY -u 
else
./build.sh $PROJECT_NAME -b $HW_VERSION -v $PRO_VARIANT -f $ISFACTORY
fi
OK_BUILD=`grep "Install system fs image: out/target/product/${PROJECT_NAME}/system.img" ${PROJECT_NAME}.log`
#OK_BUILD=1
if [ "$OK_BUILD" = "" ] ; then
	MAKE_RESULT=1
	FAIL_AMOUNT=`grep '^FAIL_AMOUNT' $BUILD_RESULT | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
	FAIL_AMOUNT=`expr $FAIL_AMOUNT + 1`
	echo "MAKE_RESULT := fail" > $BUILD_RESULT
	echo "FAIL_AMOUNT := $FAIL_AMOUNT" >> $BUILD_RESULT
	echo -e "\n=============Android Build Failed =============="
	export VERSION_DIR=${VERSION_DIR}_android_build_fail
	#PKG_DIR=$MSM_OUT_DIR/${VERSION_DIR}
	#cp -vf $MSM_ENV/${PROJECT_NAME}.log                       $PKG_DIR/Build_${EXTERNAL_NAME}_${TIMESTAMP}.log
else
	#BaoliYota modify begin
	#for ota compile ,modify by zhangwensheng@yotamobile.com,2017-07-22
	#ls ${MSM_ENV}/AMSS/out/bin/
	cp ${MSM_ENV}/AMSS/out/bin/*  ${MSM_ENV}/out/target/product/$PROJECT_NAME
	#BaoliYota modify end
	#BaoliYota modify begin
	#for National gift version, with 100 books ,modify by zhangwensheng@yotamobile.com,2017-08-24
        export NATIONAL_GIFT=FALSE
	BOOT_RES=/home/system1/JV_Y3/YOTA_BOOK/Yota/BReader
	#if [ $NATIONAL_GIFT = "TRUE" ] ; then	
	if [ $BUILD_OPERATOR = "06" ] && [ $BUILD_MARKET_LEVEL = "X" ] ; then
	  # mv ${MSM_ENV}/out/target/product/$PROJECT_NAME/cust/ALL/local_res ${MSM_ENV}/out/target/product/$PROJECT_NAME/cust/ALL/local_res_20
	  # mkdir -p ${MSM_ENV}/out/target/product/$PROJECT_NAME/cust/ALL/local_res	   	   
	  export NATIONAL_GIFT=TRUE
	  echo -e "NATIONAL_GIFT : $NATIONAL_GIFT  "
	  rm -rf  ${MSM_ENV}/device/zeusis/Y3/cust/CUST-CHINA/ALL/local_res/*
	   cp -rf $BOOT_RES/*  ${MSM_ENV}/device/zeusis/Y3/cust/CUST-CHINA/ALL/local_res/	
       cd ${MSM_ENV}	   
	   mv ${MSM_ENV}/out/target/product/$PROJECT_NAME/cust.img   ${MSM_ENV}/out/target/product/$PROJECT_NAME/cust-temp.img
	  
	   source build/envsetup.sh
	   echo "$PROJECT_NAME-$PRO_VARIANT"
       lunch $PROJECT_NAME-$PRO_VARIANT
       make custimage -j8
	  
	fi 
	#BaoliYota modify end
	
	#BaoliYota modify begin
        #make otapackage. zhoumin1@coolpad.com,2017-04-26
        echo -e "\n===========Android Build Success ==============="
	cd ${MSM_ENV}
       # if [ $ISFACTORY = "FALSE" ] && [ $PRO_VARIANT != "eng" ] ; then
         if [ $MAKE_OTA = "TRUE" ] ; then
           if [ $ISFACTORY = "FALSE" ] && [ $PRO_VARIANT != "eng" ] ; then
	   
           echo -e "\n===========Build Otapackage Start=============="
           ./build.sh $PROJECT_NAME -b $HW_VERSION -v $PRO_VARIANT -o
           if [ $? = 0 ] ; then
             MAKE_RESULT=0
             echo "MAKE_RESULT := success" > $BUILD_RESULT
             echo "FAIL_AMOUNT := 1" >> $BUILD_RESULT
             echo -e "\n===========Otapackage Build Success ==============="
           else
            MAKE_RESULT=1
            FAIL_AMOUNT=`grep '^FAIL_AMOUNT' $BUILD_RESULT | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
            FAIL_AMOUNT=`expr $FAIL_AMOUNT + 1`
            echo "MAKE_RESULT := fail" > $BUILD_RESULT
            echo "FAIL_AMOUNT := $FAIL_AMOUNT" >> $BUILD_RESULT
            echo -e "\n============Otapackage Build Fail========"
           fi
          else
            MAKE_RESULT=0 
            echo "MAKE_RESULT := success" > $BUILD_RESULT
            echo "FAIL_AMOUNT := 1" >> $BUILD_RESULT
          fi
        else
            MAKE_RESULT=0
            echo "MAKE_RESULT := success" > $BUILD_RESULT
            echo "FAIL_AMOUNT := 1" >> $BUILD_RESULT
        fi
       # BaoliYota modify end
        
fi

#start:zhoumin1 add to record last sync time
YMD_BUILD_TIME=`date +%Y-%m-%d-%H-%M`
BUILD_TIME=`date +%s`

if [ -f $SCRIPT_DIR/build_time.txt ] ; then
mv $SCRIPT_DIR/build_time.txt $SCRIPT_DIR/build_time_back.txt
fi

echo "YMD_BUILD_TIME:$YMD_BUILD_TIME" > $SCRIPT_DIR/build_time.txt
echo "BUILD_TIME:$BUILD_TIME" >> $SCRIPT_DIR/build_time.txt
rm -rf $SCRIPT_DIR/build_time_back.txt
#end:zhoumin1 add to record last sync time
if [ $MAKE_RESULT = 0 ] ; then 
echo "SUCESS_FLAG:1" > $SCRIPT_DIR/sucess_flag.txt
cd ${MSM_ENV}
rm -rf $SCRIPT_DIR/../${BRANCH}/${BRANCH}_*.xml
echo "$REPO_CMD manifest -r -o $SCRIPT_DIR/../${BRANCH}/${BRANCH}_${YMD_BUILD_TIME}.xml"
$REPO_CMD manifest -r -o $SCRIPT_DIR/../${BRANCH}/${BRANCH}_${YMD_BUILD_TIME}.xml
else
echo "SUCESS_FLAG:0" > $SCRIPT_DIR/sucess_flag.txt
fi

cd ${SCRIPT_DIR}
./hudson_copy_result.sh  amss_not_error

#BaoliYota modify begin
#for reset NATIONAL_GIFT resource ,modify by zhangwensheng@yotamobile.com,2017-07-26
#if [ $BUILD_OPERATOR = "06" ] && [ $BUILD_MARKET_LEVEL = "A" ] ; then
 cd ${MSM_ENV}/device/zeusis/Y3
 git clean -fd 
 git reset --hard	  
 cd ${MSM_ENV}
#fi
#BaoliYota modify end 

echo -e "\n========================================="
echo  "Process end at`date +%Y.%m.%d-%H.%M`"
echo -e "\n========================================="
#rm -rf $MSM_SHARE/_temp_msm_building
#rm -rf  ${SCRIPT_PATH}/../${BRANCH_NAME}/build_is_work
exit $MAKE_RESULT
