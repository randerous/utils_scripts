#!/bin/bash
name=$1
ps --no-headers -eo psr,cmd | grep $name | grep -v grep | grep -v get_running_core
