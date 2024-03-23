key=$1
ps aux | grep $key | awk '{print $2}' | xargs kill -9
