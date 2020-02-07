#!/opt/local/bin/python
''' @PACKAGE generic_mysql_simple.py
    @AUTHOR Madeline Everett
    @COPYRIGHT (c) 2012-present Madeline Everett
    @LICENSE: GPLv3, docs/gpl-3.0.txt, http://www.gnu.org/licenses/gpl-3.0.txt
'''

import sys
import MySQLdb

my_host = "localhost"
my_user = "user"
my_pass = "password"
my_db = "test"

try:
    db = MySQLdb.connect(host=my_host, user=my_user, passwd=my_pass, db=my_db)
except MySQLdb.Error, e:
     print "Error %d: %s" % (e.args[0], e.args[1])
     sys.exit (1)

cursor = db.cursor()
sql = "select column1, column2 from table";
cursor.execute(sql)

results = cursor.fetchall()
for row in results:
    column1 = row[0]
    column2 = row[1]
    print "column1: %s, column2: %s"%(column1,column2)

db.close()
