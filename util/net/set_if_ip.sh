ifname=$1
ip=$2
nmcli con del $ifname
nmcli con add con-name $ifname ifname $ifname type ethernet ipv4.method manual ipv4.address $ip
ifup $ifname
