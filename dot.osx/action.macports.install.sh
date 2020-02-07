#!/bin/bash
#------------------------------------------------------------------------------#
#-- Name     : action.macports.install.sh
#-- Purpose  : Installs/Manages macports apps
#-- Author   : EM Winterschon
#-- Repo     : https://github.com/em-winterschon/dotfiles
#-- Requires : macports
#------------:
#-- Date     : 2017-06-17
#-- Version  : 1.3
#------------------------------------------------------------------------------#

## Mark current directory
PWD=`pwd`

## Get sudo to start...
sudo -v

echo "================================================================================"
echo "    Administrative + cleanup actions"
echo "================================================================================"

## Freshen install option... this could break your shit... or clean it up!
echo -n "Remove all existing ports to start fresh? [y/N]: "; read CHOICE
if [ "${CHOICE}" = "y" ]; then
    echo " [action]: uninistalling all previously installed ports..."
    sudo port -fp uninstall installed
else
    ## clean up orphaned dependencies
    echo " [action]: cleaning up orphaned deps..."
    sudo port uninstall leaves
fi

echo "================================================================================"
echo "    Running selfupdate for MacPorts"
echo "================================================================================"
sudo port selfupdate

echo "================================================================================"
echo "    Upgrading outdated MacPorts applications (if exists)"
echo "================================================================================"
sudo port upgrade --enforce-variants outdated

echo "================================================================================"
echo "    Installing MacPorts applications"
echo "================================================================================"
cat osx.ports-list.txt | while read line; do
    sudo port -N install $line || exit 127;
done

## DEBUG BREAKPOINT 2017-06-17
#echo "----BREAKPOINT EXIT----"
#exit 0;

echo "================================================================================"
echo "    Setting up symlinks"
echo "================================================================================"
## SYM: sqlformat
echo " [action]: checking file existence for /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/sqlformat..."
if [ -f /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/sqlformat ]; then
    echo " [action]: symlink for sqlformat"
    if [ -h /usr/local/bin/sqlformat ]; then
	sudo rm /usr/local/bin/sqlformat
	sudo ln -s /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/sqlformat /usr/local/bin/sqlformat
    fi
else
    echo " [error]: macports version of sqlformat cannot be located as expected. exiting..."
    exit 1;
fi

## SYM: python
echo " [action]: checking file existence for /opt/local/bin/python..."
if [ -f /opt/local/bin/python2.7 ]; then
    echo " [action]: symlink for py -> python"
    if [ -h /opt/local/bin/py ]; then sudo rm /opt/local/bin/py; fi
    if [ -h /opt/local/bin/python ]; then sudo rm /opt/local/bin/python; fi
    sudo ln -s /opt/local/bin/python2.7 /opt/local/bin/python    
    sudo ln -s /opt/local/bin/python2.7 /opt/local/bin/py
else
    echo " [error]: macports version of python cannot be located as expected. exiting..."
    exit 1;
fi

## SYM: bash
echo " [action]: checking file existence for /opt/local/bin/bash..."
if [ -f /opt/local/bin/bash ]; then
    echo " [action]: symlink for /bin/bash"
    # /bin/bash is symlinked already, so remove it and make a new one
    if [ -h /bin/bash ]; then
	sudo rm /bin/bash
	sudo ln -s /opt/local/bin/bash /bin/bash
    else
	# symlink /bin/bash to /bin/bash-$version
	BASHVER=$(/bin/bash --version | head -n 1 | \
	    awk '{print $4}' | \
	    sed -e 's/-release//g' | \
	    sed -e 's/(//g' | \
	    sed -e 's/)//g')
	sudo mv /bin/bash /bin/bash-$BASHVER
	sudo ln -s /opt/local/bin/bash /bin/bash
    fi
else
    echo " [error]: macports version of bash cannot be located as expected. exiting..."
    exit 1;
fi

echo "================================================================================"
echo "    Setting up pips, gems, npms, go apps, shellcheck"
echo "================================================================================"
sudo -H pip3 install pinggraph
sudo gem install i2cssh
sudo npm install -g turbo-git
sudo go get -u github.com/gokcehan/lf

echo "setting up cabal for shellcheck"
cabal update
cabal install cabal-install
rm -rf $HOME/Projects/shellcheck
cd $HOME/Projects
echo "cloning shellcheck"
git clone https://github.com/koalaman/shellcheck.git
cd $HOME/Projects/shellcheck
echo "building shellcheck"
cabal install --force-reinstalls
cd $PWD

echo "================================================================================"
echo "    Setting up defaults"
echo "================================================================================"
sudo port select --set python python27
sudo port select --set python3 python36
sudo port select --set autopep8 autopep8-27
sudo port select --set pep8 pep8-27

echo "================================================================================"
echo "    COMPLETE"
echo "================================================================================"
exit 0;
