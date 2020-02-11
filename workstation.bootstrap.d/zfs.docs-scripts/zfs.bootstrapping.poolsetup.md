### ZFS option files and kernel params
```
ls /sys/module/zfs/parameters/
```

#### Modprobe options file
If you need to check if /etc/modprobe.d/zfs.conf options are being loaded at boot, run...
```
for each in `cat.nocomments /etc/modprobe.d/zfs.conf | awk '{print $3}' | awk -F= '{print $1}'`; do echo $each && cat /sys/module/zfs/parameters/$each; done
```

### iostats for a specific pool
```
cat /proc/spl/kstat/zfs/viergigs/iostats
```

### list memory related info for memory and l2arc
```
cat /proc/spl/kstat/zfs/arcstats | egrep memory_free_bytes\|memory_available_bytes\|l2_size\|c_min\|c_max | awk '{print $1" = " int($3 / 1024 / 1024)" Mb"}'
```

## lsblk list
```
sdg                                                 8:96   1   3.5T  0 disk
sdh                                                 8:112  1   3.5T  0 disk
sdi                                                 8:128  1   3.5T  0 disk
sdj                                                 8:144  1   3.5T  0 disk
sdk                                                 8:160  1   3.5T  0 disk
sdl                                                 8:176  1   3.5T  0 disk
nvme0n1                                           259:0    0 238.5G  0 disk
```

## WWN block list
```
» l /dev/disk/by-id/ | egrep sdg\|sdh\|sdi\|sdj\|sdk\|sdl\|nvme | egrep wwn\|eui | grep -v part
lrwxrwxrwx 1 root root 13 2020-02-01 07:46 nvme-eui.002538686100444e -> ../../nvme0n1
lrwxrwxrwx 1 root root  9 2020-02-01 07:46 wwn-0x5002538e700962df -> ../../sdl
lrwxrwxrwx 1 root root  9 2020-02-01 07:46 wwn-0x5002538e700962e4 -> ../../sdh
lrwxrwxrwx 1 root root  9 2020-02-01 07:46 wwn-0x5002538e700962e6 -> ../../sdj
lrwxrwxrwx 1 root root  9 2020-02-01 07:46 wwn-0x5002538e700962ec -> ../../sdg
lrwxrwxrwx 1 root root  9 2020-02-01 07:46 wwn-0x5002538e700cb7e1 -> ../../sdi
lrwxrwxrwx 1 root root  9 2020-02-01 07:46 wwn-0x5002538e700cd609 -> ../../sdk
```

## Zpool create mirror set
sudo zpool create viergigs mirror wwn-0x5002538e700962df wwn-0x5002538e700962e4 mirror wwn-0x5002538e700962e6 wwn-0x5002538e700962ec mirror wwn-0x5002538e700cb7e1 wwn-0x5002538e700cd609 cache nvme-eui.002538686100444e

## Status
```
» zpool status
  pool: viergigs
 state: ONLINE
  scan: none requested
config:

        NAME                         STATE     READ WRITE CKSUM
        viergigs                     ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            wwn-0x5002538e700962df   ONLINE       0     0     0
            wwn-0x5002538e700962e4   ONLINE       0     0     0
          mirror-1                   ONLINE       0     0     0
            wwn-0x5002538e700962e6   ONLINE       0     0     0
            wwn-0x5002538e700962ec   ONLINE       0     0     0
          mirror-2                   ONLINE       0     0     0
            wwn-0x5002538e700cb7e1   ONLINE       0     0     0
            wwn-0x5002538e700cd609   ONLINE       0     0     0
        cache
          nvme-eui.002538686100444e  ONLINE       0     0     0

errors: No known data errors
```

## Create encryption MD5 string file
Execute the following, input the desired string to get the MD5 string
```
echo -n "str: " && read x && echo -n "$x" | openssl md5 | awk '{print $2}'
```

Save the string to root's home dir.
```
sudo emacs /root/.zfs-key.viergigs.enc
```

## Update pool with encryption key setting
```
sudo zpool set feature@encryption=enabled viergigs
sudo zfs create -o encryption=on -o keyformat=raw -o keylocation=file:///root/.zfs-key.viergigs.enc viergigs/einsraum
```

## View key info
```
» zfs get -p keyformat,keylocation viergigs/einsraum
NAME               PROPERTY     VALUE                               SOURCE
viergigs/einsraum  keyformat    raw                                 -
viergigs/einsraum  keylocation  file:///root/.zfs-key.viergigs.enc  local
```

## Update mountpoint for encrypted pool
```
sudo zfs set mountpoint=/opt/storage/local/zfs/viergigs/einsraum viergigs/einsraum
```

## View zpool L2ARC stats
From the /proc dir
```
cat /proc/spl/kstat/zfs/arcstats
```

Or using arcstat
```
» arcstat                                                                                                               │
    time  read  miss  miss%  dmis  dm%  pmis  pm%  mmis  mm%  arcsz     c                                               │
08:24:36     0     0      0     0    0     0    0     0    0   2.2M  7.7G
```


## References
- https://docs.oracle.com/cd/E23824_01/html/821-1448/gkkih.html
- https://blog.heckel.io/2017/01/08/zfs-encryption-openzfs-zfs-on-linux/
- https://www.oracle.com/technetwork/articles/servers-storage-admin/manage-zfs-encryption-1715034.html
- http://www.fibrevillage.com/storage/169-zfs-arc-on-linux-how-to-set-and-monitor-on-linux
- https://github.com/joyent/pivy
