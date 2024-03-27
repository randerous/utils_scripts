#!/bin/bash
cur=`dirname $0`
source	$cur/../net/hostconfig
src=$1
target=$2
ipname=`ip a | grep "inet" | grep dynamic | awk '{print $2}' | awk -F '/' '{print $1}'`

echo "cp $1 to $2"
for i in $hosts
do
	if [[ $i == $ipname ]]
	then
		continue
	fi

	if [[  -z $src ]]
	then
		scp -r $cur/../../util $i:/root
	elif [[ -z $target ]]
	then
		scp -r $src $i:/root
	else
		scp -r $src $i:$target
	fi

done


