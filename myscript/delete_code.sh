#!/bin/bash
# for upgrade spreadtrum code

TARGET_RELEASE_DIR=~/projects/MR1-FullBuild/spreadtrum_sc7731e

for f in `cat delete_except_git.list`;
do
  echo $f
    #dirPath = `dirname $f`
    #if [ ! -d $dirPath ]; then
    #  mkdir -p $dirPath
    #fi
  cd $TARGET_RELEASE_DIR/$f
  rm -rf *
    
  if [ $? != 0 ]; then
    echo "rm $f code error!"
    return 1
  fi
done
