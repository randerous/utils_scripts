key=$1
cmd=$2
num=`ps aux | grep $key | wc -l`
while [[ $num != 3 ]]
do
	sleep 10s
	num=`ps aux | grep $key | wc -l`
done
$cmd
