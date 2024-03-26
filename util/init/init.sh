#!/bin/bash
#cur=`dirname $0`
#disable firewall, selinux
systemctl stop firewalld.service
systemctl disable firewalld.service

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#enable os interface
ifname=`ip a | grep "inet" | grep dynamic | awk '{print $NF}'`
sed -i "s/ONBOOT=no/ONBOOT=yes/g" /etc/sysconfig/network-scripts/ifcfg-$ifname
cat /etc/sysconfig/network-scripts/ifcfg-$ifname
#sh $cur/../common/collect_base_info.sh


