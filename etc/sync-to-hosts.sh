#!/bin/bash

username="$USER"
hostfile="~/etc/hosts.sync"
help="no"
skip="no"
emacs="no"
dryrun="no"

syncfiles=".bashrc .bash_linux .bash_grc .gitconfig .grc .tmux .tmux.conf .screenrc"

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
 -e, --emacs        sync .emacs.simple + .emacs.d-simple to dest: .emacs + .emacs.d [default: none]
 -x, --exec         execute the sync [required] [default: none]

Other Options
-------------------
-d, --dryrun        execute without copying files to see what would be sent
-h, --help          display command usage and options

Script Usage
-------------------
$SCRIPTNAME [options]

Example (minimum): --exec
Example (short):   -u janedoe -f ~/etc/hostfile -e -x
Example (long):    --username janedoe --hostfile ~/etc/hostfile --emacs --exec
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
            -e|--emacs) emacs="yes" ;;
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
fi

## Enable/disable dryrun
dry=""
if [ "$dryrun" = "yes" ]; then
    dry="--dry-run -v"
fi

## Execute sync
cat<<EOF
Default Settings
-------------------
username: $username
hostfile: $hostfile
emacs:    $emacs
dryrun:   $dryrun

EOF

cdir=`pwd`
for host in `cat $hostfile`; do
    echo "[SYNC] '$username@$host' starting"
    cd ~/

    # iterative sync for file list items
    for f in $syncfiles; do
	rsync -a --copy-links --copy-dirlinks $dry $f $username@$host:.
    done

    # destroy destination .emacs and .emacs.d to ensure clean sync
    if [ "$dry" = "" ]; then
	if [ "$emacs" = "yes" ]; then
	    echo "[EMACS] cleaning existing config + dir"
	    ssh $username@$host "/bin/rm -f .emacs && /bin/rm -rf .emacs.d"
	fi
    fi

    # initiate emacs sync for simple config
    if [ "$emacs" = "yes" ]; then
	echo "[EMACS] syncing updated emacs config files"
	rsync -a --copy-links --copy-dirlinks $dry .emacs.simple $username@$host:.emacs
	rsync -a --copy-links --copy-dirlinks $dry .emacs.d-simple $username@$host:
	ssh $username@$host "mv .emacs.d-simple .emacs.d"
    fi

    echo "[SYNC] '$username@$host' complete"
done
cd $cdir

echo "[COMPLETE]"
exit 0;
