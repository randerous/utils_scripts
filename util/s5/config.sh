#!/bin/bash
cur=`dirname $0`
size=14.6T
blks=`lsblk | grep $size | awk '{print $1}'`
runtime=600
oldtime=`cat $cur/tmp | grep elapse | awk -F 'elapsed=' '{print $2}' | awk -F ',' '{print $1}'`
sed -i "s/elapsed=$oldtime/elapsed=$runtime/g" $cur/tmp
