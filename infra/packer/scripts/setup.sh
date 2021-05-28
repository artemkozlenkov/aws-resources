#!/bin/bash

#install docker, prerequisites
main() {
  sudo apt-get update

  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    net-tools \
    awscli

  sudo snap install ruby --classic

  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  sudo echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER

  sudo echo "{\"experimental\": true}" >/tmp/daemon.json
  sudo cp /tmp/daemon.json /etc/docker/daemon.json

  sudo dpkg-reconfigure --frontend noninteractive -plow unattended-upgrades

  sudo reboot now
}

main
