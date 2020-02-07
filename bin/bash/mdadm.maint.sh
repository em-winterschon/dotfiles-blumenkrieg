#--------------------------------------------------------------------------------------------------#
#-- Name     : mdadm.maint.sh
#-- Purpose  : Software RAID maintenenace script for /dev/md/2_0
#-- Author   : EM Winterschon
#-- Repo     : https://github.com/em-winterschon/dotfiles
#-- Requires : mdadm
#------------:
#-- Date     : 2018-12-04
#-- Version  : 1.0
#--------------------------------------------------------------------------------------------------#
echo "NOTE: this only applies to /dev/md/2_0 - if your RAID is named otherwise you'll need to edit the script."
echo "Press any key to continue, ctrl-c to quit."
read C

echo "Scanning devices..."
mdadm --detail --scan     
mdadm --detail /dev/md/2_0     
sleep 3

echo "Examining /dev/md/2_0 partitions (sdc1, sdd1)"
mdadm --examine /dev/sdc1 /dev/sdd1     
echo "Press any key to continue, ctrl-c to quit"
read C

echo "Stopping /dev/md/2_0 (ctrl-c to cancel)"
sleep 5
mdadm --stop /dev/md/2_0     

echo "Reassembling affected RAID in 5 sec (ctrl-c to cancel)"
sleep 5
mdadm --assemble --run --force --update=resync /dev/md2 /dev/sdc1 /dev/sdd1

echo "Scanning RAID..."
sleep 5
mdadm --detail --scan     
mdadm --detail /dev/md2     

echo -n "Do you see /dev/md2? [y:N] "
read MD2
if [ "$MD2" = "y" ] || [ "$MD2" = "Y" ]; then
    echo "Mounting /dev/md2"
    mount /dev/md2 /opt/backup-md2
    if [ $? -ne 0 ]; then
	echo "Failed to mount /dev/md2"
	exit 127;
    fi
else
    echo "No... ok. Scanning RAID."
    mdadm --detail --scan     
    echo "Troubleshoot as needed. Exiting."
    exit 0;
fi

echo "Mount device /dev/md2 as needed. Exiting."
exit 0;


    
