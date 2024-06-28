#!/bin/sh

source /opt/setenv_open64.sh

export LIBRARY_PATH=`pwd`:$LIBRARY_PATH
export LD_LIBRARY_PATH=`pwd`:$LD_LIBRARY_PATH

opencc stream.c -fopenmp -O3 -DSTREAM_ARRAY_SIZE=270000000 -DNTIMES=30 -o stream-open64

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag


#count threads
lscpu -e > cpuinfo
i=0
while true
do

        core_add=`cat cpuinfo | grep -e ".*:.*:.*:$i " | head -1 | awk '{print $1}'`
        if [[ ! $core_add ]]
        then
                break
        fi
        cpulist="$cpulist $core_add $[core_add + 1]"
        let i=$i+1
done
rm -f cpuinfo &>/dev/null

omp_threads=`echo $cpulist | xargs | wc -w`

echo export OMP_NUM_THREADS=$omp_threads
echo export O64_OMP_AFFINITY_MAP=$cpulist



echo

export OMP_NUM_THREADS=$omp_threads
export O64_OMP_AFFINITY_MAP=$cpulist

./stream-open64
