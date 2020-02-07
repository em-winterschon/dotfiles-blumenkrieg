## Commands to mount ZFS share if it's not loaded after boot

### Might be useful
systemctl status zfs-mount
systemctl restart zfs-mount


### List available pools
» zpool list

   pool: zr2.sata
     id: 16964641305140691280
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

    zr2.sata                                      ONLINE
      raidz2-0                                    ONLINE
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1E649WRPY  ONLINE
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83LH120  ONLINE
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83HDU83  ONLINE
        ata-WDC_WD10JFCX-68N6GN0_WD-WXT1EA59VTRV  ONLINE
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1EB50EFD0  ONLINE
        16964641305140691280                      ONLINE
    cache
      sda


### Import the pool
» zpool import zr2.sata
» zpool status zr2.sata

  pool: zr2.sata
 state: ONLINE
  scan: none requested
config:

    NAME                                          STATE     READ WRITE CKSUM
    zr2.sata                                      ONLINE       0     0     0
      raidz2-0                                    ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1E649WRPY  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83LH120  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83HDU83  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXT1EA59VTRV  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1EB50EFD0  ONLINE       0     0     0
        16964641305140691280                      ONLINE       0     0     0
    cache
      sda


### Show mountpoint for pool
» zfs get mountpoint zr2.sata

NAME      PROPERTY    VALUE                            SOURCE
zr2.sata  mountpoint  /opt/storage/local/zfs/zr2.sata  local


### Check to see if filesystem is online

» df -h
Filesystem     Size  Used Avail Use%                           Mounted on
/dev/vg1/root 7935M 2549M 4961M 32.1 [#######................] /
/dev/sdc1      504M  120M  359M 23.8 [#####..................] /boot
zr2.sata      3592G 2358G 1234G 65.6 [###############........] /opt/storage/local/zfs/zr2.sata
/dev/vg1/var   109G   57G   52G 52.5 [############...........] /var


## Checking Serials

### Check drives to see serial numbers (they should match in zpool status)
» for i in c d e f g h; do echo -n "/dev/sd$i: "; hdparm -I /dev/sd$i | awk '/Serial Number/ {print $3}'; done
/dev/sdc: WD-WXL1E649WRPY
/dev/sdd: WD-WX11E83LH120
/dev/sde: WD-WX11E83HDU83
/dev/sdf: WD-WXT1EA59VTRV
/dev/sdg: WD-WXL1EB50EFD0
/dev/sdh: WD-WXE1E14UYN13

» zpool status
  pool: zr2.sata
 state: ONLINE
config:

    NAME                                          STATE     READ WRITE CKSUM
    zr2.sata                                      ONLINE       0     0     0
      raidz2-0                                    ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1E649WRPY  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83LH120  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83HDU83  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXT1EA59VTRV  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1EB50EFD0  ONLINE       0     0     0
        16964641305140691280                      ONLINE       0     0     0
    cache
      sda                                         ONLINE       0     0     0

errors: No known data errors


## Scrubbing, etc

You need to scrub the pool once in a while, manually or via crontab

### Via crontab

» c /etc/crontab
0 2 * * 1 root    /sbin/zpool scrub zr2.sata

### Manually

» zpool scrub zr2.sata

» zpool status
  pool: zr2.sata
 state: ONLINE
  scan: scrub in progress since Sun Feb 17 13:04:19 2019
    848G scanned out of 3.53T at 378M/s, 2h4m to go
    0 repaired, 23.49% done
config:

    NAME                                          STATE     READ WRITE CKSUM
    zr2.sata                                      ONLINE       0     0     0
      raidz2-0                                    ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1E649WRPY  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83LH120  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WX11E83HDU83  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXT1EA59VTRV  ONLINE       0     0     0
        ata-WDC_WD10JFCX-68N6GN0_WD-WXL1EB50EFD0  ONLINE       0     0     0
        16964641305140691280                      ONLINE       0     0     0
    cache
      sda                                         ONLINE       0     0     0


