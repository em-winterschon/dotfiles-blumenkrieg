#!/usr/bin/env bash
clear
echo "Knife blocking 'fastly'"
knife block fastly > /dev/null
echo "------------------------"
echo -e "\nShowing Bootly"
knife vault show vault bootly
