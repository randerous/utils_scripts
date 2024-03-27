#!/bin/bash
cur=`dirname $0`
echo $0
sh $cur/../net/set_ssh.sh
sh $cur/../sync/sync.sh

source $cur/../net/hostconfig
for i in $hosts
do
	ssh $i "sh /root/util/init/init.sh"
done
