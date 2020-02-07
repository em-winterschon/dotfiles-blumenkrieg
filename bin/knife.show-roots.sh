#!/usr/bin/env bash
clear
echo "------------------------"
echo "Knife blocking 'fastly'"
knife block fastly > /dev/null
echo "------------------------"
echo "Showing new root"
knife vault show rootpw fastly

echo -e "\nShowing old root"
knife vault show vault fastly

## waiting for access
#echo -e "\nShowing IPMI login"
#knife vault show ipmi fastly

####
echo;
echo "------------------------"
echo "Knife blocking 'cdn_fastly'"
knife block cdn_fastly > /dev/null
echo "------------------------"
## waiting for access
#echo "Showing root"
#knife vault show rootpw fastly

echo "Showing IPMI login"
knife vault show ipmi fastly

####
echo;
echo "------------------------"
echo "Knife blocking 'cdn_lab'"
knife block cdn_lab > /dev/null
echo "------------------------"
echo "Showing lab root"
knife vault show rootpw fastly

echo -e "\nShowing IPMI login"
knife vault show ipmi fastly

