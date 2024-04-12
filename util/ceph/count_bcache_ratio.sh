#!/bin/bash
cur=`dirname $0`
source $cur/../net/hostconfig
source $cur/../common/highlight.sh
function  count()
{
for i in $hosts
do
	echo -n "$i " | tee -a result
	ssh $i "cat /sys/block/bcache?/bcache/cache/stats_five_minute/cache_hit_ratio | awk 'BEGIN {sum=0} {sum+=\$1} END {print sum}'" | tee -a result
done
}

while true
do
	clear
	count
	sleep 30s
done
