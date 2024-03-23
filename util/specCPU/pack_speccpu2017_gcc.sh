#!/bin/bash

package_name=speccpu2017-hygon-gcc10.3-opt-20221128

speccpu_root=/home/cpu2017

speccpu_dir=$speccpu_root/benchspec/CPU

rm -rf $package_name

mkdir $package_name

cd $package_name

cases_dir=`ls -l $speccpu_dir | awk -F' ' '{print $9}' | grep -e ^[0-9]..`

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

cp -ra $speccpu_root/lib .
cp -ra $speccpu_root/lib32 .

tar -czvf $package_name.tar.gz .

mv $package_name.tar.gz ..
cd ..

