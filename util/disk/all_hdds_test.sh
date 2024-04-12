#!/bin/bash
lsblk

runtime=3600
#read -p "HDD size keyword(like 7.3): " hdd_size
hdd_size=10.9
sys_disk=`lsblk | grep boot -B 1 | grep disk |awk '{print $1}'`
echo "system disk: ${sys_disk}"
hdd=`lsblk | grep $hdd_size -i |grep disk|grep -v bcache| awk '{print $1}'  | xargs `
hdds=${hdd//$sys_disk/}
num_hdds=`echo $hdds | wc -w`
echo "hdds: $hdds    total_number: $num_hdds"
#read -p "Is that right? (y/n) " ans
#[[ $ans != y ]] && exit
echo "running disk-precheck background......"
mkdir ./result

############随机读测试#######
echo "4k Random Read Test"
for disk in $hdds
do
        echo $disk
#	fio --ioengine=libaio --randrepeat=0 --norandommap --thread --direct=1 --group_reporting --name=mytest --ramp_time=60 --runtime=100 --time_based --numjobs=1 --iodepth=32 --filename=/dev/$disk --rw=randread --bs=4k >> ./result/4K_randread_result_$disk &
done
#sleep 180
############随机写测试#######
echo "4k Random Write Test"
for disk in $hdds
do
        echo $disk
#	fio --ioengine=libaio --randrepeat=0 --norandommap --thread --direct=1 --group_reporting --name=mytest --ramp_time=60 --runtime=100 --time_based --numjobs=1 --iodepth=32 --filename=/dev/$disk --rw=randwrite --bs=4k >> ./result/4K_randwrite_result_$disk &
done
#sleep 180



####顺序读测试########
echo "256k Seq Read Test"
for disk in $hdds
do
	fio --ioengine=libaio --randrepeat=0 --norandommap --thread --direct=1 --group_reporting --name=mytest --ramp_time=60 --runtime=$runtime --time_based --numjobs=64 --iodepth=32 --filename=/dev/$disk --rw=read --bs=256k >> ./result/256K_read_result_$disk &
done
sleep $[runtime + 80]

####顺序写测试########
echo "256k Seq Write Test"
for disk in $hdds
do
       fio --ioengine=libaio --randrepeat=0 --norandommap --thread --direct=1 --group_reporting --name=mytest --ramp_time=60 --runtime=$runtime --time_based --numjobs=64 --iodepth=32 --filename=/dev/$disk --rw=write --bs=256k >> ./result/256K_write_result_$disk &
done
sleep $[runtime + 80]

#######结果统计###############
echo "***************256k write result**********************" >> ./result/allresult
for disk in $hdds
do
        echo "$disk 256k write:" >> ./result/allresult
        cat ./result/256K_write_result_$disk | grep BW= >> ./result/allresult
done

echo "***************256k write result**********************" >> ./result/allresult
for disk in $hdds
do
        echo "$disk 256k write:" >> ./result/allresult
        cat ./result/256K_write_result_$disk | grep BW= >> ./result/allresult
done

echo "***************randwrite IOPS result**********************" >> ./result/allresult
for disk in $hdds
do
	echo "$disk 4k randwrite:" >> ./result/allresult
	cat ./result/4K_randwrite_result_$disk | grep BW= >> ./result/allresult
done

echo "***************randread IOPS result**********************" >> ./result/allresult
for disk in $hdds
do
	echo "$disk 4k randread:" >> ./result/allresult
	cat ./result/4K_randread_result_$disk | grep BW= >> ./result/allresult
done

cat ./result/allresult
