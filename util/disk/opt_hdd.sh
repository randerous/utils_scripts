#tun for queue_depth
echo 32 > /sys/block/$1/device/queue_depth

#tune for queue
path=/sys/block/$1/queue
echo mq-deadline > $path/scheduler
echo 2048 > $path/nr_requests
echo 4096 > $path/iosched/fifo_batch
echo 500 > $path/iosched/read_expire
echo 5000 > $path/iosched/write_expire
echo 2 > $path/iosched/writes_starved

