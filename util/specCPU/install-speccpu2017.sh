#! /bin/bash

speccpu_iso_name=`find .. -name "cpu2017-1.*.iso"|head -1`
#cc_name=aocc-compiler-3.1.0.tar
#libs_name=libs-speccpu2017.tar.gz
#opt_pkg_name=hygon-speccpu2017-aocc3.1.0-20231128.tar.gz
cc_name=`ls | grep aocc-compiler`
libs_name=`ls | grep libs`
opt_pkg_name=`ls | grep speccpu2017 | grep gz`


cc_dir_name=${cc_name/.tar.gz/}

[[ -z $speccpu_iso_name ]] && echo "No SPEC CPU 2017 ISO file in current directory or parent directory. Stopped." && exit
echo "Found $speccpu_iso_name, using it."

[[ ! -f $cc_name ]] && echo "No file $cc_name in current directory. Stopped." && exit
[[ ! -f $libs_name ]] && echo "No file $libs_name in current directory. Stopped." && exit
[[ ! -f $opt_pkg_name ]] && echo "No file $opt_pkg_name in current directory. Stopped." && exit

echo "Please make sure that you have already installed all the dependences."

read -p "Mount $speccpu_iso_name to(like /mnt): " cpu2017_mnt_dir
until [[ -d $cpu2017_mnt_dir ]]
do
	read -p "No such directory. Please input again: " cpu2017_mnt_dir
done
mountpoint $cpu2017_mnt_dir &> /dev/null
[[ $? -eq 0 ]] && echo "$cpu2017_mnt_dir is already mounted, please check and try again." && exit


read -p "The directory you want to install SPEC CPU 2017(like /home/cpu2017): " cpu2017_dir

get_space_available()
{
############get test path###############
if [ -z $1 ];then
	read -p "input the path(e.g: /root):" path
else
	path=$1
fi

if [ "${path:0:1}" = "/" ];then
	if [ ! -d ${path} ];then
		# echo "create new path:${path}"
		mkdir -p ${path}
	fi
	# echo "absolute directory:${path}"
else
	pwd=`pwd`
	if [ ! -d "${pwd}/${path}" ];then
		# echo "create new path:${pwd}/${path}"
		mkdir -p ${pwd}/${path}
	fi
	path=${pwd}/${path}
	# echo "path:${path}"
fi

##########get data from df -h#############

rm -f /tmp/tmp_path_avail
rm -f /tmp/tmp_path_dir

df -h | while read line
do
	#for var in $line
	line_path=`echo ${line} | awk -F' ' '{print $6}'`
	line_avail=`echo ${line} | awk -F' ' '{print $4}'`
	if [ "${line_path:0:1}" != "/" ]; then
		continue
	fi

	if [ "${line_path}" = "/" ]; then
		root_avail=${line_avail}
		#echo "root_avail:${root_avail}"
		if [ -f /tmp/tmp_root_avail ];then
			rm /tmp/tmp_root_avail
		fi
    echo ${root_avail} > /tmp/tmp_root_avail
    continue
	fi

  path_length=${#line_path}
  if [ "${path:0:${path_length}}" = "${line_path}" ];then
    # echo "${path} contain path:${line_path}"
    path_avail=${line_avail}
    echo ${path_avail} >> /tmp/tmp_path_avail
	echo ${line_path} >> /tmp/tmp_path_dir
  fi
done



#############get data from temp file###############
if [ -f /tmp/tmp_path_avail ];then
	max_match_row_num=`awk 'BEGIN{x=0;y=0} {if(length > x) {x=length;y=NR}} END{print y}' /tmp/tmp_path_dir`
	path_avail=`sed -n "${max_match_row_num}p" /tmp/tmp_path_avail`
	rm -f /tmp/tmp_path_avail
	rm -f /tmp/tmp_path_dir
fi
if [ -f /tmp/tmp_root_avail ];then
	root_avail=`cat /tmp/tmp_root_avail`
	rm /tmp/tmp_root_avail
fi

###################compute######################
if [ -z ${path_avail} ];then
   path_avail=${root_avail}
fi
echo "${path_avail}"
}

space_avail=`get_space_available $cpu2017_dir`

get_real_val()
{
    var=$(echo $1 | tr  -d '[0-9.]')
    num=$(echo $1 | tr -cd '[0-9.]')
    case $var in
        [Kk]*) real_val=$(echo $num 1024|awk '{printf("%.0f\n",$1*$2)}') ;;
        [Mm]*) real_val=$(echo $num 1024|awk '{printf("%.0f\n",$1*$2*$2)}') ;;
        [Gg]*) real_val=$(echo $num 1024|awk '{printf("%.0f\n",$1*$2*$2*$2)}') ;;
        [Tt]*) real_val=$(echo $num 1024|awk '{printf("%.0f\n",$1*$2*$2*$2*$2)}') ;;
            *) real_val=$(echo "$num") ;;
    esac
    echo $real_val
}
space_bytes=`get_real_val $space_avail`
system_threads=`nproc`
until [[ $space_bytes -gt $[system_threads*1024*1024*1024] ]]
do
	read -p "$cpu2017_dir space left is $space_avail, less than ${system_threads}G. Please choose another directory: " cpu2017_dir
	space_avail=`get_space_available $cpu2017_dir`
	space_bytes=`get_real_val $space_avail`
done

mount $speccpu_iso_name $cpu2017_mnt_dir
cd $cpu2017_mnt_dir
echo "yes" > ~/temp.cpu
./install.sh -d $cpu2017_dir < ~/temp.cpu
[[ ! $? -eq 0 ]] && echo "Installation failed!" && umount $cpu2017_mnt_dir && exit
rm -f ~/temp.cpu
cd -

tar -zxf $cc_name -C /opt
tar -zxf $libs_name -C /opt
cd /opt/$cc_dir_name
./install.sh
[[ ! $? -eq 0 ]] && echo "AOCC installation failed!" && umount $cpu2017_mnt_dir && exit
cd -

tar -xf $opt_pkg_name -C $cpu2017_dir
umount $cpu2017_mnt_dir

echo "Installation successful. Please check the run script $cpu2017_dir/reportable-hygon-aocc.sh and do the run." && exit
