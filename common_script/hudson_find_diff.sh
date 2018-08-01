

#! /bin/bash
#get the last sync time
EXIT_CODE=1
#exit 0
cd $SCRIPT_DIR
if [ -f $SCRIPT_DIR/sync_time_back.txt ] ; then
rm -rf $SCRIPT_DIR/sync_time.txt
mv $SCRIPT_DIR/sync_time_back.txt $SCRIPT_DIR/sync_time.txt
fi

#YMD_LAST_SYNC_TIME=`grep '^YMD_SYNC_TIME' $SCRIPT_DIR/sync_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`

YEA=`grep '^YEA' $SCRIPT_DIR/sync_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`
MON=`grep '^MON' $SCRIPT_DIR/sync_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`
DAY=`grep '^DAY' $SCRIPT_DIR/sync_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`

if [ $DAY = 1 ] || [ "$DAY" = "01" ]  ; then
 if [ $MON = 1 ] || [ "$MON" = "01" ] ; then
    let YEA=10#${YEA}-1
    MON=12
    DAY=31
 else
    let MON=10#${MON}-1
    DAY=28
 fi
else
 let DAY=10#${DAY}-1
fi

export YMD_LAST_SYNC_TIME=${YEA}-${MON}-${DAY}
export LAST_SYNC_TIME=`grep '^SYNC_TIME' $SCRIPT_DIR/sync_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`

if [ -f $SCRIPT_DIR/build_time_back.txt ] ; then
rm -rf $SCRIPT_DIR/build_time.txt
mv $SCRIPT_DIR/build_time_back.txt $SCRIPT_DIR/build_time.txt
fi

export YMD_LAST_BUILD_TIME=`grep '^YMD_BUILD_TIME' $SCRIPT_DIR/build_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`
export LAST_BUILD_TIME=`grep '^BUILD_TIME' $SCRIPT_DIR/build_time.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`

SUCESS_FLAG=`grep '^SUCESS_FLAG' $SCRIPT_DIR/sucess_flag.txt | awk -F :  '{print $2}' | tr -d " "| tr -d "\r"`

echo -e "YMD_LAST_SYNC_TIME:$YMD_LAST_SYNC_TIME"
echo -e "LAST_SYNC_TIME:$LAST_SYNC_TIME"
echo -e "LAST_BUILD_TIME_YMD:$YMD_LAST_BUILD_TIME"
echo -e "LAST_BUILD_TIME:$LAST_BUILD_TIME"
echo -e "SUCESS_FLAG:$SUCESS_FLAG"

if [ $SUCESS_FLAG = 1 ] ; then
rm -rf $SCRIPT_DIR/maillist.txt
rm -rf $SCRIPT_DIR/CR_List_diff.txt

rm -rf $MSM_SHARE/maillist.txt
fi

cd $MSM_ENV
echo -e "~/repo/repo forall -c git log --pretty=format:"%H-%an-%ae-%at-%ai-%s" remotes/yulong/$BRANCH --name-status --after $YMD_LAST_SYNC_TIME >$SCRIPT_DIR/_temp_git_log.txt"
~/repo/repo forall -c git log --pretty=format:"%H-%an-%ae-%at-%ai-%s" remotes/yulong/$BRANCH --name-status --after $YMD_LAST_SYNC_TIME >$SCRIPT_DIR/_temp_git_log.txt
# read every line
cd $SCRIPT_DIR
cat $SCRIPT_DIR/_temp_git_log.txt | grep "@" > $SCRIPT_DIR/_temp_search_log.txt
notprint=0
while read line
do
if [ "$line" != "" ] ; then
searchresult=`cat $SCRIPT_DIR/_temp_search_log.txt | grep "$line" `
if [ "$searchresult" != "" ] ; then
echo $line > $SCRIPT_DIR/_temp_search_final_log.txt
comtime=`awk -F "-" '{print $4}' $SCRIPT_DIR/_temp_search_final_log.txt`
#echo -e " $comtime"
    if [ $comtime -lt $LAST_SYNC_TIME ] ; then
    notprint=1
    else
    notprint=0
    mailname=`awk -F "-" '{print $3}'  $SCRIPT_DIR/_temp_search_final_log.txt`
     echo $mailname >> $SCRIPT_DIR/maillist.txt
    fi
fi
fi
if [ $notprint = 0 ] ; then
echo $line >>$SCRIPT_DIR/CR_List_diff.txt
EXIT_CODE=0
fi
done < $SCRIPT_DIR/_temp_git_log.txt
if [ $EXIT_CODE = 0 ] ; then
cat $SCRIPT_DIR/CR_List_diff.txt
fi


#add by zhangwensheng 20170727 for del yotadevices email
#sed -i '/yotadevices/d'  $SCRIPT_DIR/maillist.txt
#end modify
cp -rf $SCRIPT_DIR/maillist.txt $MSM_SHARE
cp -rf $SCRIPT_DIR/CR_List_diff.txt $MSM_SHARE

./find_bsp_diff.sh
exit $EXIT_CODE
