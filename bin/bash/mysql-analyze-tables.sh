#!/bin/sh
HOST="localhost"
USER="root"
PASS="password"

DBS=`mysql -u$USER --password=$PASS --host=$HOST -s -e "show databases"`

for db in $DBS; do 
    array=('Database' 'mysql' 'information_schema' 'performance_schema')
    if echo "${array[@]}" | fgrep --word-regexp "$db"; then
	echo "Schema [$db] is in list of excludes, skipping."
    else
	echo $db
	TABLES=`mysql -u$USER --password=$PASS --host=$HOST $db -s -e "show tables"`	    
	for table in $TABLES; do 	   
	    echo "Analyzing table: $table"
	    mysql --show-warnings=FALSE -u$USER --password=$PASS --host=$HOST $db -e "ANALYZE TABLE $table;"
	done
    fi    
done

echo "Complete"

