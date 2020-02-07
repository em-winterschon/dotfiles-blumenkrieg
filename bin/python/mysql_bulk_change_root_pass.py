#!/usr/bin/env python
################################################################################
## DATE: 2010-12-28
## AUTHOR: Madeline Everett
## LICENSE: BSD http://www.opensource.org/licenses/bsd-license.php
################################################################################
import commands
import sys
import os
import sys, re
import time
import operator
from subprocess import Popen, PIPE, STDOUT, call

def main():
	hosts = [
		["10.20.70.26","password"],
		["10.20.30.38","password"],
		["10.20.30.30","password"],
		["10.20.30.32","password"],
		["10.20.30.33","password"],
		["10.20.30.135","password"],
		["10.20.30.136","password"],
		["10.20.30.37","password"],
		["10.10.30.130","password"],
		["10.10.30.131","password"],
		["10.10.30.30","password"],
		["10.10.30.31","password"],
		["10.10.30.39","password"],
		["10.10.30.32","password"],
		["10.10.30.34","password"],
		["10.10.30.24","password"],
		["10.10.30.38","password"],
		["10.10.30.199","platform"],
		["10.10.30.35","password"],
		["10.10.30.36","password"],
		["10.20.70.130","password"],
		["10.20.70.131","password"],
		["10.20.70.30","password"],
		["10.20.70.31","password"],
		["10.20.70.37","password"],
		["10.20.70.38","password"],
		["10.20.70.32","password"],
		["10.20.70.33","password"],
		["10.20.70.199","platform"],
		["10.20.70.35","password"],
		["10.20.70.36","password"],
		["10.20.50.30","password"],
		["10.20.50.31","password"],
		["10.20.50.32","password"],
		["10.20.50.33","password"],
		["10.20.50.34","password"],
		["10.20.50.35","password"],
		["10.20.50.36","password"],
		["10.20.40.22","password"],
		["10.20.40.24","password"],
		["10.30.40.21","password"],
		["10.30.40.22","password"],
		["10.20.50.40","password"],
		["10.20.50.41","password"],
		["10.20.50.42","password"],
		["10.20.50.43","password"],
		["10.20.50.44","password"],
		["10.20.50.45","password"],
		["10.20.50.46","password"],
		["10.20.50.47","password"],
		["10.10.30.132","password"],
		["10.10.30.133","password"],
		["10.20.70.140","password"],
		["10.20.70.141","password"],
		["10.20.80.30","password"],
		["10.20.80.31","password"],
		["10.20.70.142","password"],
		["10.20.30.128","password"],
		["10.20.30.129","password"],
		["10.20.30.35","password"],
		["10.20.30.36","password"],
		["10.10.30.135","password"],
		["10.10.30.136","password"],
		["10.20.50.50","password"],
		["10.20.50.51","password"],
		["10.20.50.52","password"],
		["10.20.50.53","password"],
		["10.20.50.54","password"],
		["10.20.50.55","password"],
		["10.20.50.56","password"],
		["10.20.50.57","password"],
		["10.20.30.111","password"],
		["10.20.30.112","password"],
		["10.20.30.113","password"],
		["10.20.30.114","password"],
		["10.20.30.115","password"],
		["10.20.30.116","password"],
		["10.20.30.117","password"],
		["10.20.30.118","password"],
		["10.20.50.60","password"],
		["10.20.50.61","password"],
		["10.20.50.62","password"],
		["10.20.50.63","password"],
		["10.20.30.104","password"],
		["10.20.30.105","password"],
		["10.20.30.106","password"],
		["10.20.30.107","password"]]


	for i in range(len(hosts)):
		addr = hosts[i][0]
		pwd = hosts[i][1]
		print "ADDR: %s, PWD: %s"%(addr,pwd) 
		a = "new_pass"
		
		#cmd = "ssh -o ConnectTimeout=5 username@%s \"/usr/bin/mysql -uroot --host=127.0.0.1 --password=%s -e \\\"use mysql;update user set Password=password('newpass') where User='root';flush privileges;\\\"\""%(addr,pwd)
		cmd = "ssh -o ConnectTimeout=5 username@%s \"/usr/bin/mysql -uroot --host=127.0.0.1 --password=%s -e \\\"select 1;\\\"\""%(addr,a)
		
		
		try:
			call(cmd, shell=True)
		except:
			print "Failed on addr: %s"%(addr)
			
	return 

#### START SOME SHIT
if __name__ == "__main__":
	try:
		retval = main()
	except (KeyboardInterrupt, SystemExit):
		sys.exit(1)
