#!/bin/bash
#set -x

function print_all() {
    WWNS="wwn-0x5002538e70089ea5
wwn-0x5002538e70089eab
wwn-0x5002538e700fc4d6
wwn-0x5002538e700fc4d2"

    for wwn in `echo $WWNS`; do
    dev=`realpath /dev/disk/by-id/$wwn`
    echo -n "md126:$dev "
    sudo smartctl --info --all $dev | grep Temperature_Celsius | awk '{print " " $10"C",$11,$12}'
    done

    #set +x
}

function print_one() {
    wwn=$1
    dev=`realpath /dev/disk/by-id/$wwn`
    name=`echo $dev | awk -F/ '{print $3}'`
    temp=`sudo smartctl --info --all $dev | grep Temperature_Celsius | awk '{print " " $10"C",$11,$12}'`
    printf "$temp (65C Crit) /dev/$name"
}

print_one $1
