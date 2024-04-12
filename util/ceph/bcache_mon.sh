#!/bin/bash
cur=`dirname $0`
source $cur/../common/highlight.sh

function find_bcache_by_id()
{
	#highlight $1
	for name in `ls /sys/block | grep bcache`
	do
		ls -l /sys/block/$name/bcache/cache | grep $1 &> /dev/null
		if [[ $? == 0 ]]
		then
			name=$name
			break
		fi
	done

}

for j in `ls /sys/fs/bcache | grep -v register`
do
	find_bcache_by_id $j
	
	highlight $name

	echo bset_tree_stats:
	cat /sys/fs/bcache/$j/internal/bset_tree_stats

	for i in btree_cache_max_chain btree_nodes btree_read_average_frequency_ms btree_sort_average_frequency_ms btree_split_average_frequency_sec btree_used_percent  writeback_keys_done writeback_keys_failed ; 
	do
       		echo -n "$i : " && cat /sys/fs/bcache/$j/internal/$i && echo ;
	done
done
