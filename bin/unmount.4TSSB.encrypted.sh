#!/bin/bash

echo -n "Ready to unmount? [enter/ctrl-c]"
read c
sudo umount /mnt/backup
sudo cryptsetup luksClose /dev/mapper/4TSSD && \
    echo -e "\n\n[COMPLETE]"



