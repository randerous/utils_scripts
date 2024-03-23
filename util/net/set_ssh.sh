#!/bin/bash
source ./hostconfig

echo "y"  | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
for h in $hosts
do
	expect -c "
		spawn ssh-copy-id $h
		expect {
	       		\"print\]\)\?\" {
				send \"yes\r\"
				expect \"password:\"
				send \"$password\r\"
			}
			\"password:\" {
				send \"$password\r\"
			}
		}
		expect eof
	"
done


