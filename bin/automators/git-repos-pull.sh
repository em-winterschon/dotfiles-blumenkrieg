#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : git-repos-pull.sh
#-- Purpose  : Pulls latest from my main git repos
#-- Author   : Madeline Everett
#-- Repo     : N/A
#-- Requires : git
#------------:
#-- Date     : 2017-04-05
#-- Version  : 1.0
#------------------------------------------------------------------------------#
C=$(pwd)

## Superbash
cd $HOME
cd Projects/superbash
git pull
./action.install-to-local

## Dotfiles
cd $HOME
cd Projects/dotfiles
git pull
./action.install-to-local

## osx.bootstrap
cd $HOME
cd Projects/osx.bootstrap
git pull

## Conclude
cd $C
