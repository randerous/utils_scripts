#!/bin/bash
cd /usr/lib/systemd/system/
for i in `ls  /usr/lib/systemd/system/ | grep ceph `
do
	sed -i "s/StartLimitBurst=[0-9]*/StartLimitBurst=100/g" $i
done
systemctl daemon-reload