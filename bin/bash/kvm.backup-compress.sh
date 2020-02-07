#!/bin/bash
#--------------------------------------------------------------------------------------------------#
#-- Name     : kvm.backup-compress.sh
#-- Purpose  : Run backup of libvirt VMs
#-- Author   : EM Winterschon
#-- Repo     : https://github.com/em-winterschon/libvirt-kvm-scripts
#-- Requires : /opt/nfs-shared/bin/kvm.nodes-backup
#------------:
#-- Date     : 2019-10-12
VERSION="1.7"
#--------------------------------------------------------------------------------------------------#

# Generic vars
LANG=en_US

# Identify this script in journald output
SCRIPTNAME=kvm.backup-compress.sh

## Prints errors
function _self.error() {
    echo -e "$1"
    exit $2;
}

## Prints banner info
function _banner() {
    cat<<EOF
-----------------------------------------------------------------------------------
Script  : $SCRIPTNAME
Purpose : Run backup of libvirt VMs w/ optional compression
Author  : eva@bonitabel.la
Repo    : https://github.com/em-winterschon/libvirt-kvm-scripts
Version : $VERSION
-----------------------------------------------------------------------------------
EOF
}

## Prints help info
function _self.help() {
    _banner
    cat<<EOF
Default Settings
-------------------
backupdir:	${BACKUPDIR}
compression:	$COMPRESSION
debug:		$debugging
dryrun:         $DRYRUN_HR
logdest:        $LOGDEST
method:		$METHOD
onedomain:      $ONEDOMAIN
processors:	$PROCESSORS
quiet:          $quiet
rate:		$RATE
snapshots:	${SNAPDIR}


Domain Options
-------------------
 -o, --onedomain    single domain to backup [string] [default: none/all]

Directories
-------------------
 -b, --backupdir    backup destination [path] [default: /var/lib/libvirt/backup]	
 -s, --snapshots    snapshot tmp file dir [path] [default: /var/lib/libvirt/images]	

Archive Compression 
-------------------
 -c, --compression  enable compression [yes/no] [default: yes]
 -m, --method	    compression method [7z,pigz,gzip] [default: 7z]
 -p, --processors   cores for compression [integer] [default: output of `nproc`]
 -r, --rate         compression level if enabled [fast/medium/max] [default: max]

Output Logging
-------------------
 -l, --logdest      logging method [stdout,systemd] [default: systemd]
 -q, --quiet        minimal output for scripting [default: none]
 -x, --debug        debugging enabled (equiv to bash "set -x") [default: none]

Output Logging
-------------------
-d, --dryrun        test run without executing backups

Script Usage   
-------------------
$SCRIPTNAME [options]

Example (minimum): $SCRIPTNAME
Example (debug):   $SCRIPTNAME --debug
Example (options): $SCRIPTNAME -b /mnt/backups -c no -x
Example (options): $SCRIPTNAME --method pigz --rate fast --quiet
-----------------------------------------------------------------------------------

EOF
}

## Non-GetOpts vars
LOC_DATE=`date +%Y%m%d-%H%M`
help="no"
skip="no"
set=null

## Set defaults for GetOpts
BACKUPDIR="/var/lib/libvirt/backups"
SNAPDIR="/var/lib/libvirt/images"
CONFIGLOG=`mktemp -t ${SCRIPTNAME}.XXXXXXXX`

COMPRESSION="yes"
METHOD="7z"
PROCESSORS=`nproc`
RATE="max"

ONEDOMAIN="all"
DRYRUN="no"
DRYRUN_HR="disabled"
LOGDEST="systemd"
debugging="no"
quiet="no"

## Check UID
if [ $UID -ne 0 ]; then
    echo "You are not root or not using sudo, please rerun with proper permissions."
    exit 127;
fi

## Check ARGV array
if [ $# -eq 0 ]; then
    _self.help;
    exit 127;
else
    if [ $# -eq 1 ]; then
	if [ $1 = "-h" ]; then
	    _self.help; exit 127;
	elif [ $1 = "--help" ]; then
	    _self.help; exit 127; 
	else
	    skip="no";
	fi
    fi
fi

## Check/Set GetOpts
if [ $skip = "no" ]; then
    while [ $# -gt 0 ]; do
	case $1 in
	    ## short opts
	    -h|--help) help="yes" ;;
	    -x|--debug) debugging="yes" ;;
	    -q|--quiet) quiet="yes" ;;
	    ## long opts need additional shift
	    -b|--backupdir) BACKUPDIR="$2" ; shift;;
	    -c|--compression) COMPRESSION="$2" ; shift;;
	    -d|--dryrun) DRYRUN="$2" ; shift;;
	    -l|--logdest) LOGDEST="$2" ; shift ;;
	    -m|--method) METHOD="$2" ; shift;;
	    -o|--onedomain) ONEDOMAIN="$2" ; shift;;
	    -p|--processors) PROCESSORS="$2" ; shift;;
	    -r|--rate) RATE="$2" ; shift;;
	    -s|--snapshots) SNAPDIR="$2" ; shift;;
	    (--) shift; break;;
	    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	    (*) break;;
	esac
	shift
    done
fi

## Var translations
LOC_BACKUP="${BACKUPDIR}/${LOC_DATE}"
CORES=$PROCESSORS

## Check debug
if [ "$debugging" = "yes" ]; then
    set -x;
else
    set +x;
fi

## Check dryrun
if [ "$DRYRUN" != "no" ]; then
    DRYRUN=1
    DRYRUN_HR="enabled"
    quiet="no"
else
    DRYRUN=0
    DRYRUN_HR="disabled"
    quiet="yes"
fi

## Internal functions
function fail() {
    MSG=$1
    NOW=`date +%Y%m%d-%H%M%S`
    if [ "$LOGDEST" = "systemd" ]; then
	which systemd-cat >/dev/null 2>&1
	if [ $? -ne 0 ]; then
	    echo "[FAILED][$NOW] Could not locate systemd-cat binary in PATH. Use '--logdest stdout' as script ARG"
	    exit 1;
	else
	    echo "[FAILED][$NOW] $MSG" | systemd-cat -t $SCRIPTNAME
	fi
    elif [ "$LOGDEST" = "stdout" ]; then
	echo "[FAILED][$NOW] $MSG"
    else
	echo "Option --logdest specified incorrectly."
	_self.help
    fi
    exit 1;
}

function debug() {
    MSG=$1
    NOW=`date +%Y%m%d-%H%M%S`
    if [ "$LOGDEST" = "systemd" ]; then
	which systemd-cat >/dev/null 2>&1
	if [ $? -ne 0 ]; then
	    echo "[DEBUG][$NOW] Could not locate systemd-cat binary in PATH. Use '--logdest stdout' as script ARG"
	    exit 1;
	else
	    echo "[DEBUG][$NOW] $MSG" | systemd-cat -t $SCRIPTNAME
	fi
    elif [ "$LOGDEST" = "stdout" ]; then
	echo "[FAILED][$NOW] $MSG"
    else
	echo "Option --logdest specified incorrectly."
	_self.help
    fi
}

## Binary check
which virsh >/dev/null 2>&1
if [ $? -ne 0 ]; then
    fail "Could not locate virsh binary in PATH. Exiting."
fi

## Display config info
if [ "$quiet" != "yes" ]; then
    _banner
        cat<<EOF
Configuration 
---------------
backupdir:	${BACKUPDIR}
compression:	$COMPRESSION
debug:		$debugging
dryrun:         $DRYRUN_HR
logdest:        $LOGDEST
method:		$METHOD
onedomain:      $ONEDOMAIN
processors:	$PROCESSORS
quiet:          $quiet
rate:		$RATE
snapshots:	${SNAPDIR}
EOF

	echo "-----------------------------------------------------------------------------------"
fi


# Check if running backups for all DOMs or single
if [ "$ONEDOMAIN" = "all" ]; then
    DOMAINS=$(virsh list | tail -n +3 | awk '{print $2}')
    DL=`echo $DOMAINS | sed -z 's/\n//g'`
else     
    DOMAINS="$ONEDOMAIN"
    DL=$DOMAINS
fi
if [ $DRYRUN -eq 1 ]; then
    cat<<EOF 
+ KVM Domains to backup: 
  [$DL]

EOF
fi
debug "Domain list: ${DL}"
    
# Loop over the domains and issue snapshots
for DOMAIN in $DOMAINS; do
    if [ $DRYRUN -eq 1 ]; then
	cat<<EOF 
++ Starting backup loop for domain: $DOMAIN

EOF
    fi
    
    DATE_START=`date +%Y%m%d-%H%M%S`
    debug "Starting backup for $DOMAIN on ${DATE_START}" 

    # Generate the backup folder URI - this is something you should
    # change/check
    LOC_DOMDIR=${LOC_BACKUP}/${DOMAIN}
    XML_DEFS="${LOC_DOMDIR}/xmldefs"
    mkdir -p ${LOC_DOMDIR}

    # Get the target disk
    TARGETS=$(virsh domblklist $DOMAIN --details | grep disk | awk '{print $3}')

    # Get the image page
    IMAGES=$(virsh domblklist $DOMAIN --details | grep disk | awk '{print $4}')

    # Create the snapshot/disk specification via loop
    # Initial DISKSPEC="" allows for alternate options if desired
    DISKSPEC=""
    for TARGET in $TARGETS; do
	DISKSPEC="$DISKSPEC --diskspec $TARGET,snapshot=external"
    done

    if [ $DRYRUN -eq 1 ]; then
	cat<<EOF 
++++ Creating in-place snapshot of domain disks 
 virsh snapshot-create-as --domain $DOMAIN --name "${DATE_START}.snapshot.tmp" \
 --no-metadata --atomic --disk-only $DISKSPEC 1>/dev/null 2>&1

EOF
    else
	virsh snapshot-create-as --domain $DOMAIN --name "${DATE_START}.snapshot.tmp" \
	      --no-metadata --atomic --disk-only $DISKSPEC 1>/dev/null 2>&1
    fi
	
    if [ $? -ne 0 ]; then
	debug "Failed to create snapshot for $DOMAIN"
	exit 1
    fi

    # Copy disk image
    for IMAGE in $IMAGES; do
	NAME=$(basename $IMAGE)
	if [ $DRYRUN -eq 1 ]; then
	    cat<<EOF 
++++ Copying domain disk images
 rsync -aq --sparse $IMAGE $LOC_DOMDIR/$NAME

EOF
	else
	    rsync -aq --sparse $IMAGE $LOC_DOMDIR/$NAME
	fi
    done

    # Merge changes back
    BACKUPIMAGES=$(virsh domblklist $DOMAIN --details | grep disk | awk '{print $4}')

    for TARGET in $TARGETS; do
	if [ $DRYRUN -eq 1 ]; then
	    cat<<EOF 
++++ Merging domain block changes from temp snapshot
 virsh blockcommit $DOMAIN $TARGET --active --pivot 1>/dev/null 2>&1

EOF
	else
	    virsh blockcommit $DOMAIN $TARGET --active --pivot 1>/dev/null 2>&1
	fi

	if [ $? -ne 0 ]; then
	    debug "Could not merge changes for disk of $TARGET of $DOMAIN. VM may be in invalid state." 
	    exit 1
	fi
    done

    # Cleanup left over backups
    for BACKUP in $BACKUPIMAGES; do
	if [ $DRYRUN -eq 1 ]; then
	    cat<<EOF 
++++ Removing temp domain image files
 rm -f $BACKUP

EOF
	else
	    rm -f $BACKUP
	fi
    done

    # Dump the configuration information.
    if [ $DRYRUN -eq 1 ]; then
	cat<<EOF 
++++ Exporting domain config XML file
 mkdir -p ${XML_DEFS}
 virsh dumpxml $DOMAIN > ${XML_DEFS}/$DOMAIN.xml

EOF
    else
	mkdir -p ${XML_DEFS}
	virsh dumpxml $DOMAIN > ${XML_DEFS}/$DOMAIN.xml
    fi

    # Compress snapshots in order of compression binary availability: 7za -> pigz -> gzip -> tar
    CORES=`nproc`
    COMPRESSED="${LOC_DOMDIR}.${DATE_START}"
    which 7za >/dev/null 2>&1;
    if [ $? -eq 0 ]; then
	OUTFILE="${COMPRESSED}.tar.7z"	
	if [ $DRYRUN -eq 1 ]; then
	    cat<<EOF 
++++ Compressing domain image backups via 7zip
 ( tar cf - ${LOC_DOMDIR} 2>/dev/null | \
 7za a -mmt=${CORES} -mx=3 -si ${OUTFILE} 1>/dev/null 2>&1 ) && \
 rm -rf ${LOC_DOMDIR}

EOF
	else
	    ( tar cf - ${LOC_DOMDIR} 2>/dev/null | \
		7za a -mmt=${CORES} -mx=3 -si ${OUTFILE} 1>/dev/null 2>&1 ) && \
	    rm -rf ${LOC_DOMDIR}
	fi
    else
	which pigz >/dev/null 2>&1;
	if [ $? -eq 0 ]; then
	    OUTFILE="${COMPRESSED}.tar.gz"
	if [ $DRYRUN -eq 1 ]; then
	    cat<<EOF 
++++ Compressing domain image backups via pigz
 ( tar cf - ${LOC_DOMDIR} 2>/dev/null | \
 pigz --fast --processes ${CORES} > ${OUTFILE} 1>/dev/null 2>&1 ) && \
 rm -rf ${LOC_DOMDIR}

EOF
	else
	    ( tar cf - ${LOC_DOMDIR} 2>/dev/null | \
		    pigz --fast --processes ${CORES} > ${OUTFILE} 1>/dev/null 2>&1 ) && \
		rm -rf ${LOC_DOMDIR}
	fi
	else
	    which gzip >/dev/null 2>&1;
	    if [ $? -eq 0 ]; then
		OUTFILE="${COMPRESSED}.tar.gz"		
	if [ $DRYRUN -eq 1 ]; then
	    cat<<EOF 
++++ Compressing domain image backups via gzip
 ( tar cf - ${LOC_DOMDIR} 2>/dev/null | \
 gzip --fast > ${OUTFILE} 1>/dev/null 2>&1 ) && \
 rm -rf ${LOC_DOMDIR}

EOF
	else
	    ( tar cf - ${LOC_DOMDIR} 2>/dev/null | \
		    gzip --fast > ${OUTFILE} 1>/dev/null 2>&1 ) && \
		rm -rf ${LOC_DOMDIR}
	fi
	    else
		if [ $DRYRUN -eq 1 ]; then
		    cat<<EOF 
++++ Archiving domain image backups via tar without compression
 ( tar cf ${LOC_DOMDIR}.tar ${LOC_DOMDIR} 1>/dev/null 2>&1 ) && \
 rm -rf ${LOC_DOMDIR}

EOF
		else
		    ( tar cf ${LOC_DOMDIR}.tar ${LOC_DOMDIR} 1>/dev/null 2>&1 ) && \
			rm -rf ${LOC_DOMDIR}
		fi
	    fi
	fi
    fi
    
    DATE_END=`date +%Y%m%d-%H%M%S` 
    debug "Finished backup of $DOMAIN at ${DATE_END}"
done

exit 0
