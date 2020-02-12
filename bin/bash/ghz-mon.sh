#!/bin/bash
## Outputs the average clock speed of all active CPU cores

cores=`sudo cpupower monitor | awk '{print $13}' | awk -F\| '{print $1}' | tail -n +3`
counter=0
numcore=0
for core in $cores; do
    let counter=$counter+$core
    let numcore=$numcore+1
done
#echo "total: $counter"
avg=`expr $counter / $numcore`
ghz=`expr $avg / 1000`

#echo "avg: $avg, $ghz"
printf "%.2f GHz\n" $(bc <<< "scale = 2; $avg / 1000")
