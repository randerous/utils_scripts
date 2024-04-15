#!/bin/bash

ulimit -s unlimited

. ./shrc
#configfile_name=gcc-11.3.0-ctuner-base.cfg
configfile_name=gcc-11.3.0-ctuner-peak.cfg


for i in 500 502 505 520 523 525 531 541 548 557 503 507 508 510 511 519 521 526 527 538 544 549 554 600 602 605 620 623 625 631 641 648 657 603 607 619 621 627 628 638 644 649 654
do
nohup runcpu -a run --size=test -C 1 -c $configfile_name --tune base -n 1 -l -o txt,screen $i &
done
