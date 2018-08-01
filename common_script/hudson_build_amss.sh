#! /bin/bash

BUILD_SCRIPT=`pwd`

if [ ! -f $LOG_AMSS  ] ; then
touch $LOG_AMSS
fi

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
cd $MSM_ENV/AMSS/build/tool

echo `ip addr`

if [ $ISFACTORY = "TRUE" ] ; then
./build.sh "" Y3 "" "" "" --factory $HW_VERSION  > $LOG_AMSS
else
./build.sh "" Y3 "" "" "" "" $HW_VERSION >$LOG_AMSS
fi

if [ $? != 0 ] ; then
cd $BUILD_SCRIPT
export VERSION_DIR=${VERSION_DIR}_amss_build_error
./hudson_copy_result.sh amss_error
exit 1
fi
