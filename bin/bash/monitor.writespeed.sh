#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : monitor.writespeed.sh
#-- Purpose  : Shows realtime growth rate stats for a file or directory
#-- Author   : Madeline Everett
#-- Requires : Bash 4.0+ and POSIX
#------------------------------------------------------------------------------#
DATE="2016-10-17"
VERSION="0.1"
REPO="https://github.com/madeline-everett/misc-scripts"
#------------------------------------------------------------------------------#
#set -x

function _self.error() {
    echo $1;
    exit $2;
}

function _self.help() {
    cat<<EOF
Name: monitor.writespeed :: builtin function of superbash
Purpose: displays realtime write stats for a file or directory
Usage: monitor.writespeed [options]

 -t, --target     file or directory to monitor [default: none]
 -h, --help       print the help text [default: none]
 -i, --interval   polling time in seconds [default: 2]
 -u, --unit       units [k=Kbyte, m=Mbyte, g=Gbyte] [default: k]
 -s, --sequence   sequential output [yes/no] [default: yes]

----------------------------------------------------------------
Author  : Madeline Everett
Repo    : $REPO
Version : $VERSION
Date    : $DATE
EOF
exit
}

## Set defaults for GetOps
help="no"
target="null"
sequence="yes"
unit="k"
interval="2"
skip="no"

## Check ARGV array
##  - If only one argv and is not for help, perhaps we're skipping options
##  - If skipping options we can bypass the other arg checks and execut
echo "Running monitor.writespeed ..."
echo "--------------------------------------------------------------------------------"
echo "Checking args"
if [ $# -eq 0 ]; then
    _self.help
else
    if [ $# -eq 1 ]; then
	if [ $1 = "-h" ]; then _self.help;
	elif [ $1 = "--help" ]; then _self.help;
	else
	    target=$1;
	    skip="yes";
	fi
    fi
fi

## Check GetOps flags
if [ $skip = "no" ]; then
    while [ $# -gt 0 ]; do
	case $1 in
	    -h|--help) help="yes" ;;
	    ## long opts need additional shift
	    -t|--target) target="$2" ; shift;;
	    -i|--interval) interval="$2" ; shift;;
	    -u|--unit) unit="$2" ; shift;;
	    -s|--sequence) sequence="$2" ; shift;;
	    (--) shift; break;;
	    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	    (*) break;;
	esac
	shift
    done
fi

## Check for help before everything else
echo -n "#---------- checking help: "
helpval=$(echo $help | awk '{print tolower($0)}')
echo $helpval
if [ "$helpval" = "yes" ]; then _self.help; fi

## Check value of interval to ensure integer
echo -n "#---------- checking interval: "
if [ "$interval" -eq "$interval" ] 2>/dev/null; then echo $interval;
else _self.error "Error: interval specified is not an integer." 3; fi

## Check which unit to use
echo -n "#---------- checking unit: "
unitval=$(echo $unit | awk '{print tolower($0)}')
echo $unitval
if [ "$unitval" = "k" ]; then unit="-k" && desc="KB";
elif [ "$unitval" = "g" ]; then unit="-g" && desc="GB";
elif [ "$unitval" = "m" ]; then unit="-m" && desc="MB";
else unit="-k" && desc="KB"; fi

## Check sequence or in-place
echo -n "#---------- checking sequence: "
seqval=$(echo $sequence | awk '{print tolower($0)}')
echo $seqval
if [ "$seqval" = "yes" ]; then inplace=0; else inplace=1; fi

## Check if our target exists
echo -n "#---------- checking target: "
echo $target
if [ "$target" = "null" ]; then _self.error "Error: Target is missing or null."; fi

## Execute...
size=$(du -ks "$target" | awk '{print $1}')
firstrun=1
echo ""

while [ 1 ]; do
    prevsize=$size
    size=$(du $unit -s "$target" | awk '{print $1}')
    csize=$((${size} - ${prevsize}))
    cmin=$((${csize}* (60/${interval}) ))
    chour=$((${cmin}*60))
    msg="$target, net+/-: ${csize}$desc, ${cmin}$desc/min, ${chour}$desc/hr, now: ${size}$desc"
    #if ([ $firstrun -ne 1 ] && [ $csize -eq 0 ]); then break; fi
    if [ $inplace -eq 1 ]; then echo -e "\e[1A $msg"; else echo $msg; fi
    firstrun=0
    sleep $interval
done
