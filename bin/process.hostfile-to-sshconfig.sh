#!/bin/bash 
for each in `cat ~/etc/accounts.work`; do
    short=`echo $each | awk -F. '{print $1}'`
    long=$each
    cat<<EOF
Host $short
     Hostname  $long
     User      root

EOF
done
