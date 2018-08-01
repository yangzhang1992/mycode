#!/bin/bash
# check differents
# output maillist
# check refs/for

function usage {
	echo  "   Build different files from two config xml files"
	echo  "   usage $0  [-esonph]"
	echo  "   -e: Int enviroment name."
	echo  "   -s: share win path."
	echo  "   -o: Old config full file name."
	echo  "   -n: New config full file name."
	echo  "   -p: Project name."
	echo  "   -h: display help information."
	echo  " "
	exit 2
}

while  getopts e:s:o:n:p:h opt
do
	case $opt in
	o) OLD_CFG="${OPTARG}";;
	n) NEW_CFG="${OPTARG}";;
	h) usage ;;
	*) echo "option do not exist."
	usage ;;
	esac
done

echo -e "\n======================================================================================================"

MAKE_RESULT=`grep '^MAKE_RESULT' $BUILD_RESULT | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
echo MAKE_RESULT=$MAKE_RESULT
echo -e "MSM_ENV\t\t: $MSM_ENV"
echo -e "MSM_SHARE\t: $MSM_SHARE"
echo -e "MAKE_RESULT\t: $MAKE_RESULT"

SIMPLE_INFO=$MSM_SHARE/simple_diff_$PROJECT_NAME.txt
echo -e "SIMPLE_INFO\t: $SIMPLE_INFO"
DETAIL_INFO=$MSM_SHARE/CR_List_diff.txt
DETAIL_FORM=$MSM_SHARE/CR_Form_diff.txt
echo -e "DETAIL_INFO\t: $DETAIL_INFO"
TMP_FILE=$MSM_SHARE/xml_tmp_$PROJECT_NAME.diff
echo -e "TMP_FILE\t: $TMP_FILE"
MAIl_LIST=$MSM_SHARE/maillist.txt
MAIl_LIST_TEMP=$MSM_SHARE/maillist_temp.txt
echo -e "MAIl_LIST\t: $MAIl_LIST"

echo -e "======================================================================================================\n"

diff $NEW_CFG $OLD_CFG >| $TMP_FILE
rm -rf $OLD_CFG
if [ -s $TMP_FILE ];then
	echo -e "===================$PROJECT_NAME Code Updated====================\n"
else
	if [ "$REBUILDTYPE" = "Clean" ]; then
		echo -e "===================Clean build====================\n"
		exit 0
	else
		echo -e "=================$PROJECT_NAME Code Not Updated==================\n"
		if [ $CHANGE_VARIANT = "true" ] ; then
                  echo -e "build module  have change, so build it " 
                  exit 0
                else
                  exit 1
                fi
	fi
fi

if [ a"$MAKE_RESULT" = a"success" ]
then
	echo "rm $SIMPLE_INFO $DETAIL_INFO $MAIl_LIST"
	rm -f $SIMPLE_INFO $DETAIL_INFO $DETAIL_FORM $MAIl_LIST
	touch $SIMPLE_INFO $DETAIL_INFO $DETAIL_FORM
else
	FAIL_AMOUNT=`grep '^FAIL_AMOUNT' $BUILD_RESULT | awk -F :=  '{print $2}' | tr -d " "| tr -d "\r"`
	echo -e "\n---------------------------------------------------------------------" >> $DETAIL_INFO
	echo -e "\n      $FAIL_AMOUNT times: `date +%Y.%m.%d-%H.%M`" >> $DETAIL_INFO
	echo -e "\n---------------------------------------------------------------------" >> $DETAIL_INFO
fi

# revert output a file
#nl $TMP_FILE_A | sort -nr | cut -f2 > $TMP_FILE_D
while read line
do

	NAME=`echo $line | grep ^\< |awk -F "name=" '{print $2}' | awk -F " " '{print $1}' | tr -d '\"' | sed -r 's/\/$//'`
	REV=`echo $line | grep ^\< |awk -F "revision=" '{print $2}' | awk -F " " '{print $1}' | tr -d '\"'`
	revision=`cat $TMP_FILE | grep ^\> | grep "${NAME}" | awk -F "revision=" '{print $2}' | tr -d '\"' | tr -d '\>' | tr -d '\/' | tr -d '\-\-' | tr -d ["\n"]`
    
	if [ "$NAME" = "" ] || [ "$REV" = "" ] ; then continue ; fi

	FLAG=`cat $SIMPLE_INFO | grep $NAME`
	if [ "$FLAG" != "" ] ; then continue ; fi
	echo "$NAME $REV" >> $SIMPLE_INFO

	echo -e "\n---------------------------------------------------------------------" >> $DETAIL_INFO
	echo -e "\n---------------------------------------------------------------------" >> $DETAIL_FORM
	echo -e "*** $NAME\n" >> $DETAIL_INFO
	echo -e "*** $NAME\n" >> $DETAIL_FORM
	cd $MSM_ENV/$NAME
	git show ${revision:0:40}...${REV:0:40} --raw >> $DETAIL_INFO

	git log --oneline | grep -e "AndDB" -e "TFS" >> $MSM_SHARE/CR_List_full_temp.txt
	git show ${revision:0:40}...${REV:0:40} -s --format=%ce >> $MAIl_LIST_TEMP
	
	j=`git log ${revision:0:40}..${REV:0:40} --oneline | wc -l`
	echo -e "id       name          time                 message"  >> $DETAIL_FORM
	for (( i=1; i<=j; i=i+1 ))
	do
        log_short_id=`git log ${revision:0:40}..${REV:0:40} --oneline | awk -F " " '{print $1}' | sed -n ${i}p`
		author_name=`git log ${revision:0:40}..${REV:0:40} -s --format=%an | sed -n ${i}p`
		time_short=`git log ${revision:0:40}..${REV:0:40} -s --format=%ci | awk -F "+" '{print $1}' | sed -n ${i}p`
		title=`git log ${revision:0:40}..${REV:0:40} --oneline | sed -n ${i}p`
		printf "%-9s" "$log_short_id"   >> $DETAIL_FORM
		printf "%-14s" "$author_name"   >> $DETAIL_FORM
		printf "%-21s" "$time_short"    >> $DETAIL_FORM
		printf "%-100s" "${title:8:100}"   >> $DETAIL_FORM
		echo ""  >> $DETAIL_FORM
	done

	#DEL_FILE_INFO=`git show ${revision:0:40}...${REV:0:40} --raw | grep "0000000... D" | awk '{print $NF}'`
	#path1=`pwd | awk -F 'my_code/yulong/' '{print $2}' | tr -d " "| tr -d "\r"`
	#for ff in $DEL_FILE_INFO
	#{
	#	dst=$path1/$ff
	#	echo dst=$dst
	#	echo $dst >> $DEL_FILE
	#}
done < $TMP_FILE

cat $MSM_SHARE/CR_List_full_temp.txt | awk -F ":" '{print $1}' | awk -F " " '{print $2}' | tr -d 'Merge' | sed '/^$/d' | sort | uniq | tr -d '\"' >> $MSM_SHARE/CR_List_full.txt
rm $MSM_SHARE/CR_List_full_temp.txt
echo "changes list:"
echo "------------------------------------------------------------------------------------------------------"
cat $DETAIL_INFO
echo -e "------------------------------------------------------------------------------------------------------\n"

#rm -rf $MSM_SHARE/*.diff
#rm -rf $MSM_SHARE/*.xml
rm -vf $SIMPLE_INFO
cp -f $NEW_CFG $OLD_CFG

cat $MAIl_LIST_TEMP | sort -u | grep -v gerrit | grep -v system >> $MAIl_LIST
rm -f $MAIl_LIST_TEMP
exit 0
