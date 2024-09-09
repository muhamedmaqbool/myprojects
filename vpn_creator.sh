#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo 'Incorrect usage, correct usage: ./vpn_creator.sh client_name <ip1> <ip2>'
    exit 1
fi

dir=~/easy-rsa
client_name=$1
ip1=$2
ip2=$3
cd $dir

if [ ! -f ~/client-configs/files/$1.ovpn ]
 then
  echo "clent name is $1"
else
  echo "file $1 already used ...try another name"
  exit 1
fi

echo "Client Name: $client_name, IP1: $2, IP2: $3" > maqbooooooooooool.txt



./easyrsa gen-req $1 nopass
if [[ $? -ne 0 ]];then
        echo "Error in creating $1 key and req file"
        exit 1
fi

cp pki/private/$1.key ~/client-configs/keys/
cp pki/reqs/$1.req /tmp
cd ~/ca-server
./easyrsa import-req /tmp/$1.req $client_name
./easyrsa sign-req client $1
cp pki/issued/$1.crt ~/client-configs/keys/

if [[ $? -ne 0 ]];then
        echo "Error in signing $1"
        exit 1
fi

cp pki/issued/$1.crt ~/client-configs/keys/
~/client-configs/make_config.sh $1

 echo "ifconfig-push" $2 $3 >> /etc/openvpn/ccd/$1
 if [ -f /root/client-configs/files_conf/$1.conf ]
 then
  echo "$1.ovpn file created ,please download this for windows client"
  echo "$1.conf file created ,please download this for linux client" >> $dir/creation.log
 else
  echo "$1 client file creation failed" >> $dir/failed.log
  exit 1
 fi

echo "Client Name: $client_name, IP1: $ip1, IP2: $ip2" > maqbooooooooooool.txt


echo "************ VPN client file :-  /root/client-configs/files/$client_name.ovpn"
