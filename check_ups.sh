#!/bin/bash

# This script takes as argument the tracking number of an UPS package
# when launched it displays the last update done on the traking page
# then it starts to monitor the page periodically, displaying every new update

# Updates are showed with command line echo's and using the osx notification system

# Used: 
#   xmllint to perform xpath queries on html pages
#   tidy to format the page output
#   osascript to show notification on osx

tracking_number=$1

if [ "$#" -ne 1 ]; then
    echo "Check UPS package"
    echo "Usage:$0 tracking_number"
    echo "ex. $0 1Z32972V6857000000"
    exit 0
fi

xmllint --html --xpath "//p[@class=\"error\"][2]/text()" http://wwwapps.ups.com/WebTracking/processRequest\?loc\=it_IT\&tracknum\=$tracking_number 2>/dev/null | grep 1 > /dev/null && error=1 || error=0

if [ "$error" -eq "1" ]
	then
	echo "The given tracking number is wrong"
	exit 0
fi

xmllint --html --xpath "//table[1]/tr[position()>1]" http://wwwapps.ups.com/WebTracking/processRequest\?loc\=it_IT\&tracknum\=$tracking_number 2>/dev/null | tidy --indent yes -xml -q > tmp.out 
#item_number=`xmllint --html --xpath "count(//tr)" tmp.out`
item_number=0

echo "starting to monitor tracking page"
trap "rm tmp.out; exit 0" SIGHUP SIGINT SIGTERM

while [ true ]
do
	xmllint --html --xpath "//table[1]/tr[position()>1]" http://wwwapps.ups.com/WebTracking/processRequest\?loc\=it_IT\&tracknum\=$tracking_number 2>/dev/null | tidy --indent yes -xml -q > tmp.out 
	item_number_tmp=`xmllint --html --xpath "count(//tr)" tmp.out`
	if [ "$item_number_tmp" -gt "$item_number" ] 
		then
		last_location=`xmllint --html --xpath "//tr[1]/td[1]/text()" tmp.out`
		last_date=`xmllint --html --xpath "//tr[1]/td[2]/text()" tmp.out`
		last_time=`xmllint --html --xpath "//tr[1]/td[3]/text()" tmp.out`
		last_message=`xmllint --html --xpath "//tr[1]/td[4]/text()" tmp.out`
		echo "Location: $last_location Date: $last_date Time: $last_time Message: $last_message"
		subtitle="Location: $last_location Date: $last_date Time: $last_time"
		osascript_cmd="display notification \"$subtitle\" with title \"UPS - Update\" subtitle \"$last_message\"" 		
		osascript -e "$osascript_cmd"
		item_number=$item_number_tmp	
	fi
	sleep 10
done
