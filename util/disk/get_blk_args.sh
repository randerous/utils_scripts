#!/bin/bash
for i in `ls /sys/block/ |grep -v dm-`; do for j in `find /sys/block/$i/queue/ -maxdepth 2 -type f 2>/dev/null`; do echo -n "$j: " && cat $j 2> /dev/null ; done ; echo; echo ; done
