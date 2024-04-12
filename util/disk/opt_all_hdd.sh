#!/bin/bash
cur=`dirname $0`

size=14.6T
for i in `lsblk | grep $size | awk '{print $1}'`
do
	sh $cur/opt_hdd.sh $i
done	
