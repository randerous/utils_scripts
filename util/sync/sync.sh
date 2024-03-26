#!/bin/bash
cur=`dirname $0`
source	$cur/../net/hostconfig
src=$1
target=$2
echo "cp $1 to $2"
for i in $hosts
do
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


