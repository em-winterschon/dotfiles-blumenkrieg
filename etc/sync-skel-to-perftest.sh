#!/bin/bash

username="$USER"
hostfile="~/etc/hosts.sync"
help="no"
skip="no"
git="no"
dryrun="no"
exec="no"
skeldir=~/Projects/skel

function _self.help() {
    cat<<EOF
Default Settings
-------------------
username: $username
hostfile: $hostfile
emacs:    $emacs
dryrun:   $dryrun

General Options
-------------------
 -u, --username     set username for remote host [default: $USER]
 -f, --hostfile     filename containing hostnames for sync [default: ~/etc/hosts.sync]

Enable/Set Flags
-------------------
 -g, --git          enable sync of skel's .git folder [default: none]
 -x, --exec         execute the sync [required] [default: none]

Other Options
-------------------
-d, --dryrun        execute without copying files to see what would be sent
-h, --help          display command usage and options

Script Usage
-------------------
$SCRIPTNAME [options]

Example (minimum): --exec
Example (short):   -u janedoe -f ~/etc/hostfile -g -x
Example (long):    --username janedoe --hostfile ~/etc/hostfile --git --exec
-----------------------------------------------------------------------------------

EOF
}


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
            -d|--dryrun) dryrun="yes" ;;
            -g|--git) git="yes" ;;
            -x|--exec) exec="yes" ;;
            ## long opts need additional shift
            -u|--username) username="$2" ; shift;;
            -f|--hostfile) hostfile="$2" ; shift ;;
            (--) shift; break;;
            (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
            (*) break;;
        esac
        shift
    done
fi

## Stop if --exec not set
if [ "$exec" != "yes" ]; then
    echo "[STOP] command option '--exec' not set"
    _self.help
    exit 1;
fi

## Enable/disable --dry-run rsync flag
if [ "$dryrun" = "yes" ]; then
    dry="--dry-run -v"
else
    dry=""
fi

## Enable/disable git exclude for rsync
if [ "$git" = "yes" ]; then
    gitsync=""
else
    gitsync="--exclude .git"
fi

## Execute sync
cat<<EOF
Default Settings
-------------------
username: $username
hostfile: $hostfile
skeldir:  $skeldir
dryrun:   $dryrun
git:      $git

EOF

[[ -d $skeldir ]] || (echo "skeldir not found: $skeldir" && exit 1;)

cdir=`pwd`
dest="/home/$username/Projects/skel"
#set -x
for host in `cat $hostfile`; do
    if [ "$git" = "yes" ]; then
	git=""
    fi

    if [ "$dryrun" = "yes" ]; then
	echo "[DRY-SYNC] '$username@$host' starting"
	cat<<EOF
ssh $username@$host "if [[ -r $dest ]]; then /bin/rm -rf $dest && mkdir -p $dest; else mkdir -p $dest; fi"
EOF
	rsync -az --links --safe-links --delete-before --delete-excluded $gitsync $dry $skeldir/* $username@$host:$dest/

	cat<<EOF
ssh $username@$host "cd $dest && ./action.install-to-local"
EOF
	echo "[DRY-SYNC] '$username@$host' complete"

    elif [ "$dryrun" = "no" ]; then
	echo "[SYNC] '$username@$host' starting"
	ssh $username@$host "if [[ -r $dest ]]; then /bin/rm -rf $dest && mkdir -p $dest; else mkdir -p $dest; fi"
	rsync -az --links --safe-links --delete-before --delete-excluded $gitsync $dry $skeldir/* $username@$host:$dest/
	ssh $username@$host "cd $dest && ./action.install-to-local"
	echo "[SYNC] '$username@$host' complete"
    else
	echo "internal error, exiting."
	exit 1;
    fi
done
cd $cdir
#set +x

echo "[COMPLETE]"
exit 0;
