## List devices and arrays
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
cat /proc/mdstat

## Paste output from above commands

## Determine appropriate devices for array

## Prepare devices for array
mdadm --zero-superblock /dev/sd?
mdadm --zero-superblock /dev/sd?

## Create RAID-1 array
mdadm --create --verbose /dev/md? --level=1 --raid-devices=2 /dev/sd? /dev/sd?

## Check array success/fail
cat /proc/mdstat

## Create filesystem
mkfs.ext4 -F /dev/md?

## Create mount point
mkdir -p /opt/storage/array/DESIREDNAME

## Mount array
mount /dev/md? /opt/storage/array/DESIREDNAME

## Check if new space is available
df -h -x devtmpfs -x tmpfs

## Save array layout 
mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

## Update initramfs
update-initramfs -u

## Add array mount to boot sequence
echo '/dev/md? /opt/storage/array/DESIREDNAME ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab


