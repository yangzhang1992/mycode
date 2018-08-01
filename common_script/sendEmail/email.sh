#! /bin/bash

EMAIL_TOOL_PATH=/home/system1/build_script_HBZ/common_script/sendEmail
CONFIG_PATH=/home/system1/build_script_HBZ/common_script/sendEmail/jv_config
TO_NAME_LIST=$CONFIG_PATH/toNameList
CC_NAME_LIST=$CONFIG_PATH/ccNameList
FROM_NAME=`grep '^FROM_NAME' $CONFIG_PATH/config | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_SUBJECT=`grep '^EMAIL_SUBJECT' $CONFIG_PATH/emailBody | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_CONTENT=`grep '^EMAIL_CONTENT' $CONFIG_PATH/emailBody | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_CONTENT_HUDSON=`grep '^EMAIL_CONTENT_HUDSON=' $CONFIG_PATH/emailBody | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
EMAIL_SMTP=`grep '^EMAIL_SMTP' $CONFIG_PATH/config | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
AUTH_USER=`grep '^AUTH_USER' $CONFIG_PATH/config | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
AUTH_PASSWORD=`grep '^AUTH_PASSWORD' $CONFIG_PATH/config | awk -F =  '{print $2}' | tr -d " "| tr -d "\r"`
echo $FROM_NAME
echo $EMAIL_SUBJECT
echo $EMAIL_CONTENT
echo $EMAIL_CONTENT_HUDSON
echo $EMAIL_SMTP
echo $AUTH_USER
echo $AUTH_PASSWORD
TEMP_CMD="-f $FROM_NAME"
while read line
do
TEMP_CMD="$TEMP_CMD -t $line"

done < $TO_NAME_LIST

while read line
do
TEMP_CMD="$TEMP_CMD -cc $line"
done < $CC_NAME_LIST

TEMP_CMD="$TEMP_CMD -u $EMAIL_SUBJECT"
TEMP_CMD="$TEMP_CMD -m $EMAIL_CONTENT \n $EMAIL_CONTENT_HUDSON"

TEMP_CMD="$TEMP_CMD -s $EMAIL_SMTP"

#TEMP_CMD="$TEMP_CMD -xu $AUTH_USER"
#TEMP_CMD="$TEMP_CMD -xp $AUTH_PASSWORD"

if [ -f $CONFIG_PATH/CR_List_diff.txt ] ; then
TEMP_CMD="$TEMP_CMD -a $CONFIG_PATH/CR_List_diff.txt"
fi

#if [ -f $CONFIG_PATH/amss_build_log.txt ] ; then
#TEMP_CMD="$TEMP_CMD -a $CONFIG_PATH/amss_build_log.txt"
#fi

#if [ -f $CONFIG_PATH/Y3.log ] ; then
#TEMP_CMD="$TEMP_CMD -a $CONFIG_PATH/Y3.log"
#fi

TEMP_CMD="$TEMP_CMD -o tls=no"
#TEMP_CMD="$TEMP_CMD -o message-charset=UTF8"
TEMP_CMD="$TEMP_CMD -o message-charset=UTF-8"

FINAL_CMD=$TEMP_CMD
echo ======email cmd is:perl $EMAIL_TOOL_PATH/sendEmail.pl $FINAL_CMD=======
perl $EMAIL_TOOL_PATH/sendEmail.pl $FINAL_CMD

if [ $? = 0 ] ; then
echo ========send email sucess========
else
echo ========send email fail=========
fi

 
