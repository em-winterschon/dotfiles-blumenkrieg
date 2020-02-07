#!/bin/bash
#--------------------------------------------------------------------------------------------------#
#-- Name     : taper-schedule.sh
#-- Purpose  : Simplifies a dose tapering schedule 
#-- Author   : Cerulean Rabbit
#-- Repo     : N/A
#-- Requires : Bash
#------------:
#-- Date     : 2018-06-04
#-- Version  : 1.0
#--------------------------------------------------------------------------------------------------#

# Starting dosage values
STARTING_QUANT_PER_DAY=42
NUM_DOSES_PER_DAY=3

# Tapering values 
REDUCE=2 #in grams
DAYS_TO_TAPER=7

# Do not edit below here
PER_DOSE=`awk "BEGIN {print (${STARTING_QUANT_PER_DAY} / ${NUM_DOSES_PER_DAY})}"`
function round() {
    printf "%.$2f" "$1"
}

ITER=0
while [ $ITER -lt $DAYS_TO_TAPER ]; do
    DOSE_REDUCTION=`awk "BEGIN {print (${REDUCE} / ${NUM_DOSES_PER_DAY})}"`
    NEW_DOSE=`awk "BEGIN {print (${PER_DOSE} - ${DOSE_REDUCTION})}"`
    PER_DOSE=`round $NEW_DOSE 1`
    DAYNUM=`expr ${ITER} + 1`
    DAY_TOTAL=`awk "BEGIN {print (${PER_DOSE} * ${NUM_DOSES_PER_DAY})}"`
    echo "[DAY ${DAYNUM}] Today's dose schedule is: ${PER_DOSE}g, ${NUM_DOSES_PER_DAY}x per day (total ${DAY_TOTAL}g)"
    let ITER=ITER+1 
done



