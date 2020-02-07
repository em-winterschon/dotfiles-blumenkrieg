#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : mysql-data-archiver.sh
#-- Purpose  : archives data based on query results
#-- Author   : Madeline Everett
#-- Repo     : https://github.com/madeline-everett/dotfiles
#-- Requires : pt-archiver
#------------:
#-- Date     : 2017-03-14
#-- Version  : 1.0
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
## User Options
#------------------------------------------------------------------------------#

DBHOST='localhost'
DBUSER='root'
DBPASS=''
DBNAME=''
DBPORT=4417
DBSOCK='/var/run/mysqld/mysqld.sock'
TABLE='time_series_data'
SQL="time_updated < NOW() - INTERVAL 3 MONTH"
DRYRUN="--dry-run"

#------------------------------------------------------------------------------#
## Functions and shared elements
#------------------------------------------------------------------------------#
function mysql.query() {
    if [ $# -eq 0 ]; then
	echo "Query missing..."
    else
	mysql --table --user=$DBUSER --password=$DBPASS --host=$DBHOST --port=$DBPORT --socket=$DBSOCK $DBNAME -e "$@"
    fi
}    


function mysql.repl.status() {
    echo "Checking replication status"
    which mysql >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "MySQL client binary not found. Cannot continue."
	kill -INT $$
    fi
    
    mysql.query "select 1;" >/dev/null 2>&1
    STATE=`mysql.query "show global status like 'Slave_running';" | awk -F\| '{print $2,$3}' | grep Slave_running | awk '{print $2}'`
    if [ "$STATE" = "ON" ]; then
	mysql.query "show slave status\G" | egrep Master_H\|Master_Log\|Seconds_Behind
    else
	echo "MySQL slave status indicates the slave is not running."
    fi
}

#------------------------------------------------------------------------------#
## Operational Sequence
#------------------------------------------------------------------------------#

## checking replication (if exists)
echo "Stopping replication..."
mysql.query "stop slave;"
mysql.repl.status

## start archive script
echo "Starting pt-archiver script"
pt-archiver --source h=$DBHOST,u=$DBUSER,p=$DBPASS,P=$DBPORT,D=$DBNAME,S=$DBSOCK,t=$TABLE \
    --bulk-delete \
    --purge \
    --where "$SQL" \
    --limit 1000 \
    --local \
    --low-priority-delete \
    --quick-delete \
    --progress=100 \
    --sentinel=/tmp/grok-purge-sentinel.tmp \
    --share-lock \
    --statistics \
    --txn-size=1000 \
    --no-check-charset \
    --why-quit \
    $DRYRUN

## start replication (if exists)
echo "Starting replication..."
mysql.query "start slave;"
mysql.repl.status

## run alter table to optimize post-delete
# pt-online-schema-change "alter table engine=innodb"
