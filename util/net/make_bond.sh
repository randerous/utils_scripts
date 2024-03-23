#!/bin/bash
cur_bond_num=`ip a |awk '{print $2}'| grep bond | wc -l`
ifname1=$1
ifname2=$2
mode=$3
ip_addr=$4
bond_name=bond`expr $cur_bond_num + 1`
echo $bond_name
if [[ $mode == 4 ]]
then
	nmcli con add con-name $bond_name ifname $bond_name type bond mode 4 bond.options "mode=4,miimon=100,xmit_hash_policy=layer3+4" ipv4.method manual ipv4.address $ip_addr
else
	nmcli con add con-name $bond_name ifname $bond_name type bond mode 0 ipv4.method manual ipv4.address $ip_addr
fi

nmcli con add type bond-slave ifname $ifname1 master $bond_name
nmcli con add type bond-slave ifname $ifname2 master $bond_name

