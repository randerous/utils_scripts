#!/bin/bash
for i in `ls`; do echo -n "$i "; cat $i |  grep avg | awk '{print $2}'; done | sort -rhk 2
