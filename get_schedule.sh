#!/bin/bash

URL=http://www.fctokyo.co.jp/category/schedule
DATETIME=$(date +%Y%m%d%H%M%S)
BASE_DIR=$(dirname $0)
TMP_DIR=$BASE_DIR/.tmp.$DATETIME.$$

mkdir $TMP_DIR
wget $URL -P $TMP_DIR >/dev/null 2>&1

SCHEDULE_FILE=$(ls -1 ${TMP_DIR}/*)

echo 'Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private'

cat $SCHEDULE_FILE |\
	 grep -A 25 '<tr>' |\
	 perl -pe 's/(\r\n|\n|\r)//g' |\
	 perl -pe 's/<tr>/\n<tr>/g' |\
	 perl -pe 's/<.+?>/ /g' |\
	 sed 's/)    /)    12:00 /g' |\
	 perl -pe 's/^ *//g' |\
	 egrep "^[0-9]( |[0-9])"  |\
	 perl -pe 's/\(.+?\)//g' |\
	 awk '{print$4" "$2" "$3" "$5}' |\
	 column -t |\
while read team gameday kickoff location
do
	if [ $location = "味の素スタジアム" ] ; then
		team="[H]vs$team"
	else
		team="[A]vs$team"
	fi
	
	gameday=$(echo $gameday | perl -pe 's/月/\//g' | perl -pe 's/日//g')
	gameday=$(date --date $gameday +%Y/%m/%d)

	kickoff=$(date --date $kickoff +%r)
	endtime=$(date --date "$kickoff 1 hours" +%r)

	echo "$team,$gameday,$kickoff,$gameday,$endtime,False,Gameday,$location,True"

done

if [ -d $TMP_DIR ] ; then
	rm -rf $TMP_DIR
fi

exit 0

