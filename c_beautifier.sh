#!/bin/sh
# ----------------------------------
# made by yummyHit
# ----------------------------------
# Shell script beautifier
# ----------------------------------
# Input parameters
# $1 = file name
# $2 = output file name
# $3 = tab space
# ----------------------------------
# ex) ./c_beautifier.sh ~/test_beauty.c /home/yummyHit/output.c 10
# ----------------------------------
# !!! Warning !!!
# if curly brace is unmatched, it occur somewhere.
# ex) main() {
#     // }
#     }
# ----------------------------------

if [ "$#" -lt "1" ]; then
	echo "Usage: $0 <File Name> [ Output File Name ] [ Tab space ]"
	echo "       ex) ./c_beautifier.sh ~/test_beauty.c /home/yummyHit/output.c 10"
	echo "       Must keep options ordering"
	echo
	echo "       If Output file name is blank, $1\_beauty is default output file name"
	echo "       Tab space is indent or tab default space. default 4"
	exit
fi

FILENAME="$1"
OUTPUTFILENAME="$2"
TABSPACE="$3"

# File path wrong
if [ ! -f "$FILENAME" ]; then
	echo "No such file or path"
	exit
fi

# Default out file
if [ "$OUTPUTFILENAME" = "" ]; then
	OUTPUTFILENAME="$FILENAME\\_beauty"
fi

TEMPFILE="$OUTPUTFILENAME\\_tmp"

# clear the destination file
: > $OUTPUTFILENAME
: > $TEMPFILE

# Default number of spaces
if [ "$TABSPACE" = "" ]; then
	TABSPACE=4;
fi

PADDER=""

for i in `seq 1 $TABSPACE`; do
	PADDER="${PADDER} "
done

echo "Get File Name is $FILENAME!!"
echo "Output File Name is $OUTPUTFILENAME!!"
echo "PADDER is ($PADDER)"

tab_counter=0
open_counter=0
close_counter=0
LINE_NUMBER=`cat $FILENAME | wc -l`
ACTUAL_LINE=1

sed -e 's/\\//g' $FILENAME | while read -r line; do
	line_tmp=`echo "$line" | sed -e 's/^ *//g' -e 's/^\t*//g'`
	linea=`echo "$line_tmp" | sed -e 's/\ $//g'`
	while [ "`echo "$linea" | grep \"\ $\" | wc -l | sed -e 's/^ *//g' -e 's/^\t*//g'`" -ne 0 ]; do
		linea=`echo "$linea" | sed -e 's/\ $//g'`
	done

	while [ "`echo \"$linea\" | egrep \"{{|}}\" | wc -l | sed -e 's/^ *//g' -e 's/^\t*//g'`" -ne 0 ]; do
		linea=`echo "$linea" | sed -e 's/}}/} }/g' -e 's/{{/{ {/g'`
	done

	cur_stat_first=0;
	cur_stat_last=0;

	cur_stat_first=`echo "$linea" | grep -v "^\/\/" | awk 'BEGIN{count=0}{for(i=1;i<=NF;i++) if($i ~ /{/) count++;}END{print count}'`
	cur_stat_last=`echo "$linea" | grep -v "^\/\/" | awk 'BEGIN{count=0}{for(i=1;i<=NF;i++) if($i ~ /}/) count++;}END{print count}'`

	if [ $cur_stat_first -ne 0 ]; then
		open_counter=`expr $open_counter + $cur_stat_first`
	fi

	if [ $cur_stat_last -ne 0 ]; then
		close_counter=`expr $close_counter + $cur_stat_last`
	fi

	if [ $cur_stat_last -ge 1 ] && [ $open_counter -ge $close_counter ]; then
		tab_counter=`expr $tab_counter - $cur_stat_last`
	fi

	if [ $open_counter -le $close_counter ]; then
		tab_counter=0
		open_counter=0
		close_counter=0
	fi

	i=0
	while [ $i -lt $tab_counter ]; do
		linea=`echo "${PADDER}${linea}"`
		i=`expr $i + 1`
	done


	if [ $cur_stat_first -ge 1 ] && [ $open_counter -ge $close_counter ]; then
		tab_counter=`expr $tab_counter + $cur_stat_first`
	fi

	echo "$linea" >> "$TEMPFILE"
	
	percent=`expr $ACTUAL_LINE \* 100`
	percent=`expr $percent \/ $LINE_NUMBER`
	printf "  %s %% completed" $percent
	printf "\r"
	ACTUAL_LINE=`expr $ACTUAL_LINE + 1`
done

sed -e 's//\\/g' $TEMPFILE > $OUTPUTFILENAME

if [ -f "$TEMPFILE" ]; then
	rm $TEMPFILE
fi

echo
exit 0
