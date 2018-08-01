#!/bin/bash
#MSM_ENV=~/TEST_INT_ENV/mydroid/
cd $MSM_ENV
COMM_PATH=out/target/common/obj/JAVA_LIBRARIES
CLASS_JAR_LIST=class_jar_list.txt
ALL_JAR=

function make_class_file {
    echo "**********************MAKE CLASS FILES*************************"
    echo "**********************MAKE CLASS FILES*************************"
    echo "**********************MAKE CLASS FILES*************************"
    echo "**********************MAKE CLASS FILES*************************"
    echo "**********************MAKE CLASS FILES*************************"
    m $ALL_JAR -j16
}
OK_BUILD=`grep "Install system fs image: out/target/product/${PROJECT_NAME}/system.img" ${PROJECT_NAME}.log`
if [ "$OK_BUILD" != "" ] ; then
    while read line
    do
        jarname="${COMM_PATH}/${line}_intermediates/classes.jar"
        echo "$jarname"
        ALL_JAR="$ALL_JAR $jarname"
    done < $CLASS_JAR_LIST
    make_class_file
fi
