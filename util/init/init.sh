#!/bin/bash

#disable firewall, selinux
systemctl stop firewalld.service
systemctl disable firewalld.service

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config


sh ../common/collect_base_info.sh


