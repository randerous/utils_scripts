#!/bin/bash
cur=`dirname $0`
#disable firewall, selinux
source $cur/../common/highlight.sh
ipname=`ip a | grep "inet" | grep dynamic | awk '{print $2}' | awk -F '/' '{print $1}'`

echo "init $ipname"
systemctl stop firewalld.service
systemctl disable firewalld.service

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#enable os interface
ifname=`ip a | grep "inet" | grep dynamic | awk '{print $NF}'`
sed -i "s/ONBOOT=no/ONBOOT=yes/g" /etc/sysconfig/network-scripts/ifcfg-$ifname
cat /etc/sysconfig/network-scripts/ifcfg-$ifname

#set hostname
function set_hostname()
{
source $cur/../net/hostconfig
num=1
for i in $hosts
do
	echo -e "$i \t ceph0$num" >> /etc/hosts
	let num=$num+1
done

name=`cat /etc/hosts | grep $ipname |head -1| awk '{print $2}'`
highlight $name
hostnamectl set-hostname $name
}

#set_hostname


rpm -e $(rpm -qa | grep bclinux-license)

sh $cur/../common/collect_base_info.sh

echo
echo
