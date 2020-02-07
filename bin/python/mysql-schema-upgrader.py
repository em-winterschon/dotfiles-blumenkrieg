#!/usr/bin/env python
''' @PACKAGE mysql-schema-upgrader.py
    @AUTHOR Madeline Everett
    @COPYRIGHT (c) 2012-present Madeline Everett
    @LICENSE: GPLv3, docs/gpl-3.0.txt, http://www.gnu.org/licenses/gpl-3.0.txt
'''
from __future__ import division
import commands
import os
import sys
import datetime
import logging
import MySQLdb
from optparse import OptionParser

## Hardcodes
code_version = "1.00.1.2"
d = datetime.datetime.now()
date = d.isoformat()
ver = sys.version.split(' ')[0].split(".")
major=ver[:1]
minor=ver[1:2]
version="%s.%s"%(major[0],minor[0])

## Logging functionality
def logger(detail,level):
    if(level == "d"):
        log.debug("%s"% (detail))
    elif(level == "i"):
        log.info("%s"% (detail))
    elif(level == "w"):
        log.warn("%s"% (detail))
    elif(level == "e"):
        log.error("%s"% (detail))
    elif(level == "c"):
        log.critical("%s"% (detail))


def parse_options():
    usage = "usage: "
    parser = OptionParser(usage=usage)
    parser.add_option("--user", dest="dbuser", default="", help="MySQL user")
    parser.add_option("--host", dest="dbhost", default="localhost", help="MySQL host (default: localhost)")
    parser.add_option("--password", dest="dbpass", default="", help="MySQL password")
    parser.add_option("--port", dest="dbport", type="int", default=3306, help="TCP/IP port (default: 3306)")
    parser.add_option("--socket", dest="dbsocket", default="/var/lib/mysql/mysql.sock", help="MySQL socket file. Only applies when host is localhost")
    parser.add_option("--database", dest="dbdatabase", help="Database name to upgrade")
    parser.add_option("-v", "--verbose", dest="verbose", action="store_true", help="Print user friendly messages")
    parser.add_option('--ddlfile', dest='infile', default='', help='DDL upgrade file containing schema structure ONLY (default: none)')
    parser.add_option('--log', dest='log', default='upgrade.log', help='Log filename (default: upgrade.log)')
    return parser.parse_args()

## System command executor
def sysexec(command):
    logger("Running system command: [%s]"%(command),'i')    
    start = datetime.datetime.now()
    retcode, output = commands.getstatusoutput(command)
    end = datetime.datetime.now()
    timing = end - start
    logger("Total compute time: %s"%(timing),'d')
    if retcode != 0:
        logger("System command: [%s], code: [%i] [FAILED]"%(command,retcode),'e')
        return retcode,output
    else:
        logger("System command: [OK]",'d')
        logger("Returning: [%i], [%s]"%(retcode, output),'d')
        return retcode,output

def verbose(message):
    if options.verbose:
        print "-- %s" % message

def print_error(message):
    print "-- ERROR: %s" % message

def query_exec(query):
    """
    Run the given query, commit changes
    """
    connection = conn
    cursor = connection.cursor()
    num_affected_rows = cursor.execute(query)
    cursor.close()
    connection.commit()
    return num_affected_rows


def query_row(query):
    connection = conn
    cursor = connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    row = cursor.fetchone()

    cursor.close()
    return row


def query_rows(query):
    connection = conn
    cursor = connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query)
    rows = cursor.fetchall()

    cursor.close()
    return rows


def exit_with_error(error_message):
    """
    Notify and exit.
    """
    print_error(error_message)
    exit(1)

## Application header info
def header():
    print '''>>>>--------------------<<<<
MySQL_SchemaUpgrader
<<<<-------------------->>>>
author: madeline.e.everett@gmail.com
date: 20120716
'''

## Simple error reporter
def error(str):
    print '''Configuration argument [%s] missing. Please set the variable and retry.'''%(str)
    sys.exit(1)

## Meat and potatoes
def processor(infile,conn):
    print os.stat(infile)
    logger("starting the schema upgrade task for DDL file:[%s]"%(infile),'i')

    logger("exporting data from database",'i')
    ret0,out0 = sysexec("mysqldump --host=%s --user=%s --password=%s -t -c %s > %s_data-only.sql"%(dbhost,dbuser,dbpass,dbdatabase,dbdatabase))
    if ret0 is not 0:
        logger("Data dump for schema failed",'e')
        return 201
        
    logger("importing structure from DDL file",'i')
    ret1,out1 = sysexec("mysql --host=%s --user=%s --password=%s %s < %s"%(dbhost,dbuser,dbpass,dbdatabase,infile))
    if ret1 is not 0:
        logger("DDL import for schema failed",'e')
        return 202
        
    logger("importing data into new schema",'i')
    ret2,out2 = sysexec("mysql --host=%s --user=%s --password=%s %s < %s_data-only.sql"%(dbhost,dbuser,dbpass,dbdatabase,dbdatabase))
    if ret2 is not 0:
        logger("Data import for schema failed",'e')
        return 203        


    '''PRINT SOME STATS'''
    s_orig = {} #original schema (dictionary)
    s_new = {} #new schema (dictionary)

    tables = query_rows("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '%s' ORDER BY TABLE_NAME"%(dbdatabase))
    for table in tables:
        t = table['TABLE_NAME']
        c = query_row("SELECT COUNT(*) AS ROWS FROM %s.%s"%(dbdatabase,t))
        s_new.update({t: c["ROWS"]})

    tables = query_rows("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '%s' ORDER BY TABLE_NAME"%(dbdatabase+'_backup'))
    for table in tables:
        t = table['TABLE_NAME']
        c = query_row("SELECT COUNT(*) AS ROWS FROM %s.%s"%(dbdatabase+'_backup',t))
        s_orig.update({t: c["ROWS"]})

    logger("Table row count comparisons",'i')
    logger("name [orig:new]",'i')
    for k in s_orig:
        v1 = s_orig.get(k)
        v2 = s_new.get(k)
        logger("%s [%s:%s]"%(k,v1,v2),'i')
        if v1 != v2:
            logger("DATA INCONSISTENT: %s[%s:%s]"%(k,v1,v2),'i')

    return 0


## Initialization Process
if __name__ == "__main__":
    header()    

    '''ARG configuration'''
    (options, args) = parse_options()
    infile = options.infile
    log = options.log
    dbuser = options.dbuser
    dbhost = options.dbhost
    dbpass = options.dbpass
    dbdatabase = options.dbdatabase
    dbport = int(options.dbport)
    dbsocket = options.dbsocket
    
    #ensure certain args are set
    if not infile: error('--ddlfile')
    if not dbuser: error('--user')
    if not dbhost: error('--host')
    if not dbpass: error('--password')
    if not dbdatabase: error('--database')
    if not dbport: error('--port')
    if not dbsocket: error('--socket')

    #create log instances
    log = logging.getLogger()
    log.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    c = logging.StreamHandler(sys.stdout)
    c.setLevel(logging.INFO) 
    c.setFormatter(formatter)
    log.addHandler(c) 

    try:
        f = logging.FileHandler(options.log)
    except:
        logger("[CODE:127] - failed to open logfile[%s] for writing. check permissions."%(options.log),'e')
        sys.exit(127)

    f.setLevel(logging.DEBUG)
    f.setFormatter(formatter)
    log.addHandler(f) 
    #end log creation

    ## START PROCESSING THE JOB
    conn = None
    reuse_conn = True
    try:
        conn = MySQLdb.connect(
            host = dbhost,
            user = dbuser,
            passwd = dbpass,
            port = dbport,
            db = dbdatabase,
            unix_socket = dbsocket)

    except Exception, err:
        logger(err,'e')
        sys.exit(127)
        
    try:
        if infile:
            if os.stat(infile).st_size > 0:                
                # Check DDL file for INSERT statements - if we have data in the infile it will clobber production data
                for line in open(infile):
                    if "INSERT INTO" in line:
                        logger("DDL schema upgrade file seems to contain INSERT statements. Please export the DDL file using: 'mysqldump --no-data' and try again",'e')
                        sys.exit(122)
            
                # Run database backup before we start messing with things. Dump and pipe into $dbdatabase_backup.
                query_exec("drop database if exists %s_backup"%(dbdatabase))
                query_exec("create database %s_backup"%(dbdatabase))
                ret,out = sysexec("mysqldump --host=%s --user=%s --password=%s --single-transaction %s | mysql --host=%s --user=%s --password=%s %s_backup"%(
                        dbhost,dbuser,dbpass,dbdatabase,
                        dbhost,dbuser,dbpass,dbdatabase))
                if ret is not 0:
                    logger("Failed to create backup of database. Exiting.",'e')
                    sys.exit(198)                                 

                # Start upgrade process with DDL file
                retcode = processor(infile,conn)
                if retcode is not 0:
                    logger("FAILURE CODE: %s"%(retcode),'e')
                    sys.exit(retcode)
                    
                # Close DB connection
                if conn:
                    conn.close()                

                # And we're done
                logger("Operation complete.",'i')
                sys.exit(0)
                
            else:
                logger("Input file is zero size. Nothing to do. Exiting.",'e')
                sys.exit(1)
        else:
            logger("Nothing to process, but we should have gotten an error if 'infile' wasn't set prior to this anyway",'d')
            sys.exit(1)
            
    except (KeyboardInterrupt, SystemExit):
        sys.exit(1)



