#!/bin/bash
#size=14.6T
cur=`dirname $0`
source $cur/config.sh
path=$1


blks=`lsblk | grep $size | awk '{print $1}'`
mkdir -p $path/config
for i in $blks; do sed "s/sdb1/${i}1/g" $cur/tmp > $path/config/$i ; done

