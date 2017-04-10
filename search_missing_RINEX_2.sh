#!/bin/bash
#
# Script to search for missing RINEX files in the Datapool ($D/RINEX/) and available on the FTP server
# Command:
# 	./search_missing_RINEX_2 inputfile ftp_dir GPSWeekStart [GPSWeekEng]
# 
# Example :
# 	./search_missing_RINEX_2 list_IGS 1773 1896
#
# Alexandr Sokolov, KEG
# 10.05.2016


rm -f list_in_DP
rm -f list_No_DP  
rm -f list_probable

list=$1
GPSWeekStart=$2
GPSWeekEnd=$3

if (( $# == 2))
then
	GPSWeekEnd=$GPSWeekStart
fi

echo "GPSWeekStart $GPSWeekStart"
echo "GPSWeekEnd   $GPSWeekEnd"

for(( GPSWeek=GPSWeekStart; GPSWeek<=$GPSWeekEnd; GPSWeek++ ))
do {
	#echo "Loading GPS week $GPSWeek"    
	for(( wd=0; wd<=6; wd++ )) 
	do {
		date=$( ~/bin/gps_date -wd $GPSWeek $wd  -o "%Y %y %j") 
		yyyy=$(echo "$date" | cut -f1 -d' ')
		yy=$(  echo "$date" | cut -f2 -d' ')
		ddd=$( echo "$date" | cut -f3 -d' ')
		# search for probable missing RNX files
		# slow
#		echo "$site $ddd $yy " | awk '{printf "ls  $D/RINEX/%s%s0.%sd.Z  2>&1 >/dev/null| cut --characters=53-66 \n",$1, $2, $3}' | sh >> list_No_DP
		echo "$site$ddd"0."$yy"[D].Z >> list_probable
	} done
} done

## make faster scan of DP
ls -1 $D/RINEX/$site*[d,D].Z | xargs -n 1 basename > list_in_DP
grep --ignore-case --invert-match --file list_in_DP list_probable > list_No_DP

## upload if exist

while read RNXfile
do {
	echo "$ftp_dir $RNXfile" | awk '{printf "%s20%02d/%03d/%s\n", $1, substr($2,10,2), substr($2,5,3), $2}' #>> list_to_import
} done < list_No_DP

rm list_No_DP
rm list_in_DP
rm list_probable






 
