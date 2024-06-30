#!/bin/bash
cur=`pwd`
cpu2017_dir=/home/cpu2017
cd $cpu2017_dir

#collect_base_info
{ echo;echo;echo;echo  && echo -e "\033[33m=======================CPU===========================\033[0m" && echo -n $(cat /proc/cpuinfo|grep "physical id"|sort|uniq|wc -l) && echo " *$(cat /proc/cpuinfo | grep "model name"|uniq|cut -f2 -d:)" && echo -e "\033[33m======================Memory========================\033[0m" && echo -n "$(dmidecode -t memory|grep Speed|grep "Configured"|grep -v Unkn|wc -l) * " && echo -n "$(dmidecode -t memory | grep -i "manu\|part" | grep -v "Unknown\|DIMM" | sort | uniq | awk -F : '{print $2}' | xargs)" && echo -n " `dmidecode -t memory | grep Size | grep -v Ins | grep -v "None\|Vola" | uniq |awk -F: '{print $2}' |xargs|sed s/[[:space:]]//g`";echo -n " `dmidecode -t memory |grep Rank|sort|grep -v Unk|uniq|awk '{print $NF}'`R";echo " $(dmidecode -t memory |grep Speed|grep -v "Unk\|Con"|uniq|awk -F" " '{print $2}')MT/s running on `dmidecode -t memory|grep Speed|grep Con |grep -v Un |uniq|awk -F' ' '{print $4}'`MT/s" && echo -e "\033[33m=====================Network=========================\033[0m" && for i in `lspci |grep net |awk 'i=!i' | awk '{print $1}'`;do echo -n "`lspci -s $i -v | grep node |awk -F 'NUMA' '{print $2}'| sed 's/^ *//' ` " &&   lspci |grep net |awk 'i=!i' | grep $i; done && for i in `ls /sys/class/net/ | grep en[pso]`; do echo -n "$i node" && echo -n "`cat /sys/class/net/$i/device/numa_node` " && echo -n "$(lscpu | grep "node`cat /sys/class/net/$i/device/numa_node`" | awk '{print $4}' )" && echo -n "   driver: `ethtool -i $i  | grep "^driver\|^version" | awk -F: '{print $2}' | xargs`" && echo "   FW: `ethtool -i $i | grep firm |awk -F' ' '{print $2" "$3" " $4}' `"; done && echo -e "\033[33m====================SAS/RAID/NVMe====================\033[0m" && for i in `lspci |grep "SAS" | awk '{print $1}'`;do echo -n "`lspci -s $i -v | grep node |awk -F 'NUMA' '{print $2}'| sed 's/^ *//' ` " && echo -n  "$(lspci |grep "SAS" | grep $i) " && dname=`lspci -s $i -v | grep modules | awk -F: '{print $2}'` && echo -e "  driver:$dname $(modinfo $dname | grep ^version | awk -F: '{print $2}'|sed 's/^ *//')" && unset dname; done ;for i in `nvme list 2>/dev/null|grep nvme|awk '{print $1}'|awk -F"/" '{print $3}'`;do echo -n "node `cat /sys/class/nvme/\`ls -l /sys/block/${i}|awk -F'/' '{print $(NF-1)}'\`/device/numa_node` " && nvme list 2>/dev/null|sed "/---/d"|sed "/Namesp/d"|awk '{print $1,$3,$2,$5,$9,$15}'|grep $i ; done && echo -e "\033[33m======================DISKS==========================\033[0m" && num=`lsblk -o model |sort | grep -vi model |uniq |sed /^[[:space:]]*$/d |wc -l`; for i in `seq 1 $num` ; do name=`lsblk -o model |sort | grep -vi model |uniq |sed /^[[:space:]]*$/d |sed -n "${i}p"` && echo -n "`lsblk -o model |sort | grep -vi model |sed /^[[:space:]]*$/d | grep "$name" | wc -l` * " && echo -n "$name" && echo -n " $(lsblk -o model,size | grep "$name" |uniq |awk -F"$name" '{print $2}')" && keyn=$name ; dev_n=`lsblk -o name,model | grep "$keyn"|awk '{print$1}'|xargs|awk '{print$1}'`;echo "  FW: `smartctl -i /dev/$dev_n  2> /dev/null|grep "^Firm"|awk -F: '{print $2}' | uniq | xargs`" ;done; unset num name keyn && echo -e "\033[33m======================CPU Freq===========================\033[0m" && turbostat -s Bzy_MHz -i0.5 -n1 -q|grep -v "MHz\|-"|awk 'NR>1 {a[int($1/50)]++} END{for(i in a) print i*50,a[i]}'|awk '{printf("%dMHz: ",$1)} {for(n=0;n<$2;n++) {printf("+")}} {print $2}'|sort -r; echo -e "\033[33m======================Baseinfo===========================\033[0m" && echo "Name: `ipmitool fru 2>/dev/null | grep "Name"|awk -F: '{print $2}'|sed 's/^ *//' |uniq`" ; echo "BIOS: `dmidecode -s bios-version`" ; echo "BMC:`ipmitool mc info 2>/dev/null| grep "Firmware Revision"|awk -F: '{print $2}'`  (IP: `ipmitool lan print 1  2>/dev/null| grep 'IP A'|tail -n1|awk '{print $4}'`)" ; echo "Board: `dmidecode -t 2 | grep 'Product\|Serial'| awk -F: '{print $2}'|xargs `";echo "Serial Number: `dmidecode -t 1 | grep Serial |awk -F' ' '{print $3}'`";echo "Clock Source: `cat /sys/devices/system/clocksource/clocksource0/current_clocksource`"; echo "OS: $(cat /etc/os-release|grep PRETTY_NAME|cut -f2 -d\") - $(cat /etc/redhat-release 2>/dev/null) - (IP: $(ip a|grep 'state UP' -A3|grep scope|awk '{print $2}'|cut -f1 -d '/'))"; echo "Kernel: `uname -r`";echo "glibc: `ldd --version|head -1|awk '{print $NF}'`" ; echo "compiler: `gcc --version|head -1 2>/dev/null` "; date; nkvers 2>/dev/null; java -version 2>&1 | grep -v "bash" |head -1; echo -e "\033[33m======================CmdLine===========================\033[0m" && cat /proc/cmdline; } > result/env.txt

#cat result/env.txt


#copy run shell scripts
cp *.sh result/


#change result dir to intrate fprate intspeed fpspeed
intrate_result_file=`ls result/ | grep intrate.refrate.txt | head -1`
fprate_result_file=`ls result/ | grep fprate.refrate.txt | head -1`
intspeed_result_file=`ls result/ | grep intspeed.refspeed.txt | head -1`
fpspeed_result_file=`ls result/ | grep fpspeed.refspeed.txt | head -1`

cd result
[[ $intrate_result_file ]] && intrate_res=`cat $intrate_result_file | grep 2017_int_base | awk '{print $3}'`
[[ $fprate_result_file ]] && fprate_res=`cat $fprate_result_file | grep 2017_fp_base | awk '{print $3}'`
[[ $intspeed_result_file ]] && intspeed_res=`cat $intspeed_result_file | grep 2017_int_base | awk '{print $3}'`
[[ $fpspeed_result_file  ]] && fpspeed_res=`cat $fp_speed_result_file | grep 2017_fp_base | awk '{print $3}'`
cd ..
res_name="$intrate_res $fprate_res $intspeed_res $fpspeed_res"
mv result "$res_name"

cd $cur
cp -r "$cpu2017_dir/$res_name" $cur
