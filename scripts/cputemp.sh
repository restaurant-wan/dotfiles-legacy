#!/bin/zsh
temp1=`cat /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp2_input`
echo `expr $temp1 / 1000`
