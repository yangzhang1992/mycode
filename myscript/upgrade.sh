#!/bin/bash
# for upgrade spreadtrum code

TARGET_RELEASE_DIR=~/projects/spreadtrum_sc7731e

for f in `cat upgrade_code.list`;
do
  echo $f
  cd $TARGET_RELEASE_DIR/$f
  rm -rf .gitignore
  git add .
  git commit -s -m "upgrade_spreadtrum_code"
  git push yota HEAD:spreadtrum_sc7731e 
    
  if [ $? != 0 ]; then
    echo "upgrede $f code error!"
    return 1
  fi
done
