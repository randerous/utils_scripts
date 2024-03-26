#!/bin/bash
cur=`dirname $0`

source $cur/../net/hostconfig
for i in $hosts
do
	ssh $i < $cur/init.sh
done
