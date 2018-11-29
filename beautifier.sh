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
# ex) ./beautifier.sh ~/test_beauty.sh /home/yummyHit/output.sh 10
# ----------------------------------

if [ "$#" != "3" ]; then
	echo "Usage: $0 <File Name> <Output File Name> <Tab space>"
	return
fi

FILENAME="$1"
OUTPUTFILENAME="$2"
TABSPACE="$3"

# Default out file
if [ "$OUTPUTFILENAME" = "" ]; then
	OUTPUTFILENAME="$FILENAME\_beauty"
fi

TEMPFILE="$OUTPUTFILENAME\_tmp"

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

if_counter=0
LINE_NUMBER=`cat $FILENAME | wc -l`
ACTUAL_LINE=1

sed -e 's/\\//g' $FILENAME | while read -r line; do
	linea=`echo "$line" | sed -e 's/^ *//g' -e 's/^\t*//g'`

	cur_stat_first=`echo "$linea" | awk '{print $1}'`
	cur_stat_last=`echo "$linea" | awk '{print $NF}' | tr -d ';'`

	is_fi_first=`echo "$cur_stat_first" | tr -d ' '`
	is_fi_last=`echo "$cur_stat_last" | tr -d ' '`

	if [ "$is_fi_first" = "fi" ] || [ "$cur_stat_first" = "else" ] || [ "$cur_stat_first" = "esac" ] || [ "$cur_stat_first" = "done" ] || [ "$cur_stat_first" = "elif" ]; then	
		if_counter=`expr $if_counter - 1`
	elif [ "$is_fi_last" = "fi" ] || [ "$cur_stat_last" = "else" ] || [ "$cur_stat_last" = "esac" ] || [ "$cur_stat_last" = "done" ] || [ "$cur_stat_last" = "elif" ]; then	
		if_counter=`expr $if_counter - 1`
	fi

	i=0
	while [ $i -lt $if_counter ]; do
		linea=`echo "${PADDER}${linea}"`
		i=`expr $i + 1`
	done

	is_do_first=`echo "$cur_stat_first" | tr -d ' '`
	is_do_last=`echo "$cur_stat_last" | tr -d ' '`

	# If it is a condition open
	if [ "$cur_stat_first" = "else" ] || [ "$cur_stat_first" = "case" ] || [ "$cur_stat_first" = "then" ] || [ "$is_do_first" = "do" ]; then
		if_counter=`expr $if_counter + 1`
	elif [ "$cur_stat_last" = "else" ] || [ "$cur_stat_last" = "case" ] || [ "$cur_stat_last" = "then" ] || [ "$is_do_last" = "do" ]; then
		if_counter=`expr $if_counter + 1`
	fi

	echo "$linea" >> "$TEMPFILE"
	
	percent=`expr $ACTUAL_LINE \* 100`
	percent=`expr $percent \/ $LINE_NUMBER`
	printf "%s %% completed" $percent
	printf "\r"
	ACTUAL_LINE=`expr $ACTUAL_LINE + 1`
done

sed -e 's//\\/g' $TEMPFILE > $OUTPUTFILENAME

if [ -f "$TEMPFILE" ]; then
	rm $TEMPFILE
fi

echo
exit 0
