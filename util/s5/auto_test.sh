#!/bin/bash

cur=`dirname $0`
path=s5-test

source $cur/../common/highlight.sh
source $cur/config.sh

mkdir -p $path

sh $cur/../disk/opt_all_hdd.sh

sh $cur/gen_config.sh $path

echo $size $blks $path

function test_all()
{
mkdir -p $path/result

for i in $blks
do
	highlight "test $i"
	/home/vdbench50406/vdbench -f $path/config/$i > $path/result/$i 
	sleep 30s
done
}

#test_all

