#!/bin/bash
dev=$1
time=$2
path=$dev-result

mkdir -p $path
cd $path

blktrace -w $2 -d /dev/$dev 

blkparse -i $dev -d blkparse.out &>/dev/null

btt -i blkparse.out >  result.out 2>/dev/null

head -47 result.out


