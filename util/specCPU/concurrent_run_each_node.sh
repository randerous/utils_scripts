#!/bin/bash
export LANG="en_US.UTF-8"
config_name=$1
bench_select=$2
path=fast-test

[[ -d $path ]] && mv $path ${path}--$(date +%F)
mkdir -p $path

tmp=`lscpu | grep "NUMA node0 CPU(s)" | awk -F '-' '{print $2}' | awk -F ',' '{print $1}'`
copies=`expr $tmp \* 2 + 2`
#echo $copies

function set_env()
{
. ./shrc

# tuning for OS
ulimit -l 268435456
ulimit -s unlimited
ulimit -u unlimited
ulimit -n 32768
systemctl stop irqbalance
systemctl stop numad 2> /dev/null
echo 8 > /proc/sys/vm/dirty_ratio
echo 1 > /proc/sys/vm/swappiness
echo 1 > /proc/sys/vm/zone_reclaim_mode
echo 3 > /proc/sys/vm/drop_caches
echo 1 > /proc/sys/kernel/numa_balancing
echo 40 > /proc/sys/vm/dirty_background_ratio
echo 200 > /sys/kernel/mm/ksm/sleep_millisecs
echo 50000 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag

rm -rf benchspec/CPU/*/run/*

[[ -d result ]] && mv  result result-$(date +%F)
}

function geometric_mean() 
{
  local input_file="$1"
  echo $input_file
#  cat $input_file

  awk '
  BEGIN {
    product = 1
    count = 0
  }
  {
    product *= $1
    count += 1
  }
  END {
    if (count > 0) {
      print exp(log(product) / count)
    } else {
      print "Error: No numbers provided"
    }
  }' $path/"$input_file" | tee ${path}/${input_file}_avg
}

function bind_cpus()
{
	local bindnum=0
	local BIND=""
	local core_list=$1
	local start1=`echo $core_list | awk -F '-' '{print $1}'`
	local end1=`echo $core_list | awk -F '-' '{print $2}' | awk -F ',' '{print $1}'`
	local start2=`echo $core_list | awk -F '-' '{print $2}' | awk -F ',' '{print $2}'`
	local end2=`echo $core_list | awk -F '-' '{print $3}'`
	for i in `seq $start1 $end1`
	do
		let bindnum=$bindnum+1
		BIND=$BIND"\nbind$bindnum = numactl --localalloc --physcpubind=$i"
	done
	for i in `seq $start2 $end2`
        do
		let bindnum=$bindnum+1
                BIND=$BIND"\nbind$bindnum = numactl --localalloc --physcpubind=$i"
        done
	echo -e $BIND
}
function run()
{
	local node=$1
	local benchs=$2
	local cmd=""
	for bench in $benchs
	do
		local cpulist=`lscpu | grep node${node} | awk '{print $4}'`
		bench_cfg=${config_name}-${bench}.cfg

		rm -f config/$bench_cfg
		cp -f config/$config_name config/$bench_cfg

		echo "default:" >> config/$bench_cfg

		bind_cpus $cpulist >> config/$bench_cfg	
		echo "submit = echo \"\$command\" > run.sh ; \$BIND bash run.sh" >>  config/$bench_cfg

		local tmp_cmd=" numactl -N $node  -m $node runcpu --action run -C  $copies -c $bench_cfg --tune base --size ref  -n 1 -l -o all $bench"
		if [[ $cmd == ""  ]]
		then
			cmd=$tmp_cmd
		else
			cmd="$cmd && sleep 30s && $tmp_cmd "
		fi
	done
	echo ". ./shrc; $cmd &" > tmp_run.sh
	sh tmp_run.sh
	rm -f tmp_run.sh
}

function wait_finish()
{
	local bench_type=$1
	if [[ $bench_type == intrate ]] 
	then
		sum=10
	else
		sum=13
	fi

	while true
        do
                local num=`ls result | grep pdf | wc -l`
                if [[ $num == $sum ]]
                then
                        break;
                fi
                sleep 30s
        done

	mv  result $path/result-$bench_type
}


function run_intrate()
{
	local nodes=`lscpu |  grep "node(s)" | awk '{print $3}'`
	if [[ $nodes == 8 ]]
	then	
		run 0 500
		run 1 502
		run 2 505
		run 3 520
		run 4 541
		run 5 557
		run 6 "523 531"
		run 7 "525 548"
	elif [[ $nodes == 4 ]]
	then
		run 0 "500 541"
                run 1 "502 557"
                run 2 "505 523 531"
                run 3 "520 525 548"
	fi
	wait_finish intrate
}


function run_fprate()
{
	local nodes=`lscpu |  grep "node(s)" | awk '{print $3}'`
        if [[ $nodes == 8 ]]
        then
		run 0 503
		run 1 "507 508 511"
		run 2 "510"
		run 3 "519 526"
		run 4 "521 544"
		run 5 "527 538"
		run 6 "549"
		run 7 "554"
	elif [[ $nodes == 4 ]]
        then
		run 0 "503 521 544"
                run 1 "507 508 511 527 538"
                run 2 "510 549"
                run 3 "519 526 554"
	fi

	wait_finish fprate
}




#500 502 505 520 523 525 531 541 548 557 

#503 507 508 510 511 519 521 526 527 538 544 549 554

function collect_result
{
	dir=$path/result-$1
	for i in `ls $dir | grep txt `
	do
	        cat $dir/$i | grep Benchmarks -A 14 | grep -v Benchmarks | grep -v "-" | awk '$NF!="NR" {print $1}' | head -1 >> $path/$1-detail


		cat $dir/$i | grep 2017_int_base | awk '{print $3}' >> $path/intrate_score
		cat $dir/$i | grep 2017_int_base | awk '{print $3}' >> $path/$1-detail

		cat $dir/$i | grep 2017_fp_base | awk '{print $3}' >> $path/fprate_score
		cat $dir/$i | grep 2017_fp_base | awk '{print $3}' >> $path/$1-detail
	done
}

function main()
{
	set_env

	if [[ $bench_select == all ]]
	then
	        run_intrate
 	 	echo 3 > /proc/sys/vm/drop_caches
		sleep 30s
		run_fprate


		collect_result intrate
		collect_result fprate

		geometric_mean intrate_score
		geometric_mean fprate_score

	elif [[ $bench_select == intrate ]]
	then
		run_intrate
		collect_result intrate
                geometric_mean intrate_score
	elif [[ $bench_select == fprate ]]	
	then
		run_fprate
		collect_result fprate
                geometric_mean fprate_score
	fi
}
main
