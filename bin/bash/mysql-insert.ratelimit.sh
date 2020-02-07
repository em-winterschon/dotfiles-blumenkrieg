#!/bin/bash
################################################################################
# Author: Madeline Everett
# Date: 2015-10-21
# Name: mysql-insert.ratelimit.sh"
# Purpose: very simple rate limiting script for MySQL statements
################################################################################

DB="mail"
QUERY="UPDATE user_package SET status = '1' WHERE user_id" ## query without final qualifier, which we set programmatically.

FILE=$1 ## input file with our IDs

exec 3<&0
exec 0<$FILE

x=0 # counter for tps
i=1 # counter for iteration
t=`wc -l $FILE | awk '{print $1}'` # counter for total

while read line; do
    echo "TX[$x/s][$i:${t}], Operating on ID: $line"

    ## we're already operating as root, so we're not setting user/pass
    mysql $DB -e "$QUERY = '$line';"

    if [ $x -eq 50 ]; then
	echo "  50/TPS Limited, Sleeping...\n"
	sleep 1 && x=0
    fi	

    x=$(( $x + 1 ))
    i=$(( $i + 1 ))

done

exec 0<&3

