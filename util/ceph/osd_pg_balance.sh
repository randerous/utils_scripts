rm -f out.txt osd.map
ceph osd df
ceph osd set-require-min-compat-client luminous
ceph osd getmap -o osd.map
osdmaptool osd.map --upmap out.txt --upmap-pool rbdpool --upmap-max=300 --upmap-deviation 1
cat out.txt

cur=`pwd`
 source $cur/out.txt

rm -f out.txt osd.map
