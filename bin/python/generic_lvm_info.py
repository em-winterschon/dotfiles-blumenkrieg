#!/usr/bin/python
''' @PACKAGE generic_lvm_info.py
    @AUTHOR Madeline Everett
    @COPYRIGHT (c) 2012-present Madeline Everett
    @LICENSE: GPLv3, docs/gpl-3.0.txt, http://www.gnu.org/licenses/gpl-3.0.txt
'''
import os
import sys
import subprocess
import select
import commands

argv = list()
argv.append("lvdisplay")
argv.append("-c")

# execute command
process = subprocess.Popen(argv, stdout=subprocess.PIPE)
output = ""
out = process.stdout.readline()
output += out

# parse command output
lines = output.splitlines()
for line in lines:
    line = line.strip()
    words = line.strip().split(":")
    
    vgname = words[1].strip()
    lvpath = words[0].strip()
    last_slash_index = lvpath.rfind("/") + 1
    lvname = lvpath[last_slash_index:]
    #self.lvs_paths[vgname + '`' + lvname] = lvpath
    
    # lv query command
    argv = list()
    argv.append("/sbin/lvm")
    argv.append("lvs")
    argv.append("--nosuffix")
    argv.append("--noheadings")
    argv.append("--units")
    argv.append("b")
    argv.append("--separator")
    argv.append(";")
    argv.append("-o")
    argv.append("lv_name,vg_name,stripes,stripesize,lv_attr,lv_uuid,devices,origin,snap_percent,seg_start,seg_size,vg_extent_size,lv_size")

process = subprocess.Popen(argv, stdout=subprocess.PIPE)
output = ""
out = process.stdout.readline()
output += out
lines = output.splitlines()
for line in lines:
    line = line.strip()
    words = line.split(";")
    
    lvname = words[0].strip()
    vgname = words[1].strip()
    attrs = words[4].strip()
    uuid = words[5].strip()
    extent_size = int(words[11])
    #seg_start = int(words[9]) / extent_size
    lv_size = int(words[12]) / extent_size
    #seg_size = int(words[10]) / extent_size
    #devices = words[6]
    
    print "lvname: %s, vgname: %s, attrs: %s, size: %s"%(lvname, vgname, attrs, extent_size)
    
        
