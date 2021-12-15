#!/bin/bash

sudo apt-get update
#sudo apt upgrade -y

#aws ec2 attach-volume --device /dev/sdxx --instance-id `cat /var/lib/cloud/data/instance-id` --volume-id vol-01234567890abc
#reboot

###### RAM ####
#  ram=$(awk '/^Mem/ {print $2*0.75}' <(free --kilo))
#  fram=$(printf "%.0f\n" $ram)

cd /var/discourse
sudo ./launcher start app --skip-mac-address --docker-args '--cpus=2 -m=1538m --oom-kill-disable'
