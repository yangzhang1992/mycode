#!/bin/bash
SCRIPT_PATH=`pwd`
echo -e "\n=======clean build result======"
rm -rf ${MSM_OUT_DIR}/*

echo -e "\n=======copy build result======="
echo -e "\n=======1.copy android build result========"


export LOCAL_OUT=${MSM_OUT_DIR}/${VERSION_DIR}
export OUT_SERVER=/home/release/y3/${BRANCH}/${VERSION_DIR}
export EMAIL_OUT_SERVER=/versions/y3/${BRANCH}/${VERSION_DIR}

export BUILD_PARAMETERS=$SCRIPT_DIR/../${BRANCH}/temp/_temp_build_parameters.txt
export ISFACTORY=`grep '^ISFACTORY' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
export PRO_MAKETAG=`grep '^PRO_MAKETAG' $BUILD_PARAMETERS | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`


#email config
EMAIL_PATH=$SCRIPT_PATH/sendEmail
EMAIL_CONFIG=$EMAIL_PATH/jv_config
cp ${MSM_SHARE}/CR_List_diff.txt $EMAIL_CONFIG
cp -rvf ${MSM_SHARE}/maillist.txt $EMAIL_CONFIG/toNameList
cp $LOG_AMSS $EMAIL_CONFIG
SUCESS_FLAG=`grep '^SUCESS_FLAG' $SCRIPT_DIR/sucess_flag.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`

if [ ! -d ${LOCAL_OUT} ] ; then
mkdir -p ${LOCAL_OUT}
else
rm -rf ${LOCAL_OUT}/*
fi

echo -e "\nOUT_SERVER:${OUT_SERVER}"
if [ ! -d ${OUT_SERVER} ] ; then
mkdir -p ${OUT_SERVER}
else
rm -rf ${OUT_SERVER}/*
fi

if [ $1 = "amss_error" ] ; then
echo ":::::::{MSM_SHARE}/*.xml ::::::"
echo "${MSM_SHARE}/*.xml"
cp -rvf ${MSM_SHARE}/*.xml ${LOCAL_OUT}/Configurations
cp -rvf $LOG_AMSS $LOCAL_OUT
cp -rvf ${MSM_SHARE}/CR_List_diff.txt ${LOCAL_OUT}/Configurations
cp -rvf ${MSM_SHARE}/maillist.txt ${LOCAL_OUT}/Configurations

cp -rvf $LOCAL_OUT/* $OUT_SERVER
SUCESS_FLAG=0
else
cd ${LOCAL_OUT}
mkdir android_result
mkdir bsp_result
mkdir Configurations
mkdir debug
mkdir ota
mkdir -p debug/elf

#zhangwenshengadd it by meet jiangyuelong request
cp -rvf $LOG_AMSS ${LOCAL_OUT}/debug

cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/*.img ${LOCAL_OUT}/android_result
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/*.mbn ${LOCAL_OUT}/android_result
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/*.bat ${LOCAL_OUT}/android_result
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/*.sh ${LOCAL_OUT}/android_result
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/*.zip ${LOCAL_OUT}/ota
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/obj/PACKAGING/target_files_intermediates/*.zip ${LOCAL_OUT}/ota
#FIXME copy a stable emmc_appboot.mbn for sign failture in new server
#cp -rvf $SCRIPT_PATH/../emmc_appsboot.mbn ${LOCAL_OUT}/android_result
    echo -e "\n========== begin to pull jar... ========="
    INTER_DIR=$MSM_ENV/out/target/common/obj
    inter_zipname=${LOCAL_OUT}/debug/intermediates_jar
    ALL_DIR=`find $INTER_DIR -name "*_intermediates"`
    DEBUG_JAR=classes-full-debug.jar
    mkdir -p $inter_zipname
    for dd in $ALL_DIR
    {
        bname=${dd%_intermediates}
        jar_name=`basename $bname`.jar
        if [ -f $dd/$DEBUG_JAR ]; then cp -f $dd/$DEBUG_JAR  $inter_zipname/${jar_name}; fi
    }


echo -e "\n=======2.copy bsp and modem build result=========="
cp -rvf ${MSM_ENV}/AMSS/out/bin/* ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/out/elf/* ${LOCAL_OUT}/debug/elf
#zhangwenshengadd it by meet jiangyuelong request 2017-12-14
mkdir -p ${LOCAL_OUT}/debug/elf/wcnss_proc/build/ms
cp -rvf ${MSM_ENV}/AMSS/wcnss_proc/build/ms/8953*.elf  ${LOCAL_OUT}/debug/elf/wcnss_proc/build/ms
#end add  2017-12-14

echo -e "\n=======3.copy all result to server============="

SUCESS_FLAG=`grep '^SUCESS_FLAG' $SCRIPT_DIR/sucess_flag.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`
echo -e "\n========SUCESS_FLAG:${SUCESS_FLAG}========="
cd ${OUT_SERVER}
if [ $SUCESS_FLAG = 1 ] ; then
mkdir flash
mkdir qfil
mkdir ota
fi
mkdir Configurations
mkdir debug
if [ $SUCESS_FLAG = 1 ] ; then
cp -rf ${LOCAL_OUT}/android_result/* ${OUT_SERVER}/flash
cp -rf ${LOCAL_OUT}/bsp_result/* ${OUT_SERVER}/flash
cp -rf ${LOCAL_OUT}/ota/* ${OUT_SERVER}/ota
cp -rvf $SCRIPT_PATH/../${BRANCH}/*.xml ${LOCAL_OUT}/Configurations
cp -rf ${LOCAL_OUT}/android_result/* ${OUT_SERVER}/qfil
fi

cp -rvf ${MSM_SHARE}/CR_List_diff.txt ${LOCAL_OUT}/Configurations
cp -rvf ${MSM_SHARE}/maillist.txt ${LOCAL_OUT}/Configurations
cp -rvf ${MSM_ENV}/device/zeusis/Y3/xtt/*.xtt ${LOCAL_OUT}/Configurations
cp -rvf ${MSM_ENV}/AMSS/common/build/gpt_backup0.bin ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/common/build/gpt_main0.bin ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/common/build/patch0.xml ${LOCAL_OUT}/bsp_result
if [ "$ISFACTORY" = "FALSE" ] ; then
#  cp -rvf ${MSM_ENV}/AMSS/common/build/rawprogram0.xml ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/common/build/bin/asic/sparse_images/sparse_no_persist/rawprogram0.xml ${LOCAL_OUT}/bsp_result
else
  cp -rvf ${MSM_ENV}/AMSS/common/build/bin/asic/sparse_images/rawprogram0.xml ${LOCAL_OUT}/bsp_result
fi
cp -rvf ${MSM_ENV}/AMSS/about.html ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/modem_proc/FSG/${PROJECT_NAME}/fs_image.tar.gz.mbn_*.img ${MSM_ENV}/AMSS/modem_proc/FSG/fs_image.tar.gz.mbn.img
cp -rvf ${MSM_ENV}/AMSS/modem_proc/FSG/fs_image.tar.gz.mbn.img ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/modem_proc/FSG ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/boot_images/core/storage/tools/ptool/checksparse.py ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/boot_images/core/storage/tools/ptool/ptool.py ${LOCAL_OUT}/bsp_result
cp -rvf ${MSM_ENV}/AMSS/common/sectools/8953_sign/Y3_fuse_sec_dat/*  ${LOCAL_OUT}/bsp_result
if [ $SUCESS_FLAG = 1 ] ; then
cp -rf ${LOCAL_OUT}/bsp_result/* ${OUT_SERVER}/qfil

cd ${OUT_SERVER}/debug
mkdir obj
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/obj/KERNEL_OBJ/vmlinux obj
fi
cp -rf ${LOCAL_OUT}/Configurations/*  ${OUT_SERVER}/Configurations
cp -rvf ${MSM_ENV}/out/target/product/${PROJECT_NAME}/obj/KERNEL_OBJ/.config ${OUT_SERVER}/Configurations
cp -rf ${LOCAL_OUT}/debug/* ${OUT_SERVER}/debug
cp -rvf ${MSM_ENV}/${PROJECT_NAME}.log ${OUT_SERVER}
cp -rvf ${MSM_ENV}/${PROJECT_NAME}.log $EMAIL_CONFIG
if [ $SUCESS_FLAG = 1 ] ; then
cd ${OUT_SERVER}/qfil
if [ "$ISFACTORY" = "TRUE" ] ; then
cp -rf ${MSM_ENV}/device/zeusis/Y3/modem/* .
fi
mkdir temp
cp -rf recovery.img temp
cd temp
mv recovery.img recoverybp.img
mv recoverybp.img ../
cd ..
rm -rf temp
cd ${OUT_SERVER}/qfil
python checksparse.py -i rawprogram0.xml  -o rawprogram_unsparse.xml -s ${OUT_SERVER}/qfil
    if [ $? = 0 ];then
        rm -rf checksparse.py
        rm -rf ptool.py
        #delete redundant files
        RM_ITEM="cust.img userdata.img cust.img system.img"
        a=(${RM_ITEM})
        for var in ${a[@]};do echo $var;rm $var ;done
    else
       echo "分包错误"
       exit 1
    fi
fi
fi

#ready for to send email
if [ $SUCESS_FLAG = 0 ] ; then
EMAIL_SUBJECT="${PROJECT_NAME} project ${BRANCH}"
temp=`grep '^ERROR_SUBJECT' $EMAIL_CONFIG/body_template | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_SUBJECT="$EMAIL_SUBJECT $temp ${VERSION_DIR}"
else
EMAIL_SUBJECT="${PROJECT_NAME} project ${BRANCH}"
temp=`grep '^SUCESS_SUBJECT' $EMAIL_CONFIG/body_template | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_SUBJECT="$EMAIL_SUBJECT $temp ${VERSION_DIR}"
fi
echo -e "EMAIL_SUBJECT=$EMAIL_SUBJECT" > $EMAIL_CONFIG/emailBody

EMAIL_CONTENT=`grep '^EMAIL_CONTENT_OUT' $EMAIL_CONFIG/body_template | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_CONTENT="$EMAIL_CONTENT $EMAIL_OUT_SERVER"
echo -e "EMAIL_CONTENT=$EMAIL_CONTENT" >> $EMAIL_CONFIG/emailBody

#EMAIL_CONTENT_HUDSON
EMAIL_CONTENT_HUDSON=`grep '^EMAIL_CONTENT_HUDSON' $EMAIL_CONFIG/body_template | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_CONTENT_HUDSON="$EMAIL_CONTENT_HUDSON $BUILD_URL"
echo -e "EMAIL_CONTENT_HUDSON=$EMAIL_CONTENT_HUDSON" >> $EMAIL_CONFIG/emailBody
bash $EMAIL_PATH/email.sh
cd ${SCRIPT_PATH}
rm -rf  ${SCRIPT_DIR}/../${BRANCH_NAME}/build_is_work
