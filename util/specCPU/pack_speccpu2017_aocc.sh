#!/bin/bash
#READ ME#
#need install-speccpu2017.sh to exists in same dir as this script#
echo "you need place aocc-compiler.tar in current directory"
echo 
echo 

cur=`pwd`

datetime=`date +%F | sed 's/-//g'`

opt_package=speccpu2017-hygon-aocc-opt-$datetime

package_name=hygon-speccpu2017-aocc3.1.0-opt-$datetime

libs_name=libs-$datetime

aocc_name=`ls  $cur | grep aocc-compiler | head -1`

libs="extra_libs_32 extra_libs_64 glibc_2_30_64bit glibc-2.33-32bit glibc-2.33-64bit hygonlibm jemalloc setenv_AOCC.sh"

speccpu_root=/home/cpu2017

speccpu_dir=$speccpu_root/benchspec/CPU

cases_dir=`ls -l $speccpu_dir | awk -F' ' '{print $9}' | grep -e ^[0-9]..`



tmp=${cur}/tmp
function pack_specdir()
{
	rm -rf $package_name
	
	mkdir $package_name
	
	cd $package_name
	
	
	for i in $cases_dir ; do
	        mkdir -p benchspec/CPU/${i}/exe
	        cp -a $speccpu_dir/${i}/exe/* benchspec/CPU/${i}/exe
	done
	
	cp -ra $speccpu_root/config .
	rm -f ./config/*.conf.*
	rm -f ./config/*.cfg.*
	
	cp -ra $speccpu_root/inc_template .
	
	cp -a $speccpu_root/*.sh .
	rm -f install.sh
	rm -f uninstall.sh
	
	tar --use-compress-program=pigz -cpvf $package_name.tar.gz .

	mv $package_name.tar.gz ..
	cd ..
	rm -rf $package_name
}

function pack_lib()
{
	cd /opt
	tar --use-compress-program=pigz -cpvf ${tmp}/${libs_name}.tar.gz ${libs}
	cd ${tmp}
}

function pack_aocc()
{
	cd /opt
	cp $cur/$aocc_name $tmp
#	tar --use-compress-program=pigz -cpvf ${tmp}/${aocc_name}.tar.gz ${aocc_name}
	cd ${tmp}
}

function main()
{
	mkdir -p ${tmp}
	cd ${tmp}
	rm -rf *
	
	pack_specdir
	pack_lib
	pack_aocc
	
	echo "pack over"
	cd ${tmp}
#	cp ${cur}/install-speccpu2017.sh ${tmp}
	a=$cur/`dirname $0`/install-speccpu2017.sh
	pwd
	ls $a
	cp $a ${tmp}
	
	tar --use-compress-program=pigz -cpvf ${opt_package}.tar.gz .
	mv ${opt_package}.tar.gz ..
	
	#clean env
	cd ${cur}
	rm -rf ${tmp}
}

main
