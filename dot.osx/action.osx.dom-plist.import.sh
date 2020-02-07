#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : action.osx.dom-plist.import.sh
#-- Purpose  : Imports plist backup file to domain
#-- Author   : EM Winterschon
#-- Repo     : Part of dotfiles: https://github.com/em-winterschon/dotfiles
#-- Requires : sudo
#------------:
#-- Date     : 2017-02-23
#-- Version  : 1.0
#------------------------------------------------------------------------------#

## Ask for the administrator password upfront
sudo -v

## Read args
if [ $# -eq 0 ]; then
    echo "Usage: action.osx.dom-plist.import.sh PLIST"
else 
    if [ $# -gt 1 ]; then
	echo "Usage: action.osx.dom-plist.import.sh PLIST"
    else 	
	PLIST=$1
	DOM=`echo $PLIST | sed 's/.plist//g'`
	sudo defaults import $DOM $PLIST
    fi
fi



