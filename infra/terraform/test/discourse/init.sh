#!/bin/bash

sudo apt update
sudo apt upgrade -y
#iptables -F
#service sshd restart

sudo echo "This is a test discourse-ec2-instance" > /tmp/index.html
cd /tmp  && sudo python3 -m http.server 80

#docker run -it --rm -d -p 80:80 --name web nginx
