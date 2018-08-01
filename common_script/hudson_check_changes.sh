
#!/bin/bash
# fix gerrit bug

# 1- no update ; 0- find change
EXIT_CODE=1
sleep 5s

if [ "$REBUILDTYPE" = "Clean" ]; then
	echo "Clean pre build,wait about 20m..."
	cd $MSM_ENV
        make clobber
	echo -----------------------------------------
elif [ "$REBUILDTYPE" = "Light" ]; then
	echo " *** increase Build"
	if [ ! -d $MSM_ENV/out/target/product/${PROJECT_NAME} ]; then
		rm -rf $MSM_ENV/out/target/product/*
	fi
else
	echo "REBUILDTYPE error .." && exit 1
fi

echo -----------------------------------------
echo "code sync begin at `date +%Y.%m.%d-%H.%M`"
echo -----------------------------------------
set -x 



cd $MSM_ENV

echo -e "$REPO_CMD forall -c git reset --hard"
$REPO_CMD forall -c git reset --hard
echo -e "$REPO_CMD init -u $RMT_URL -b $MANIFEST_BRANCH -m $MAINFEST_CONFIG  --no-repo-verify"
$REPO_CMD init -u $RMT_URL -b $MANIFEST_BRANCH -m $MAINFEST_CONFIG --no-repo-verify
if [ $? != '0' ] ;then echo "*** error when repo init ..." && exit 1; fi
echo -e "repo sync code ......\n"
$REPO_CMD sync -q -j16

#if [ $? != 0 ] ; then
#echo -e "$REPO_CMD forall -c git reset --hard"
#$REPO_CMD forall -c git reset --hard
#$REPO_CMD sync -q -j16
#fi

if [ $? != '0' ] ;then echo "error when repo sync  ..." && exit 1; fi

if [ -f $MSM_ENV/.repo/manifest.xml ]
then
    cd $MSM_ENV
else
    echo "+++++  $BRANCH integrate enviroment is empty"
    exit 1
fi
echo -----------------------------------------
echo "code sync finished at `date +%Y.%m.%d-%H.%M`"
echo -----------------------------------------


echo -e "check update here"

cd $MSM_ENV
if [ -f $MSM_SHARE/${BRANCH}.xml ] ; then
rm -rvf $MSM_SHARE/${BRANCH}_old.xml
mv $MSM_SHARE/${BRANCH}.xml $MSM_SHARE/${BRANCH}_old.xml
$REPO_CMD manifest -r -o $MSM_SHARE/${BRANCH}.xml
cd $SCRIPT_DIR
./build_diff_files.sh -o $MSM_SHARE/${BRANCH}_old.xml -n $MSM_SHARE/${BRANCH}.xml
else
echo "=======no xml file=========="
$REPO_CMD manifest -r -o $MSM_SHARE/${BRANCH}.xml
fi
if [ $? = 0 ] ; then
EXIT_CODE=0
else
cd $SCRIPT_DIR
#rm -rf build_is_work
rm -rf ${SCRIPT_DIR}/../${BRANCH_NAME}/build_is_work
fi

if [ x${BUILD_SPECIAL_VERSION} != x"NX" ];then
EXIT_CODE=0  #modify by zhangwensheng  ,if code has no diff ,still run to next step ,means compileing do not stop ,it works only at compileing CTA and CMCC
fi

if [ $EXIT_CODE != 0 ] ; then
rm -rf  ${SCRIPT_DIR}/../${BRANCH_NAME}/build_is_work
fi

exit $EXIT_CODE
