#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : action.osx.dom-plist.sh
#-- Purpose  : Exports all application and system prefs to plist files
#-- Author   : EM Winterschon
#-- Repo     : Part of dotfiles: https://github.com/em-winterschon/dotfiles
#-- Requires : sudo
#------------:
#-- Date     : 2017-02-22
#-- Version  : 1.0
#------------------------------------------------------------------------------#

## Ask for the administrator password upfront
sudo -v

## Defaults
DATE=`date +"%Y%m%d"`
PWD=`pwd`
DIR="$HOME/Projects/dotfiles/dot.osx/_domains/$HOSTNAME/$DATE"
TMPDIR="$DIR/.tmp"
mkdir -p $DIR 2>&1
mkdir -p $TMPDIR 2>&1

## Iterate all non-global domains
for dom in `defaults domains`; do
    DOM=`echo $dom | awk -F, '{print $1}'`
    TMPFILE="$TMPDIR/$DOM.plist.tmp"
    PLIST="$DIR/$DOM.plist"
    echo " [ACTION] [DOMAIN][$DOM]"
    sudo defaults export $DOM - > $TMPFILE
    find $TMPFILE -size +181c | egrep '.*' > /dev/null
    if [ $? -ne 0 ]; then
	echo "   [SKIP] - defaults"
	rm -f $TMPFILE 2>&1
    else
	echo "   [SAVE] - customized"
	mv $TMPFILE $PLIST 2>&1
    fi
    echo ;
done

## Global domain
echo " [ACTION] [DOMAIN][NSGlobalDomain]"
sudo defaults export NSGlobalDomain - > $DIR/NSGlobalDomain.plist

## Finishing up
echo ;
echo " [ACTION] removed temp directory: [$TMPDIR]"
echo " [FINISH] DOM files located in directory: [$DIR]"
rm -rf $TMPDIR
echo " -- Complete --"
echo ;
exit 0;


