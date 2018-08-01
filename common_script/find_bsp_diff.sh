#!/bin/bash
log_list="
boot_images
adsp_proc
trustzone_images
rpm_proc
modem_proc
venus_proc
wcnss_proc
common
build
MSM8937/rpm_proc
MSM8937/venus_proc
MSM8940/common
cpe_proc
static_analysis
"
BSP_ROOT=$MSM_ENV/AMSS
rm -rf $SCRIPT_DIR/bsp_script/_temp_git_log.txt
rm -rf $SCRIPT_DIR/bsp_script/_temp_update_code.txt

for line in $log_list
do
 cd $BSP_ROOT
# echo -e "\n====git log ${line}====="
 if [ -d $line/.git ] ; then
   cd $BSP_ROOT/$line
   git log -1 --pretty=format:"%H-%an-%ae-%at-%ai-%s" remotes/yulong/$BRANCH >$SCRIPT_DIR/bsp_script/_temp_git_log.txt
   comtime=`awk -F "-" '{print $4}' $SCRIPT_DIR/bsp_script/_temp_git_log.txt`
   #echo -e " $comtime"
    if [ $comtime -lt $LAST_SYNC_TIME ] ; then
    echo "=====$line not update========"
    else
    echo "=====$line code update======="
    echo $line >> $SCRIPT_DIR/bsp_script/_temp_update_code.txt
    fi
 else
   echo "${line} have no .git. error"
   exit 1
 fi
done

FULL_BUILD=`cat $SCRIPT_DIR/bsp_script/_temp_update_code.txt | grep "common|build"`
#echo $FULL_BUILD
BOOT_BUILD=`cat $SCRIPT_DIR/bsp_script/_temp_update_code.txt | grep "boot_images"`
#echo $BOOT_BUILD
ADSP_BUILD=`cat $SCRIPT_DIR/bsp_script/_temp_update_code.txt | grep "adsp_proc"`
#echo $ADSP_BUILD
MODEM_BUILD=`cat $SCRIPT_DIR/bsp_script/_temp_update_code.txt | grep "modem_proc"`
#echo $MODEM_BUILD
RPM_BUILD=`cat $SCRIPT_DIR/bsp_script/_temp_update_code.txt | grep "rpm_proc"`
#echo $RPM_BUILD
TZ_BUILD=`cat $SCRIPT_DIR/bsp_script/_temp_update_code.txt | grep "trustzone_images"`
#echo $TZ_BUILD
