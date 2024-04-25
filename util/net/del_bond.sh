#!/bin/bash
name=$1
for i in `ip a | grep master | grep $name | awk -F ':' '{print $2}'`
do
	nmcli con del bond-slave-$i
done

nmcli con del $name 
