#!/bin/bash
lsblk
read -p "disk size keyword(like 894G): " disk_size
sys_disk=`lsblk | grep boot -B 1 | grep disk |awk '{print $1}'`
echo "system disk: ${sys_disk}"
disk=`lsblk | grep $disk_size -i |grep disk |grep -v bcache | awk '{print $1}' | xargs `
disks=$disk
num_disks=`echo $disks | wc -w`
echo "disks: $disks    total_number: $num_disks"
read -p "Is that right? (y/n) " ans
[[ $ans != y ]] && exit

read -p "subnet1 (without prefix): " subnet1
[[ $subnet1 == "" ]] && subnet1=11.11.11.11
read -p "subnet2 (without prefix): " subnet2
[[ $subnet2 == "" ]] && subnet2=12.12.12.11

read -p "iqn for subnet1: " iqn1
[[ $iqn1 == "" ]] && iqn1=iqn.2023-07.org.openanolis:406116b7cb
read -p "iqn for subnet2: " iqn2
[[ $iqn2 == "" ]] && iqn2=iqn.2023-07.org.openanolis:2bd6ef76aa8


count=1
for i in $disks
do
	echo $count: $i
	disks_array[$count]=$i
	let count+=1
done

function build()
{
half=$[ num_disks / 2 ]
for i in `seq 1 1 $num_disks`
do
	targetcli /backstores/block create disk${disks_array[$i]}  /dev/${disks_array[$i]}1
	targetcli /iscsi create iqn.2023-07.iscsi.test$i:client
	targetcli /iscsi/iqn.2023-07.iscsi.test$i:client/tpg1/luns/ create /backstores/block/disk${disks_array[$i]}
	targetcli /iscsi/iqn.2023-07.iscsi.test$i:client/tpg1/portals/ delete 0.0.0.0 3260
	if [[ $i -le $half ]] 
	then
		targetcli /iscsi/iqn.2023-07.iscsi.test$i:client/tpg1/portals create $subnet1
		targetcli /iscsi/iqn.2023-07.iscsi.test$i:client/tpg1/acls/ create $iqn1
	else
		targetcli /iscsi/iqn.2023-07.iscsi.test$i:client/tpg1/portals create $subnet2
		targetcli /iscsi/iqn.2023-07.iscsi.test$i:client/tpg1/acls/ create $iqn2
	fi
done
}

build

echo "for subnet=$subnet1: iqn=$iqn1"
echo "for subnet=$subnet2: iqn=$iqn2"
echo -e "after modification of /etc/iscsi/initiatorname.iscsi,\n you should restart iscsid with \"systemctl restart iscsid\" \n and rerun discovery : iscsiadm -m discovery -t sendtargets -p ip"
