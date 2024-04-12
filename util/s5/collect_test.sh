#!/bin/bash
for i in `ls`; do str=`smartctl -a /dev/$i | grep -i serial | awk '{print $3}'`; echo -n "$i $str "; cat $i |  grep avg | awk '{print $2}'; done | sort -rhk 3
