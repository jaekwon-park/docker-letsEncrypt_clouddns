#!/bin/bash

function file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(<"${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

#CERTIFICATE_FILE

# Setup Default AWS Configure

file_env 'EMAIL'


while (true); do
  certification_path=$(echo /etc/letsencrypt/archive/"$(ls /etc/letsencrypt/archive | grep -v default)"/*)
  if [ $(ls /etc/letsencrypt/archive/ | wc -l) -eq 0 ]; then
    if !  certbot certonly -n --agree-tos --email "$EMAIL" --dns-google --dns-google-credentials /mnt/$CERTIFICATE_FILE --server https://acme-v02.api.letsencrypt.org/directory --expand -d "$DNS_LIST" 
    then
      echo "$(date "+%F %H:%M") DNS Auth Failed" 
      exit
    fi
  else
    echo "$(date "+%F %H:%M") Remove Old cetificate files"
    rm -rf $certification_path
    if !  certbot renew
    then
      echo "$(date "+%F %H:%M") DNS Auth Failed" 
      exit
    fi
    echo "$(date "+%F %H:%M") Renew certificate Files Done."
  fi
  echo "$(date "+%F %H:%M") DNS Auth Success"
  if [ ! -d /etc/letsencrypt/archive/default ]; then
  	echo "$(date "+%F %H:%M") create default directory"
  	mkdir /etc/letsencrypt/archive/default 
  fi
  echo "$(date "+%F %H:%M") copy certification file to /etc/letsencrypt/archive/default directory"
  if !  cp -rfp $certification_path /etc/letsencrypt/archive/default/
  then
      echo "$(date "+%F %H:%M") Certification copy failed" 
      exit
  else
      echo "$(date "+%F %H:%M") copied file list" 
      ls -alhd /etc/letsencrypt/archive/default/*
  fi
  echo "$(date "+%F %H:%M") i will Sleep two month"
  #pause to 2 month
  sleep 5184000
done
