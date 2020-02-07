#!/bin/bash
INPUT=$1
OUTPUT="${INPUT}.utf8-ascii.txt"
/opt/local/bin/iconv -f utf-8 -t ascii//TRANSLIT < ${INPUT} > ${OUTPUT}

