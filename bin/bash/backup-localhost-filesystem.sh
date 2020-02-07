#!/bin/bash
#--------------------------------------------------------------------------------------------------#
#-- Name     : backup-localhost-filesystem.sh
#-- Purpose  : Backup Archiver for localhost filesystems
#-- Author   : EM Winterschon
#-- Repo     : https://github.com/em-winterschon/dotfiles
#-- Requires : tar with xz 
#-- Reference: https://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html
#------------:
#-- Date     : 2019-12-01
VERSION="1.5"
#--------------------------------------------------------------------------------------------------#

# Generic vars
LANG=en_US

# Identify this script in journald output
SCRIPTNAME=backup-localhost-filesystem.sh

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
Purpose : Backup Archiver for localhost filesystems
Author  : em-winterschon
Repo    : https://github.com/em-winterschon/dotfiles
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
fsmount:        ${FS}
compression:	$COMPRESSION
debug:		$debugging
dryrun:         $DRYRUN_HR
logdest:        $LOGDEST
quiet:          $quiet
priority:	$PRIORITY


Directories
-------------------
 -f, --fsmount      backup sourc via --one-file-system opt in tar [default: none]
 -b, --backupdir    backup destination [path] [default: /var/lib/libvirt/backup]	
 -e, --exclude      dirs to exclude from backup, comma separated list...
                     default fixed excludes: /dev,/proc/,/sys,/run,/tmp

Archive Options
-------------------
 -c, --compression  enable 7za compression [yes/no] [default: yes]
 -i, --incremental  enable incremental functionality for tar [yes/no] [default:no]
 -p, --priority     set 'nice' process priority level [19 to -20] [default: 18]

Output Logging
-------------------
 -l, --logdest      logging method [stdout,systemd] [default: systemd]
 -q, --quiet        minimal output for scripting [default: none]
 -x, --debug        debugging enabled (equiv to bash "set -x") [default: none]

Listing Archives
-------------------
To view files included in an incremental tar archive, use the following command:
Ref: https://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html
> tar --list --incremental --verbose --verbose --file <archive-file-here>

Output will show each file in the archive and its presence state via tags:
Y = included in the present archive file
N = not included, should be in a previous incremental file
D = file is a directory 
Ref: https://www.gnu.org/software/tar/manual/html_node/Dumpdir.html#SEC195


Dry Run 
-------------------
-d, --dryrun        test run without executing backups

Script Usage   
-------------------
$SCRIPTNAME [options]

Example (minimum): --fsmount /home
Example (debug):   --fsmount /home --logdest stdout --debug
Example (short):   -f /home -b /backups -c no -x -e /home/foo,/home/bar
Example (long):    --fsmount /home --compression no --exclude /opt/nfs-shared,/home
-----------------------------------------------------------------------------------

EOF
}

## Non-GetOpts vars
LOC_DATE=`date +%Y%m%d-%H%M`
help="no"
skip="no"
set=null

## Set defaults for GetOpts

BACKUPDIR="/mnt/backup/backups/tar-archive"
COMPRESSION="yes"
CONFIGLOG=`mktemp -t ${SCRIPTNAME}.XXXXXXXX`
DRYRUN="no"
DRYRUN_HR="disabled"
EXCLUDES=""
FSMOUNT=""
INCREMENTAL="no"
LOGDEST="systemd"
PRIORITY="18"
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
	    -f|--fsmount) FSMOUNT="$2" ; shift ;;
	    -c|--compression) COMPRESSION="$2" ; shift;;
	    -d|--dryrun) DRYRUN="$2" ; shift;;
	    -i|--incremental) INCREMENTAL="$2" ; shift ;;
	    -l|--logdest) LOGDEST="$2" ; shift ;;
	    -p|--priority) PRIORITY="$2" ; shift ;;
	    -e|--exclude) EXCLUDES="$2" ; shift;;
	    (--) shift; break;;
	    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	    (*) break;;
	esac
	shift
    done
fi

## Excluded dirs loop
LIST=`echo $EXCLUDES | sed -e 's/,/ /g'`
EXLIST="--exclude /dev --exclude /proc --exclude /run --exclude /sys --exclude /tmp"
for each in $LIST; do
    EXLIST="${EXLIST} --exclude ${each}"
done


## Var translations
LOC_BACKUP="${BACKUPDIR}"

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
	    echo "[${DOMAIN}:${FSMOUNT}][FAILED][$NOW] Could not locate systemd-cat binary in PATH. Use '--logdest stdout' as script ARG"
	    exit 1;
	else
	    echo "[${DOMAIN}:${FSMOUNT}][FAILED][$NOW] $MSG" | systemd-cat -t $SCRIPTNAME
	fi
    elif [ "$LOGDEST" = "stdout" ]; then
	echo "[${DOMAIN}:${FSMOUNT}][FAILED][$NOW] $MSG"
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
	    echo "[${DOMAIN}:${FSMOUNT}][DEBUG][$NOW] Could not locate systemd-cat binary in PATH. Use '--logdest stdout' as script ARG"
	    exit 1;
	else
	    echo "[${DOMAIN}:${FSMOUNT}][DEBUG][$NOW] $MSG" | systemd-cat -t $SCRIPTNAME
	fi
    elif [ "$LOGDEST" = "stdout" ]; then
	echo "[${DOMAIN}:${FSMOUNT}][DEBUG][$NOW] $MSG"
    else
	echo "Option --logdest specified incorrectly."
	_self.help
    fi
}

## Binary check
which tar >/dev/null 2>&1
if [ $? -ne 0 ]; then
    fail "Could not locate tar binary in PATH. Exiting."
fi

## Check Filesystem Mount and determine filesystem mount name without slashes
if [ "$FSMOUNT" = "" ]; then
    fail "Filesystem mount (--fsmount) not set, cannot continue."
else
    FSNAME=`echo "${FSMOUNT}" | sed -e s'/\//-/g'`
    if [ "$FSNAME" = "-" ]; then
	FSNAME="-root"
    fi
fi

if [ $COMPRESSION = "no" ]; then
    RATE="none"
fi

## Basic vars
DATE_START=`date +%Y%m%d-%H%M%S`
DOMAIN=${HOSTNAME}
debug "Starting backup for $DOMAIN on ${DATE_START}"

# Determine options for incremental backups
if [ $INCREMENTAL = "yes" ]; then
    FILE="${DOMAIN}.icrmt.fs${FSNAME}.${DATE_START}"
    INCFILE="${DOMAIN}.icrmt.fs${FSNAME}.icrmt.log.snar"
else
    FILE="${DOMAIN}.fs${FSNAME}.${DATE_START}"
fi

# Generate the backup folder
LOC_DOMDIR="${LOC_BACKUP}/fs${FSNAME}"
FILEMAIN="${LOC_DOMDIR}/${FILE}"

# Assign directory for incremental file if required
if [ $INCREMENTAL = "yes" ]; then
    INCOPT="--listed-incremental=${LOC_DOMDIR}/${INCFILE}"
else
    INCOPT=""
fi

## Determine filename based on compression
if [ $COMPRESSION = "yes" ]; then
    OUTFILE="${FILEMAIN}.tar.xz"
else
    OUTFILE="${FILEMAIN}.tar"
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
destfile:       ${OUTFILE}
dryrun:         $DRYRUN_HR
exclude:        ${EXCLUDE}
fsmount:        ${FSMOUNT}
fsname:         ${FSNAME}
incremental:    $INCREMENTAL
logdest:        $LOGDEST
quiet:          $quiet
EOF

	echo "-----------------------------------------------------------------------------------"
fi

if [ $DRYRUN -eq 1 ]; then
    cat<<EOF 
++++ Creating backup directory
> mkdir -p ${LOC_DOMDIR} 

EOF
else
    mkdir -p ${LOC_DOMDIR} || fail "Backup dir [${LOC_DOMDIR}] could not be created."
fi

if [ $COMPRESSION = "yes" ]; then
    if [ $DRYRUN -eq 1 ]; then
	cat<<EOF 
++++ Executing filesystem backup with 7za compression
> nice --adjustment $PRIORITY tar -cp --xz --exclude=${BACKUPDIR} ${EXLIST} --file ${OUTFILE} ${FSMOUNT} 1>/dev/null 2>&1

EOF
    else
	nice --adjustment $PRIORITY tar -cp --xz --exclude=${BACKUPDIR} ${EXLIST} --file ${OUTFILE} ${FSMOUNT} 1>/dev/null 2>&1
	if [ $? -ne 0 ]; then fail "Backup status [${DOMAIN}:{FSMOUNT}]: [FAILED]"; fi	
    fi
    
else
    if [ $DRYRUN -eq 1 ]; then
	cat<<EOF 
++++ Executing filesystem backup via tar without compression
> nice --adjustment $PRIORITY tar -cp --exclude=${BACKUPDIR} ${EXLIST} ${INCOPT} --file ${OUTFILE} ${FSMOUNT} 1>/dev/null 2>&1 

EOF
    else
	nice --adjustment $PRIORITY tar -cp --exclude=${LOC_DOMDIR} ${EXLIST} ${INCOPT} --file ${OUTFILE} ${FSMOUNT} 1>/dev/null 2>&1	
	if [ $? -ne 0 ]; then fail "Backup status [${DOMAIN}:{FSMOUNT}]: [FAILED]"; fi
    fi
fi
    
DATE_END=`date +%Y%m%d-%H%M%S` 
debug "Finished backup of [${DOMAIN}:${FSMOUNT}] to [${OUTFILE}] at ${DATE_END}"

exit 0;
