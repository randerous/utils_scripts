key=$1
for i in `ls`; 
do
	echo -e "\033[40;33m${i}  \033[0m";
	if [[ ! ${key} ]]
	then
		cat $i;
	else
		cat $i | grep ${key}
	fi
done
