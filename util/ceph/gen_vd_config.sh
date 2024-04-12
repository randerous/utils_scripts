
begin=$1
end=$2

rdpct=$3
seekpct=$4
size=$5

cat << EOF > tmp
hd=default,vdbench=/home/vdbench50406,user=root,shell=ssh
hd=hd1,system=node01
hd=hd2,system=node02
hd=hd3,system=node03
hd=hd4,system=node04

sd=default,openflags=o_direct,thread=2048,range=($begin,$end)
 
sd=sd01,host=hd1,lun=/dev/rbd0
sd=sd02,host=hd1,lun=/dev/rbd1
sd=sd03,host=hd1,lun=/dev/rbd2
sd=sd04,host=hd1,lun=/dev/rbd3
sd=sd05,host=hd1,lun=/dev/rbd4
sd=sd06,host=hd1,lun=/dev/rbd5

sd=sd11,host=hd2,lun=/dev/rbd0
sd=sd12,host=hd2,lun=/dev/rbd1
sd=sd13,host=hd2,lun=/dev/rbd2
sd=sd14,host=hd2,lun=/dev/rbd3
sd=sd15,host=hd2,lun=/dev/rbd4
sd=sd16,host=hd2,lun=/dev/rbd5


sd=sd21,host=hd3,lun=/dev/rbd0
sd=sd22,host=hd3,lun=/dev/rbd1
sd=sd23,host=hd3,lun=/dev/rbd2
sd=sd24,host=hd3,lun=/dev/rbd3
sd=sd25,host=hd3,lun=/dev/rbd4
sd=sd26,host=hd3,lun=/dev/rbd5


sd=sd31,host=hd4,lun=/dev/rbd0
sd=sd32,host=hd4,lun=/dev/rbd1
sd=sd33,host=hd4,lun=/dev/rbd2
sd=sd34,host=hd4,lun=/dev/rbd3
sd=sd35,host=hd4,lun=/dev/rbd4
sd=sd36,host=hd4,lun=/dev/rbd5

wd=wd1,sd=sd*,rdpct=$rdpct,seekpct=$seekpct,xfersize=$size

rd=rd1,wd=wd1,iorate=max,elapsed=604800,interval=5,warmup=30
EOF
