#!/bin/bash
#--------------------------------------------------------------------------------------------------#
#-- Name     : chassis-drive-info.sh
#-- Purpose  : Enumerates connected drives
#-- Author   : Madeline
#-- Repo     : https://github.com/fastly/sfodev-benchmarking
#-- Requires : N/A
#------------:
#-- Date     : 2018-05-04
#-- Version  : 1.1
#--------------------------------------------------------------------------------------------------#

## This method will index ONLY physical based drives
TMPFILE=`mktemp`
for each in `ls /dev/disk/by-path/ | grep -v part | grep phy | sort`; do readlink /dev/disk/by-path/$each | awk -F\/ '{print $3}' >> $TMPFILE; done
DEVLIST=`cat $TMPFILE | sort`

echo $DEVLIST

for DEV in $DEVLIST; do
    WWN="wwn-`udevadm info -n /dev/${DEV} | grep -w ID_WWN | awk -F\= '{print $2}'`"
    DEVPATH=`udevadm info -n /dev/${DEV} | grep -w DEVPATH | awk -F\= '{print $2}'`
    MODEL=`udevadm info -n /dev/${DEV} | grep -w ID_MODEL | grep -v ENC | awk -F\= '{print $2}'`
    SERIAL=`udevadm info -n /dev/${DEV} | grep -i serial_short | awk -F\= '{print $2}'`
    LUN=`udevadm info -n /dev/${DEV} | grep -w ID_SAS_PATH | awk -F\= '{print $2}'`
    CONTROLLER=`udevadm info -n /dev/${DEV} | grep -w ID_SAS_PATH | awk -F\= '{print $2}' | awk -F- '{print $2}'`
    BAY=`udevadm info -n /dev/${DEV} | grep -w ID_SAS_PATH | awk -F\= '{print $2}' | awk -F: '{print $3}' | awk -F- '{print $3}' | sed 's/phy//'`
    let BAY=$BAY+1
    SIZE=`fdisk -l 2>&1 | grep "^Disk" | cut -f 1 -d ',' | cut -f 3- -d '/' | grep $DEV | awk '{print $2}' | awk -F. '{print $1}'`
    LOCATION="$CONTROLLER:$BAY"
    echo "#-----------------------------------------------------------------------------------------------------------------------#"
    echo " DEVPATH: $DEVPATH"
    echo " WWN: $WWN"
    echo " DEV: $DEV"
    echo " MODEL: $MODEL"
    echo " SIZE: $SIZE"
    echo " SERIAL: $SERIAL"
    echo " LUN: $LUN"
    echo " LOCATION: $CONTROLLER, BAY: $BAY"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" $DEVPATH $WWN $DEV $MODEL $SIZE $SERIAL $LUN $LOCATION >> $TMPFILE.csv
done

echo -e "#-----------------------------------------------------------------------------------------------------------------------#\n\n"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" DEVPATH WWN DEV MODEL SIZE SERIAL LUN LOCATION 
cat $TMPFILE.csv

rm -f $TMPFILE
rm -f $TMPFILE.csv

