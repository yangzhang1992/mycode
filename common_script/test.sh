#! /bin/bash

  source coolyota_build_script/version_number.sh
  let VERSION_NUM=10#${VERSION_NUM}+1
  if [ $VERSION_NUM -ge 10 ] ; then
     VERSION_NUM="0${VERSION_NUM}"
  else
     VERSION_NUM="00${VERSION_NUM}"
  fi
  echo -e "\n #! /bin/bash" > coolyota_build_script/version_number.sh
  echo -e "export VERSION_NUM=${VERSION_NUM}" >> coolyota_build_script/version_number.sh
