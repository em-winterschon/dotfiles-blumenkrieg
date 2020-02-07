#!/usr/bin/env python
################################################################################
## NAME: atomic - the login automator
## DATE: 2016-08-19
## AUTHOR: Madeline Everett
## LICENSE: BSD http://www.opensource.org/licenses/bsd-license.php
VERSION = "1.1.5"
#xmlfile = "/Users/madeline.everett/.atomic.xml"
################################################################################
## OPTIONAL, We can scp environment files to a server on each login, if we want. 
# Specify array of files, in list format: ['file1','file2'] or False to disable
#filenames = ['~/.bashrc', '~/.bash_logout', '~/.emacs', '~/.screenrc']
filenames = False
################################################################################
## OPTIONAL, We can ask the user to select from 'login' or 'code execution'
# Specify one of the following flags: 'login','exec','ask'
action = 'login'
################################################################################
from xml.dom import minidom
from optparse import OptionParser
from os.path import expanduser
import commands
import sys
import operator
import os

'''Check Python version for compatibility'''
ver = sys.version.split(' ')[0].split(".")
major=ver[:1]
minor=ver[1:2]
pyver="%s.%s"%(major[0],minor[0])
if pyver < 2.6:
	print "Please upgrade to python 2.6+"
	sys.exit(1)
else:
	from subprocess import Popen, PIPE, STDOUT, call

def parse_options():
        home = expanduser("~")
        usage = "usage: "
        parser = OptionParser(usage=usage)
        parser.add_option("-p", "--printxml",
                          dest="printxml",
                          action="store_true",
                          help="Print a sample XML file.")

        parser.add_option("-x", "--xmlfile",
                          dest="xmlfile",
                          default="%s/.atomic.xml"%(home),
                          help="File containing hosts. (default: %s/.atomic.xml)"%(home))
        return parser.parse_args()
        
def printsample():
	print '''
        <?xml version = "1.0"?>
	<hosts>
         <server hostname='hostname.com' address='10.4.4.8' username='madeline' network='production'/>
	</hosts>
        '''

def xmlparser(ch):
	hosts = []
	file = open(xmlfile,'rU')
	xmldoc = minidom.parse(file)
	servers = xmldoc.getElementsByTagName('server')
	for server in servers:
		hostname = server.getAttribute('hostname')
		address = server.getAttribute('address')
		username = server.getAttribute('username')
		network = server.getAttribute('network')
		add = [hostname,address,username,network]		
		if ch != False:
			if network == ch:
				hosts.append(add)
		else:
			hosts.append(add)

	return hosts

def main(action):
	'''get unique network names from the XML data to generate our menu'''
	lst = []
	data = xmlparser(False)
	for x in range(len(data)):
		lst.append(data[x][3])		

	lst = list(set(lst)) #assign networks a unique (not order preserved) list
	for n in range(len(lst)):		
		print "[%i] %s"%(n+1,lst[n])

	dc = int(raw_input("Datacenter ID: "))
	hosts = xmlparser(lst[dc-1]) #remove the increment from the ID, then get hosts from XML		
	nodes = []

        if action == 'ask':
	        action = lower(str(raw_input("Login or Execute: [L/e] ")))
                
	if action == "login" or action == "l" or action is None:
		## Login and file copy section
		nest = sorted(hosts, key=operator.itemgetter(0))
		for x in range(len(nest)):
			'''hostname = nest[x][0], addr = nest[x][1], username = nest[x][2]'''
                        index = x
                        hostname = nest[x][0]
                        ipaddr = nest[x][1]
                        username = nest[x][2]
			print "[%i] %s | %s"%(index,ipaddr,hostname)

		ch = int(raw_input("ID: "))
		if filenames != False:
			for i, file in zip(range(len(filenames)), filenames):
				try:
					print "Host: %s - copying %s"%(nest[ch][1],file)
					call("scp %s %s@%s:. > /dev/null"%(file,nest[ch][2],nest[ch][1]),shell=True)
				except:
					print "Failed to copy file"
					sys.exit(1)
					
		try:
			call("ssh %s@%s"%(nest[ch][2],nest[ch][1]),shell=True)
		except:
			print "Failed to ssh"
			sys.exit(1)

		sys.exit(0)

	elif action == 'exec' or action == 'e':
		##Execution section
		stay = True
		login = False
		print "\n"
		while stay == True:
			nest = sorted(hosts, key=operator.itemgetter(0))
			for x in range(len(nest)):
				'''hostname = nest[i][0], addr = nest[i][1], username = nest[i][2]'''
				print "[%i] %s | %s"%(x,nest[x][1],nest[x][0])

			print "\nSelect node to add to execution list"
			ch = int(raw_input("ID: "))
			nodes.append([nest[ch][1],nest[ch][2]]) #addr,username
			s = str(raw_input("\nAdd another node? [Y/n] "))
			if s == "n" or s == "N":
				stay = False
		
		addrs = ""
		for node in nodes:
			address = (node[1]+"@"+node[0]+",").rstrip("\n")
			addrs = addrs+address

		cmd = str(raw_input("\nEnter the command to execute: "))
		l = str(raw_input("\nLogin to each server after executing command? [N/y]: "))
		if l == "y" or l == "Y":
			login = True

		## Test for existence of pdsh command, use if it exists. Else we use regular ssh in serial
		pdsh = call("which pdsh",shell=True)
		if pdsh == 0 and login == False:
			print "Command 'pdsh' exists. Executing commands in parallel."
			try:
				c = "pdsh -w %s %s"%(addrs.strip(","),cmd)
				print "Executing: %s"%(c)
				call(c,shell=True)
			except:
				print "Failed to execute pdsh command: %s"%(c)
				sys.exit(1)

		else:
			if pdsh != 0:
				print "Command 'pdsh' not found. Serializing ssh for command execution."
			else:
				print "Login after execution chosen. Serializing ssh for command execution."

			for node in nodes:
				retval = call("ssh -o ConnectTimeout=5 %s@%s \"%s\""%(node[1],node[0],cmd),shell=True)
				if retval == "1":
					print "ERROR: ssh command failed. Exit code: %i"%(retval)
					resp = str(raw_input("Continue? [Y/n]: "))
					if resp != "Y" or resp != "y":
						sys.exit(1)

				if login == True:
					call("ssh -o ConnectTimeout=5 %s@%s"%(node[1],node[0]),shell=True)
					
		sys.exit(0)

	else:
		print "WRONG!"
		sys.exit(1)

if __name__ == "__main__":
	print "Atomic version: %s"%(VERSION)
        (options, args) = parse_options()
        xmlfile = options.xmlfile
        printxml = options.printxml
        if printxml is not None:
                printsample()
                sys.exit(0)

	try:
		retval = main(action)

	except (KeyboardInterrupt, SystemExit):
		sys.exit(1)
