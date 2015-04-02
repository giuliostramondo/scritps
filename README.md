# Scritps
Collection of script for osx

###Check UPS package
 This script takes as argument the tracking number of an UPS package
 when launched it displays the last update done on the traking page
 then it starts to monitor the page periodically, displaying every new update

 Updates are showed with command line echo's and using the osx notification system
######Usage 
`./check_ups.sh tracking_number`
ex. `./check_ups.sh 1Z32972V6857000000`

######Used in the script\:
  * xmllint to perform xpath queries on html pages
  * tidy to format the page output
  * osascript to show notification on osx
