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

count=1
for i in $disks
do
	echo $count: $i
	disks_array[$count]=$i
	let count+=1
done


for i in $disks
do
	echo $i
	echo "	mkfs.xfs -f -b size=65536 /dev/$i && parted -s /dev/$i mklabel gpt && 	parted -s /dev/$i mkpart xfs 0% 4T && 	mkfs.xfs -f -b size=65536 /dev/${i}1 &" | bash; 
done

