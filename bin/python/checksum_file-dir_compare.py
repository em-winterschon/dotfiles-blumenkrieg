#!/usr/bin/env python
#Author: Madeline Everett
#Date: 2012.04.24
#Purpose: generates simple report about common and differing files and directories
#Input: takes command line options 
#Outpt: text report
##
import filecmp
import os
import commands
import md5
from optparse import OptionParser

usage = "usage: %prog [options] arg"
parser = OptionParser(usage=usage)
parser.add_option("--dir1", dest="dir1", default="", help="first dir")
parser.add_option("--dir2", dest="dir2", default="", help="second dir")
parser.add_option("--file1", dest="file1", default="", help="first file")
parser.add_option("--file2", dest="file2", default="", help="second file")

(options, args) = parser.parse_args()

print "Checksum Comparison Operations"
print "-------------------------------"

# to do: check out: http://docs.python.org/library/difflib.html#module-difflib

if options.file1:
    if options.file2:
        f1 = options.file1
        f2 = options.file2
        state = filecmp.cmp(f1,f2)        
        if state == False:
            print "Files are not identical."
            f1 = commands.getoutput("md5sum %s"%(f1))
            f2 = commands.getoutput("md5sum %s"%(f2))
            print "md5: "+f1
            print "md5: "+f2
        else:
            print "Files are identical!"
            f1 = commands.getoutput("md5sum %s"%(f1))
            f2 = commands.getoutput("md5sum %s"%(f2))
            print "md5: "+f1
            print "md5: "+f2

elif options.dir1:
    if options.dir2:
        # to add: do an directory size check first, if it's large then tell the user 'this might take a while'
        cmp = filecmp.dircmp(options.dir1,options.dir2)        
        print cmp.report()
        print '----'
        # to add: put a progress or status bar here for large dirs
        print cmp.report_full_closure()

else:
    print "options not set, please tell me what to do."
    parser.print_help()

    
