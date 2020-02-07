#!/usr/bin/env python
''' @PACKAGE generic_mysql_framework.py
    @AUTHOR Madeline Everett
    @COPYRIGHT (c) 2012-present Madeline Everett
    @LICENSE: GPLv3, docs/gpl-3.0.txt, http://www.gnu.org/licenses/gpl-3.0.txt
'''
import sys
import MySQLdb
from optparse import OptionParser

## Command line arguments
def parse_options():
    usage = 'usage: '
    parser = OptionParser(usage=usage)
    
    '''Defaults'''
    parser.add_option('-l', '--log', dest='log', default='script.log', help='Log filename (default: script.log)')
    parser.add_option('-c', '--config', dest='config', default='', help='Config filename (default: script.conf)')

    '''DB configs'''
    parser.add_option("--user", dest="dbuser", default="", help="MySQL user")
    parser.add_option("--host", dest="dbhost", default="localhost", help="MySQL host (default: localhost)")
    parser.add_option("--password", dest="dbpass", default="", help="MySQL password")
    parser.add_option("--port", dest="dbport", type="int", default=3306, help="TCP/IP port (default: 3306)")
    parser.add_option("--socket", dest="dbsocket", default="/var/lib/mysql/mysql.sock", help="MySQL socket file. Only applies when host is localhost")
    parser.add_option("--database", dest="dbdatabase", help="Schema name to connect to")
    
    return parser.parse_args()


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


if __name__ == "__main__":

    (options, args) = parse_options()
    try:
        conn = MySQLdb.connect(
            host=options.dbhost,
            user=options.dbuser,
            passwd=options.dbpass,
            port=options.dbport,
            db=options.dbname,
            unix_socket=options.dbsocket)

    except:
        sys.exit(1)


