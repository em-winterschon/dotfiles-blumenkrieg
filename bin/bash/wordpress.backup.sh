#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : wordpress.backup.sh
#-- Purpose  : Issues files+db backup for wordpress site
#-- Requires : mysql, tar, gzip
#------------------------------------------------------------------------------#
AUTHOR="Madeline Everett"
REPO="https://github.com/madeline-everett/misc-scripts.git"
DATE="2016-10-26"
VERSION="1.0"
#------------------------------------------------------------------------------#

##Prints our help info
function _self.help() {
    cat<<EOF
> wordpress.backup.sh
Author  : $AUTHOR
Repo    : $REPO
Version : $VERSION
Date    : $DATE

Usage: wordpress.backup.sh [options]

 -t, --target     TLDR of site to backup [default: none]
 -h, --help       print the help text [default: none]

--------------------------------------------------------------------------------

EOF
    return 1;
    }

## Get site from ARG1 or print help
if [ $# -eq 0 ]; then
    echo 'ERROR: missing site TLDR as ARG1.'
    _self.help;
else
    if [ $# -eq 1 ]; then
	if [ $1 = "-h" ]; then _self.help; return;
	elif [ $1 = "--help" ]; then _self.help; return;
	else
	    SITE=$1;
	fi
    fi
fi

## Dynamic Variables
DATE=`date +"%Y%m%d%H%M"`
DB_NAME=`grep DB_NAME $HOME/$SITE/wp-config.php | awk -F\' '{print $4}'`
DB_USER=`grep DB_USER $HOME/$SITE/wp-config.php | awk -F\' '{print $4}'`
DB_PASSWORD=`grep DB_PASSWORD $HOME/$SITE/wp-config.php | awk -F\' '{print $4}'`
DB_HOST=`grep DB_HOST $HOME/$SITE/wp-config.php | awk -F\' '{print $4}'`
DIR_SITE="$HOME/_backups/sites"
DIR_SCHEMA="$HOME/_backups/schema"
DB_FILE="$DIR_SCHEMA/db-$SITE-$DATE.sql"

## Commence backup process...
if [ ! -d $DIR_SITE ]; then 
    echo -n "INFO: site backup directory [$DIR_SITE] does not exist, creating... "
    mkdir -p $DIR_SITE || (echo "ERROR: failed to create directory. Exiting." && exit 1;)
    echo "[OK]"   
fi

if [ ! -d $DIR_SCHEMA ]; then 
    echo -n "INFO: schema backup directory [$DIR_SCHEMA] does not exist, creating... "
    mkdir -p $DIR_SCHEMA || (echo "ERROR: failed to create directory. Exiting." && exit 1;)
    echo "[OK]"   
fi

echo "Backing up $SITE:files"
tar czf $DIR_SITE/$SITE-$DATE.tgz $HOME/$SITE

echo "Backing up $SITE:schema"
mysqldump --opt --single-transaction \
    --host=$DB_HOST \
    --user=$DB_USER \
    --password="$DB_PASSWORD" \
    $DB_NAME > $DB_FILE

echo "Compressing $SITE:schema"
gzip $DB_FILE

echo "COMPLETE"

