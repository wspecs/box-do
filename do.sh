#!/bin/bash

source /etc/wspecs/global.conf
source /etc/wspecs/functions.sh

# apt-get purge -y do-agent
# curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash
# /opt/digitalocean/bin/do-agent --version
# install_once s3cmd

DO_BUCKET_NAME="${DO_BUCKET_NAME:-$(echo $PRIMARY_HOSTNAME | sed 's/\.[^.]*$//' | sed 's/\./-/g')}"
DO_REGION="${DO_REGION:-nyc3}"

if [[ ! -f $HOME/.s3cfg ]] &&  [[ -v DO_ACCESS_KEY ]] && [[ -v DO_SECRET_KEY ]]; then
  cat s3cfg.conf |
    sed s/ACCESS_KEY/$DO_ACCESS_KEY/ | \
    sed s/SECRET_KEY/$DO_SECRET_KEY/ |\
    sed s/REGION/$DO_REGION/ > $HOME/.s3cfg

  if [[ ! $(s3cmd ls | grep $DO_BUCKET_NAME) ]]; then
    echo creating new bucket
    s3cmd mb s3://$DO_BUCKET_NAME
  fi
fi
