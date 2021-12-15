#!/bin/bash -e

sudo apt update
sudo apt upgrade -y
iptables -F
service sshd restart