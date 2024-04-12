echo mq-deadline > /sys/block/$1/queue/scheduler
#echo none > /sys/block/$1/queue/scheduler
echo 2048 > /sys/block/$1/queue/nr_requests
echo 4096 > /sys/block/$1/queue/iosched/fifo_batch

