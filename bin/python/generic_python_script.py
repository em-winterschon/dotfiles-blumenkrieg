#!/usr/bin/env python
''' @PACKAGE GenericPythonScript
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
from Queue import *
from threading import Thread, Lock
from optparse import OptionParser
from ConfigParser import ConfigParser

## Hardcodes
code_version = "1.00.1.2"
d = datetime.datetime.now()
date = d.isoformat()
ver = sys.version.split(' ')[0].split(".")
major=ver[:1]
minor=ver[1:2]
version="%s.%s"%(major[0],minor[0])

## Command line arguments
def parse_options():
    usage = 'usage: '
    parser = OptionParser(usage=usage)
    
    '''File configs'''
    parser.add_option('-i', '--infile', dest='infile', default='', help='Input filename (default: none)')
    parser.add_option('-d', '--outdir', dest='outputdir', default='output', help='Output directory (default: output)')

    '''Defaults'''
    parser.add_option('-l', '--log', dest='log', default='script.log', help='Log filename (default: script.log)')
    parser.add_option('-c', '--config', dest='config', default='', help='Config filename (default: script.conf)')

    '''Thread configs'''
    parser.add_option('-t', '--threads', dest='threads', default=4, help='Quantity of processing threads to use (default: 4)')

    '''DB configs'''
    parser.add_option("--user", dest="dbuser", default="", help="MySQL user")
    parser.add_option("--host", dest="dbhost", default="localhost", help="MySQL host (default: localhost)")
    parser.add_option("--password", dest="dbpass", default="", help="MySQL password")
    parser.add_option("--port", dest="dbport", type="int", default=3306, help="TCP/IP port (default: 3306)")
    parser.add_option("--socket", dest="dbsocket", default="/var/lib/mysql/mysql.sock", help="MySQL socket file. Only applies when host is localhost")
    parser.add_option("--database", dest="dbdatabase", help="Schema name to connect to")
    
    return parser.parse_args()

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

## Byte formatter for human readable output
def human(bytes):
    bytes = float(bytes)
    if bytes >= 1099511627776:
        terabytes = bytes / 1099511627776
        size = '%.2fT' % terabytes
    elif bytes >= 1073741824:
        gigabytes = bytes / 1073741824
        size = '%.2fG' % gigabytes
    elif bytes >= 1048576:
        megabytes = bytes / 1048576
        size = '%.2fM' % megabytes
    elif bytes >= 1024:
        kilobytes = bytes / 1024
        size = '%.2fK' % kilobytes
    else:
        size = '%.2fb' % bytes
    return size

## START MySQL Functions
def query_exec(query):
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
#### END MySQL Functions

## System command executor
def syscmd(command):
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


## Application header info
def header():
    print '''>>>>--------------------<<<<
Generic.Python.Script
<<<<-------------------->>>>
author: madeline.e.everett@gmail.com
date: 20120713
'''

## Simple error reporter
def error(str):
    print '''Configuration argument [%s] missing. Please set the variable and retry.'''%(str)
    sys.exit(1)

## Meat and potatoes
def file_processor(inputfile):
    o = outputdir + '/' + i
    logger("starting the file processing task for input-file:[%s], output-file:[%s]"%(i,o),'i')

    try:
        logger("Opening output file for writing:[%s]"%(o),"i")
        outfile = open(o, "w")    
    except:
        logger("[CODE:0128] - failed to open output file [%s], check permissions."%(o),"e")
        sys.exit(128)

    ''' start processing the input file line by line '''
    with open(i) as ifile:
        for line in ifile:            
            line = line.rstrip()
            
            if "string" in line:
                logger("match for string entry",'d')
            else:
                logger("no match for string entry",'d')

            outfile.write(line+"\n")

    logger("processing complete, closing file handle:[%s]"%(o),'d')
    outfile.close()
    return 0

## Checks output directory for usablility 
def check_outputdir(outputdir):
    logger("Opening output directory for writing:[%s]"%(outputdir),"i")
    if os.path.isdir(outputdir):
        logger("Output dir exists",'d')
    else:
        logger("Output directory does not exist, creating: [%s]"%(outputdir),'i')
        retcode,output = syscmd("mkdir %s"%(outputdir))
        if retcode != 0:
            logger("[CODE:0168] - failed to open output directory [%s], check permissions."%(outputdir),"e")
            sys.exit(168)

## Handles the config file variable definitions 
def config_handler(config):
    '''test config file existence and access'''
    sys.stdout.write("Testing %s config access: "% (config))
    if(os.path.exists(config)):
        sys.stdout.write("[exists]")
        if(os.access(config, os.R_OK)):
            sys.stdout.write("[readable]\n")
        else:
            sys.stdout.write("[read-failed][exiting(1)]\n")
            sys.exit(1)
    else:
        sys.stdout.write("[config file does not exist][exiting(1)]\n")
        sys.exit(1)

    '''initilize config settings'''
    cfg = ConfigParser()
    cfg.read([config])
    header = 'configuration' #config file header string: "[configuration]"
    threads = config.get(header,'threads')
    infile = config.get(header,'infile') 
    outfile = config.get(header,'outfile') 
    outputdir = config.get(header,'outputdir') 
    log = config.get(header,'log') 

    return threads,infile,outfile,outputdir,log

## Queue and Thread Functions
def thread_processor(item):
    start = time.time()
    print 'operating on item: %s'%(item)
    file_processor(item)
    end = time.time()                
    elapse = str(round((end - start)*1000))+"ms"
    print "TIMING|elapse|%s|%s"%(url,elapse)

def thread_worker():
    while True:
        item = work_queue.get()
        thread_processor(item)
        work_queue.task_done()

def thread_init():
    for i in range(threads):
        t = Thread(target=worker)
        t.setDaemon(True)
        t.start()

def queue_source():
    items = open("list-of-items", "r")
    return items.readlines() 

def queue_init(queue):
    for items in queue_source():
        item = items.rstrip()
        print "inserting into the queue: %s"%(item)
        queue.put(item)

def queue_process(queue):
    queue.join()


## Main
if __name__ == "__main__":
    header()    

    '''ARG configuration'''
    (options, args) = parse_options()
    config = options.config


    '''Config file based configuration if enabled via ARG value
    otherwise skip and use ARG config values'''
    if config:
        threads,infile,outfile,outputdir,log = config_handler(config)
    else:
        threads = options.threads
        infile = options.infile
        outfile = options.outfile
        outputdir = options.outputdir
        log = options.log


    ''' ensure certain args are set '''
    if not infile: error('--infile')
    if not outfile: error('--outfile')


    ''' create log instances '''
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


    ''' sanity checks '''
    check_outputdir(outputdir)


    ''' initialize Queue and Threads: sequence is important'''
    queue = Queue()
    thread_init()
    queue_init(queue)
    queue_process(queue)
