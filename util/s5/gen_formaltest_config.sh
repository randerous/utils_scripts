#!/bin/bash
cur=`dirname $0`
configname=formaltest-config
source $cur/config.sh
source $cur/../common/highlight.sh

read -p "input runtime: " runtime
[[ $runtime == "" ]] && runtime=3600
read -p "input data size: " datasize
[[ $datasize == "" ]] && datasize=18T

highlight "your config: configname=$configname, runtime=$runtime, datasize=$datasize"
echo -e "testblks:\n$blks"

cat << EOF > $configname
hd=default,vdbench=/home/vdbench50406,shell=ssh,user=root
sd=default,threads=2048,openflags=o_direct
EOF

num=1
for i in $blks
do
	echo "sd=sd$num,lun=/dev/${i}1" >> $configname
	num=$[ num + 1 ]
done



cat << EOF >> $configname
wd=wd1,sd=sd*,xfersize=1M,rdpct=70,seekpct=100
rd=run1,wd=wd1,iorate=max,maxdata=$datasize,elapsed=$runtime,interval=1,warmup=60
EOF



