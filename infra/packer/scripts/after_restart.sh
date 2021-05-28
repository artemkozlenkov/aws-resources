#!/bin/bash

BASE_TAG=2.0.20210217-2235

launch_app() {
  sudo rm -rf /shared
  sudo mkdir /shared
  sudo chown -R $USER:$USER /shared

  #  sudo mount /dev/nvme1n1 /shared

  sudo cp ~/app.yml /var/discourse/containers/app.yml
}

# bootstrapping discourse
install_discourse() {
  if [ -d /var/discourse ]; then
    cd /var/discourse
    git checkout master
    git fetch
    git pull origin master
  else
    sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse
  fi

  launch_app
}

install_discourse
