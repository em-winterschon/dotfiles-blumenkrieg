#!/bin/bash
list="c d e f g h i j k l m n o p q r"
for e in `echo $list`; do
    dev="sd${e}"
    wwn=`ls -al /dev/disk/by-id/ | egrep sd${e} | egrep wwn | grep -v part | awk '{print $9}'`
    #echo $wwn
    cat<<EOF
{color magenta}/dev/$dev:${color}  {diskio_read $dev}/s                 {diskio_write $dev}/s         {execi 10 ~/bin/bash/smartctl.temps.sh $wwn}
EOF
done
