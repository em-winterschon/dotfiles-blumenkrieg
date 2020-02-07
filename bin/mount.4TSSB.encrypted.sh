#!/bin/bash

echo -n "Enter device for USB disk: /dev/"
read dev
echo -n "Ready to mount? [enter/ctrl-c]"
read c
sudo cryptsetup luksOpen /dev/$dev 4TSSD

echo "Ensure 4TSSD is listed in the following output:"
ls -al /dev/mapper | grep "4TSSD"

echo -n "Look good? [enter/ctrl-c]"
read c
echo -n "Mounting /dev/mapper/4TSSD to /mnt/backup"
sudo mount /dev/mapper/4TSSD /mnt/backup && echo -e "\n\n[COMPLETE]"


