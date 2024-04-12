#!/bin/bash
cur=`dirname $0`
source $cur/../common/highlight.sh
function turn_off()
{
cd /sys/block
for i in `ls /sys/block/ | grep bcache`
do
	echo writeback > $i/bcache/cache_mode
	echo 40 > $i/bcache/writeback_percent
	echo 0 > $i/bcache/writeback_running
	echo 0 > $i/bcache/cache/congested_write_threshold_us
	echo 0 > $i/bcache/cache/congested_read_threshold_us
	echo 0 > $i/bcache/sequential_cutoff
	#cd $i;sh /root/util/common/ls.sh;cd ..
done
}

function turn_on()
{
cd /sys/block
for i in `ls /sys/block/ | grep bcache`
do
	echo 1 > $i/bcache/writeback_running
	echo 40 > $i/bcache/writeback_percent
done
}

if [[ $# == 0 ]]
then
	
	highlight turn_off
	turn_off
else
	highlight turn_on
	turn_on
fi
