#!/bin/bash
#
#  Lossage.sh
#  Generate graph representing packet loss versus time for a specified site.
#  Requires GNU ping and GNU cut.
#
#  DWF  6/6/95
#  11/14/95  Added another space in header to correct alignment problem.
#
#  Usage:  ./lossage.sh sitename
#
echo "                            Dead                                    Alive"
echo "Time                          |   1   2   3   4   5   6   7   8   9   |"
while /usr/bin/true; do
  LOSSAGE=`ping -qc 40 $1 | fgrep "packet loss" | cut -d , -f 2 | cut -d ' ' -f 2`
  echo -n `date` '  '
  while [ ${LOSSAGE} -gt 0 ]; do
    echo -n "#"
    LOSSAGE=$[LOSSAGE-1]
  done
  echo ''
  sleep 60
done
