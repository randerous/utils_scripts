#!/bin/bash
size=3.6T
path=`lsblk | grep $size | awk '{print $1}'`
num=`lsblk | grep $size | wc -l`
ip_1=11.11.11.11
ip_2=12.12.12.11

echo disknums: $num
function change_iscsi()
{
	local name=$1
	local val=$2
	name=`hostname`
	if [[ $name == node01 ]]
	then
		for i in `seq 1 $num`
		do
			iscsiadm -m node -T iqn.2023-07.iscsi.test$i:client -p $ip_1 --op update -n $name -v $val
		done
	fi

	if [[ $name == node02 ]]
        then
		end=$[ num * 2 ]
		num=$[ num + 1 ]
		echo $end $num
                for i in `seq $num $end`
                do
                        iscsiadm -m node -T iqn.2023-07.iscsi.test$i:client -p $ip_2 --op update -n $name -v $val
                done
        fi

}

function set_scsi()
{
	maxNetSize=1073741824
	maxLength=262144
	maxCons=2048
	change_iscsi node.conn[0].iscsi.MaxXmitDataSegmentLength $maxLength
	change_iscsi node.conn[0].iscsi.MaxRecvDataSegmentLength $maxLength
	change_iscsi node.conn[0].tcp.window_size $maxNetSize
	change_iscsi node.session.iscsi.MaxBurstLength $maxLength
	change_iscsi node.session.queue_depth $maxCons
	change_iscsi node.session.cmds_max $maxCons
	change_iscsi node.session.iscsi.FirstBurstLength $maxLength
	change_iscsi node.session.iscsi.MaxConnections $maxCons
}

function set_net()
{
	ifconfig bond1 mtu 9000
	ifconfig bond2 mtu 9000
#	for ifname in `ip a | grep bond | grep master | awk -F ":" '{print $2}'`
#	do
#		echo $ifname
#		ethtool -g $ifname
#		val=`ethtool -g $ifname | grep -A 1 max | grep -v max | awk '{print $2}'`
#		ethtool -G $ifname rx $val tx $val 
#		ethtool -g $ifname
#	done
}

#set_scsi
set_net

