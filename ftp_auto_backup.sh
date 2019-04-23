#!/bin/sh
####################################################################################################
#
# Made by yummyHit
#
####################################################################################################
# 1. .forward_backup.txt file is execute ftp auto backup in /root/work
#    If this file doesn't exist, it read user input. Therefore, be careful when using scheduled jobs.
####################################################################################################
# 2. This script read ftp server username, password. The input information is encoded and stored as 
#    a file. And server IP, the path to the file you want to send, the path to the file you want to
#    receive. Now, make .forward_backup.txt file.
#    If your input is incorrect, you must remove .forward_backup.txt file and re-start script.
####################################################################################################
# 3. This script assume a backup file format "backup_YYYYMMDD_whatelse.tar.gz"
#    All of error write to /root/work/forward.log file.
####################################################################################################
# 4. username and password information aren't remain in /root/work/.forward_backup.txt file.
####################################################################################################

SED_CMD=`which sed 2>/dev/null| grep bin | sed -e 's/^ *//g' -e 's/^\t*//g'` 
GREP_CMD=`which grep 2>/dev/null | grep bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
CAT_CMD=`which cat 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
EGREP_CMD=`which egrep 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
LS_CMD=`which ls 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
AWK_CMD=`which awk 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
RM_CMD=`which rm 2>/dev/null | $GREP_CMD -bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
BASE64_CMD=`which base64 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
UUENCODE_CMD=`which uuencode 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`
UUDECODE_CMD=`which uudecode 2>/dev/null | $GREP_CMD bin | $SED_CMD -e 's/^ *//g' -e 's/^\t*//g'`

USRNAME_FILE="/root/work/.ftp_name"
USRPWD_FILE="/root/work/.ftp_pw"

if [ ! -f "$USRNAME_FILE" ] || [ ! -f "$USRPWD_FILE" ]; then
	echo "This will only be done once at the beginning."
	printf "Input FTP Username(such as root): "
	read USRNAME
	printf "Input FTP Password(such as test): "
	read USRPWD
	if [ "$BASE64_CMD" != "" ]; then
		echo $USRNAME | $BASE64_CMD > $USRNAME_FILE
		echo $USRPWD | $BASE64_CMD > $USRPWD_FILE
	elif [ "$UUENCODE_CMD" != "" ]; then
		echo $USRNAME | $UUENCODE_CMD $USRNAME_FILE\.tmp > $USRNAME_FILE
		echo $USRPWD | $UUENCODE_CMD $USRNAME_FILE\.tmp > $USRPWD_FILE
	else
		echo "encode command not found. please install base64 or uuencode package"
		exit 127;
	fi
	printf "Input Windows Server IP(such as 192.168.100.100): "
	read SRV_IP
	printf "Input log directory(such as /log/path): "
	read LOG_DIR
	printf "Input server backup directory(such as /backup/log/path or C:\\\\\\Users\\\\\\\\test\\\\\\path\\\\\\log): "
	read BAK_DIR
	if [ "`echo $BAK_DIR | $GREP_CMD \\\\`" != "" ]; then
		BAK_DIR=`echo $BAK_DIR | $SED_CMD -e 's/\\\\/\\\\\\\\/g'`
	fi
	flag="on";
fi

BFILE="backup_`date +%Y%m%d`"
FORWARD_FILE="/root/work/.forward_backup.txt"
LOG_FILE="/root/work/forward.log"
TMP_FILE="/root/work/forward.log.tmp"

get_user()
{
	if [ "$BASE64_CMD" != "" ]; then
		USRNAME=`$CAT_CMD $USRNAME_FILE | $BASE64_CMD -d 2>/dev/null`
		if [ $? -ne 0 ]; then
			USRNAME=`$CAT_CMD $USRNAME_FILE | $BASE64_CMD -D 2>/dev/null`
		fi
		USRPWD=`$CAT_CMD $USRPWD_FILE | $BASE64_CMD -d 2>/dev/null`
		if [ $? -ne 0 ]; then
			USRPWD=`$CAT_CMD $USRPWD_FILE | $BASE64_CMD -D 2>/dev/null`
		fi
	fi

	if ([ "$USRNAME" = "" ] || [ "$USRPWD" = "" ]) && [ "$UUDECODE_CMD" != "" ]; then
		$CAT_CMD $USRNAME_FILE | $UUDECODE_CMD $USRNAME_FILE 2>/dev/null
		$CAT_CMD $USRPWD_FILE | $UUDECODE_CMD $USRPWD_FILE 2>/dev/null
		USRNAME=`$CAT_CMD $USRNAME_FILE\.tmp 2>/dev/null`
		USRPWD=`$CAT_CMD $USRPWD_FILE\.tmp 2>/dev/null`
		$RM_CMD -f $USRNAME_FILE\.tmp $USRPWD_FILE\.tmp
	fi

	if [ "$USRNAME" = "" ] || [ "$USRPWD" = "" ]; then
		echo "`date`::: FTP user name or password has error. please remove .ftp_name, .ftp_pw files" >> $LOG_FILE
		exit 127;
	fi
}

if [ "$flag" = "on" ]; then
	echo "
open $SRV_IP 21
user
lcd $LOG_DIR
cd $BAK_DIR
bin
mput $BFILE*.tar.gz
quit
" > $FORWARD_FILE
	exit 127;
fi

if [ ! -f "$FORWARD_FILE" ]; then
	echo "`date`::: ftp auto script file not found. remove files and re-execute this script for initialize" >> $LOG_FILE
	$RM_CMD -f $USRNAME_FILE $USRPWD_FILE
	exit 127;
fi

if [ "$LS_CMD" != "" ] && [ -f "$FORWARD_FILE" ]; then
	get_user
	if [ "$USRNAME" != "" ] && [ "$USRPWD" != "" ]; then
		$SED_CMD -i 's/^user$/user '$USRNAME' '$USRPWD'/g' $FORWARD_FILE
	else
		echo "`date`::: FTP user name or password has error. please remove .ftp_name, .ftp_pw files" >> $LOG_FILE
		exit 127;
	fi

	today=`date +%Y%m%d`
	directory=`$CAT_CMD $FORWARD_FILE | $GREP_CMD ^lcd | $AWK_CMD '{print $NF}'`
	check=`$LS_CMD -t $directory 2>/dev/null | $GREP_CMD $today | $AWK_CMD 'NR == 1{print}'`
	if [ "$check" != "" ]; then
		$SED_CMD -i 's/^mput\ .*\.tar.gz$/mput '$BFILE'*.tar.gz/g' $FORWARD_FILE
		ftp -n < $FORWARD_FILE > $TMP_FILE 2>&1
		$SED_CMD -i 's/^user\ .*/user/g' $FORWARD_FILE
	else
		$SED_CMD -i 's/^user\ .*/user/g' $FORWARD_FILE
		echo "`date`::: backup file not found" >> $LOG_FILE
		exit 127;
	fi
fi

if [ "$CAT_CMD" != "" ] && [ "$EGREP_CMD" != "" ] && [ -f "$TMP_FILE" ]; then
	check=`$CAT_CMD $TMP_FILE | $EGREP_CMD "Invalid|Login\ incorrect|Login\ failed|Not\ connect|550 Failed"`
	if [ "$check" != "" ]; then
		echo "`date`::: Forward backup files failed with ftp cuz .." >> $LOG_FILE
		echo "$check" >> $LOG_FILE
	fi
	$RM_CMD -f $TMP_FILE
fi
