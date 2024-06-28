#!/bin/bash
cur=`dirname $0`
read -p "Hdd size:" size
#size=7.3T
for i in `lsblk | grep $size | awk '{print $1}'`
do
	sh $cur/restore_hdd.sh $i
done	
