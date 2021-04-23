#!/bin/bash

BASE_TAG=2.0.20210217-2235

launch_app() {

  docker stop
  sudo rm -rf /shared
  sudo mkdir /shared
  sudo chown -R $USER:$USER /shared
  sudo mount /dev/nvme1n1 /shared

  echo "
templates:
  - templates/postgres.template.yml
  - templates/redis.template.yml
  - templates/web.template.yml
  - templates/web.ratelimited.template.yml

expose:
  - 80:80   # http
  - 443:443 # https

params:
  db_default_text_search_config: pg_catalog.english
  #db_shared_buffers: 512MB

env:
  LC_ALL: en_US.UTF-8
  LANG: en_US.UTF-8
  LANGUAGE: en_US.UTF-8
  # DISCOURSE_DEFAULT_LOCALE: en

  ## How many concurrent web requests are supported? Depends on memory and CPU cores.
  ## will be set automatically by bootstrap based on detected CPUs, or you can override
  UNICORN_WORKERS: 8

  ## TODO: The domain name this Discourse instance will respond to
  ## Required. Discourse will not work with a bare IP number.
  DISCOURSE_HOSTNAME: forum.kozlenkov.de

  ## TODO: List of comma delimited emails that will be made admin and developer
  DISCOURSE_DEVELOPER_EMAILS: artem.kozlenkov@gmail.com

  DISCOURSE_SMTP_ADDRESS: email-smtp.eu-west-2.amazonaws.com
  DISCOURSE_SMTP_PORT: 587
  DISCOURSE_SMTP_USER_NAME: "AKIATWG3ZWRLOTENIXEL"
  DISCOURSE_SMTP_PASSWORD: "BEaaNEucTtzKR2x75ewfpROvMWDaXeEzzbG8d2qCUb3v"
  DISCOURSE_SMTP_ENABLE_START_TLS: true
  DISCOURSE_NOTIFICATION_EMAIL: softawebit@gmail.com

#docker_args:
#  - '--network nginx-proxy'

volumes:
  - volume:
      host: /shared/standalone
      guest: /shared
  - volume:
      host: /shared/standalone/log/var-log
      guest: /var/log

## Any custom commands to run after building
run:
  - exec: sudo apt update && sudo apt upgrade -y
  - exec: rails r "SiteSetting.notification_email='softawebit@gmail.com'"

hooks:
  after_code:
    - exec:
        cmd:
          - sudo rm -rf /plugins/docker_manager && sudo git clone https://github.com/discourse/docker_manager.git /plugins/docker_manager

" >/tmp/app.yml

  sudo cp /tmp/app.yml /var/discourse/containers/app.yml

  pushd /var/discourse

  ###### RAM ####
  ram=$(awk '/^Mem/ {print $2*0.75}' <(free --kilo))
  fram=$(printf "%.0f\n" $ram)
  ###### RAM ####

  pushd /var/discourse
  sudo ./launcher rebuild app --skip-mac-address --docker-args '--cpus=2 -m=$(printf "$fram%s" "k") --oom-kill-disable'
}

# bootstrapping discourse
install_discourse() {
  [[ ! -f ~/.ssh/github ]] && sudo cp /tmp/github ~/.ssh/github

  if [ -d /var/discourse ]; then
    cd /var/discourse
    git fetch
  else
    sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse
  fi

  launch_app
}

install_discourse
