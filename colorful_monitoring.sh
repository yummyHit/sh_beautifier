#!/bin/sh
# ----------------------------------
# made by yummyHit
# ----------------------------------
# Shell script; when monitoring with tail -f command, specific string makes colorful
# ----------------------------------
# Input parameters
# $1 = file path that monitoring
# $2 = specific string
# $3 = select color (default: RED)
# $4 = optional fonts (default: BOLD)
# ----------------------------------
# ex) ./colorful_monitoring.sh /var/log/test.log "What is" PURPLE
# ----------------------------------

if [ $# -lt 2 ]; then
	echo "Usage: $0 <File Name> <String> [ Color ] [ Font ]"
	echo "       ex) ./colorful_monitoring.sh /var/log/test.log \"What is\" PURPLE"
	echo "       Must keep options ordering"
	echo
	echo "       Color and Font is optional. default Color is Red, default Font is BOLD"
	echo "       Color and Font can select only one. Can't mixed it"
	echo
	echo "       Color List: BLACK, RED, GREEN, YELLOW, BLUE, PURPLE, CYAN, WHITE"
	echo "       Font List: BOLD, UNDERLINE"
	exit
fi

FILENAME="$1"
STRING="$2"
COLOR="$3"

if [ "$4" = "UNDERLINE" ]; then
	OPTIONS="4"
else
	OPTIONS="1"
fi

COLORLIST="BLACK|RED|GREEN|YELLOW|BLUE|PURPLE|CYAN|WHITE"
DEFAULT="0"

if [ ! -f "$FILENAME" ]; then
	echo "No such file or path"
	exit
fi

echo "Get File Name is $FILENAME!!"
echo "Find String is $STRING!!"

if [ `echo $COLORLIST | grep $COLOR | wc -l` -eq 1 ]; then
	echo "Selected Color is $COLOR!!"
fi

case $COLOR in
	BLACK)
		COLOR_STR="\033[$OPTIONS;90m$STRING\033[$DEFAULT;99m"
		;;
	RED)
		COLOR_STR="\033[$OPTIONS;91m$STRING\033[$DEFAULT;99m"
		;;
	GREEN)
		COLOR_STR="\033[$OPTIONS;92m$STRING\033[$DEFAULT;99m"
		;;
	YELLOW)
		COLOR_STR="\033[$OPTIONS;93m$STRING\033[$DEFAULT;99m"
		;;
	BLUE)
		COLOR_STR="\033[$OPTIONS;94m$STRING\033[$DEFAULT;99m"
		;;
	PURPLE)
		COLOR_STR="\033[$OPTIONS;95m$STRING\033[$DEFAULT;99m"
		;;
	CYAN)
		COLOR_STR="\033[$OPTIONS;96m$STRING\033[$DEFAULT;99m"
		;;
	WHITE)
		COLOR_STR="\033[$OPTIONS;97m$STRING\033[$DEFAULT;99m"
		;;
	*)
		COLOR_STR="\033[$OPTIONS;91m$STRING\033[$DEFAULT;99m"
		;;
esac

tail -f $FILENAME | awk '{if($0 ~ /'$STRING'/) {gsub(/'$STRING'/,"'$COLOR_STR'")}} {print}'
