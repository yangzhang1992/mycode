#! /bin/bash
#gen release note by Snapshot_XML

STEP=$1
export SCRIPT_PATH=/home/system1/build_script_INT/common_script
DATE=`date +%Y%m%d%H%M`

export src_path=/home/system1/JV_Y3/Upgrade_zeusis
REPO_CMD=/home/system1/repo/repo
export INT_FLOAD=${src_path}/coolyota_newint

export BRANCH=coolyota_msm8953_newint
PATH_SNAPSHOT=/home/release/y3/ReleaseNote/Manifest_static
PATH_RESULT=/home/release/y3/ReleaseNote/DailyRecord
Int_DATE=`date +%y%m%d`
set -x

function download_int_code {

if [ ! -d $INT_FLOAD ] ; then  mkdir -p $INT_FLOAD;else "int is exist!" ;fi
cd $INT_FLOAD
pwd

$REPO_CMD init -u ssh://172.16.7.25:29418/COOLYOTA/.repo/manifests -b default -m coolyota/coolyota_msm8953_newint.xml  --no-repo-verify

if [ $? != '0' ] ;then echo "*** error when repo init ..." && exit 1; fi
echo -e "repo sync code ......\n"
$REPO_CMD sync -q -j16

$REPO_CMD manifest -o $INT_FLOAD/Y3INT_${Int_DATE}.xml -r
rm version-change.xls
}

download_int_code

if [  -f ${PATH_SNAPSHOT}/Y3INT_${Int_DATE}.xml ] ; then "xml exist!";rm  ${PATH_SNAPSHOT}/Y3INT_${Int_DATE}.xml ;fi

cd $PATH_SNAPSHOT/
LAST_XML=Y3`ls -lt *.xml |head -1 |awk -F "Y3"  '{print $2}'`

LAST_XML=$PATH_SNAPSHOT/$LAST_XML
NOW_XML=$INT_FLOAD/Y3INT_${Int_DATE}.xml

if [  -f $NOW_XML ] ; then "now.xml ok";else exit 1 ;fi
if [  -f $LAST_XML ] ; then "LAST_XML ok";else  exit 1 ;fi

NAME_ST=F`basename $LAST_XML | sed 's/.xml//g' | awk -F "_" '{print $2}' `
NAME_ND=T`basename $NOW_XML | sed 's/.xml//g' | awk -F "_" '{print $2}' `
RESULT_FILE=ReleaseNote_${NAME_ST}_${NAME_ND}.xls

cd $SCRIPT_PATH
python genRelease.py  $LAST_XML $NOW_XML $INT_FLOAD
if [ $? -ne 0 ];then
	echo "Fail:gen release_note---LAST_XML:${NAME_ST}---CURR_XML:${NAME_ND}"
	exit 1
else
	echo "SUCESS:gen release_note---LAST_XML:${NAME_ST}---CURR_XML:${NAME_ND} "
fi

#cp  ${NOW_XML}  $PATH_SNAPSHOT

#cd $SCRIPT_PATH

cd $INT_FLOAD
mv ${NOW_XML}  $PATH_SNAPSHOT
cp version-change.xls $PATH_RESULT/$RESULT_FILE
cd /home/system1/build_script_INT/common_script
