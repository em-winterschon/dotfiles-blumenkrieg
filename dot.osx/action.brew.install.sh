#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : action.brew.install.sh
#-- Purpose  : installs Brew and packages
#-- Author   : EM Winterschon
#-- Repo     : git@bitbucket.org:em-winterschon/dotfiles.git
#-- Requires : Bash
#------------:
#-- Date     : 2019-05-27
#-- Version  : 1.0
#------------------------------------------------------------------------------#

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

if [ $? -eq 0 ]; then
    brew install grv
fi
