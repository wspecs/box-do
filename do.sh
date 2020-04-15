#!/bin/bash

source /etc/wspecs/global.conf
source /etc/wspecs/functions.sh

# apt-get purge -y do-agent
# curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash
# /opt/digitalocean/bin/do-agent --version
# install_once s3cmd

DO_BUCKET_NAME="${DO_BUCKET_NAME:-$(echo $PRIMARY_HOSTNAME | sed 's/\.[^.]*$//' | sed 's/\./-/g')}"
DO_REGION="${DO_REGION:-nyc3}"

install_once s3cmd

if [[ ! -f $HOME/.s3cfg ]] &&  [[ -v DO_ACCESS_KEY ]] && [[ -v DO_SECRET_KEY ]]; then
  cat s3cfg.conf |
    sed "s|ACCESS_KEY|$DO_ACCESS_KEY|" | \
    sed "s|SECRET_KEY|$DO_SECRET_KEY|" |\
    sed "s|REGION|$DO_REGION|" > $HOME/.s3cfg;

  if [[ ! $(s3cmd ls | grep $DO_BUCKET_NAME) ]]; then
    echo creating new bucket
    s3cmd mb s3://$DO_BUCKET_NAME
  fi
fi

if [ ! -z "$(bucket_has_file FINGERPRINT 2>&1 >/dev/null)" ]; then
  SEAL=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-64)
  echo $SEAL > /tmp/fingerprint.txt
  openssl rand -base64 48 | tr -d "=+/" | cut -c1-64 > /tmp/fingerprint.txt
  make_bucket wspecs-records
  s3cmd put /tmp/fingerprint.txt s3://$DO_BUCKET_NAME/FINGERPRINT --acl-private
  s3cmd put /tmp/fingerprint.txt "s3://wspecs-records/${PRIMARY_HOSTNAME}.fingerprint" --acl-private
  rm /tmp/fingerprint.txt
fi

if grep -q KEY_PASSPHRASE "$HOME/.s3cfg"; then
  tfile=$(mktemp /tmp/do.XXXXXXXXX)
  s3cmd get s3://$DO_BUCKET_NAME/FINGERPRINT $tfile --force
  SEAL=$(cat $tfile)
  echo $SEAL
  sed -i "s|KEY_PASSPHRASE|$SEAL|" $HOME/.s3cfg
  rm $tfile
fi

echo done
