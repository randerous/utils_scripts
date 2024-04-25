#!/bin/bash
cur=`dirname $0`
read -p "input hdd size: " size
#size=7.3T
blks=`lsblk | grep $size | awk '{print $1}'`
runtime=600
oldtime=`cat $cur/tmp | grep elapse | awk -F 'elapsed=' '{print $2}' | awk -F ',' '{print $1}'`
sed -i "s/elapsed=$oldtime/elapsed=$runtime/g" $cur/tmp

for i in $blks
do
	lsblk | grep ${i}1 &>/dev/null

	if [[ $? != 0 ]] 
	then
		echo $i 1
		parted -s /dev/$i mklabel gpt; 
		parted -s /dev/$i mkpart xfs 0% 4T
	fi
done
