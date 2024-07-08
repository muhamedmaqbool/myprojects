#!/bin/bash
#Description:  script to renew letencrypt certificate

if [[ $(id -u) -ne 0 ]]
then
    echo "WARNING!! you can run this script as a root user or with sudo previlrges"
    exit 1
fi
log_file="/etc/letsencrypt/log.txt"
date=$(date '+%d-%m-%Y %H:%M:%S')

x=$(/usr/bin/certbot certificates | grep -oP 'VALID: \K\d+(?= days)')
echo "$date ===== $x days pending" >> $log_file
if [ "$x" -lt 30 ]; then
   sleep 5
   service nginx stop
   sleep 5
   /usr/bin/letsencrypt renew >> $log_file
   sleep 5
   service nginx start >> $log_file
   sleep 5
   service apache2 restart >> $log_file
   sleep 10
else
   echo "The certificate is valid for more than 30 days"
fi
