#!/bin/bash

# Validate input arguments
if [[ $# -ne 3 ]]; then
    echo 'Incorrect usage, correct usage: ./vpn_creator.sh client_name <ip1> <ip2>'
    exit 1
fi

# Variables
dir=~/easy-rsa
ccd_dir="/etc/openvpn/ccd"
client_name=$1
ip1=$2
ip2=$3
ip1_in_use=$(grep -r "$ip1" $ccd_dir)
ip2_in_use=$(grep -r "$ip2" $ccd_dir)
log_file="$dir/creation.log"
error_log="$dir/failed.log"

# Function to validate IP addresses
function validate_ip() {
    local ip=$1
    if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid IP address: $ip"
        exit 1
    fi
}

# Validate the IP addresses
validate_ip $ip1
validate_ip $ip2

echo "THE CLIENT NAME IS: $client_name"
#search for the first ip address
if [[ -n $ip1_in_use ]]; then
    echo "Sorry!!  The IP address $ip1 is already in use in the following file as shown below:"
    echo "$ip1_in_use"
    exit 1
else
    echo "Hurray!! The IP address $ip1 is not in use."
fi

if [[ -n $ip2_in_use ]]; then
    echo "Sorry!! The IP address $ip2 is already in use in the following file as shown below"
    echo "$ip2_in_use"
    exit 1
else
    echo "Hurray!! The IP address $ip2 is not in use."
fi

# Change to the Easy-RSA directory
cd $dir || { echo "Failed to change directory to $dir"; exit 1; }

# Check if the client config already exists
if [ ! -f ~/client-configs/files/$client_name.ovpn ]; then
    echo "Creating client: $client_name"
else
    echo "File $client_name already exists. Please choose another name."
    exit 1
fi

# Generate the client's key and request
printf '\n' | ./easyrsa gen-req $client_name nopass
if [[ $? -ne 0 ]]; then
    echo "Error in creating $client_name key file" | tee -a $error_log
    exit 1
fi

# Copy the private key and request
cp pki/private/$client_name.key ~/client-configs/keys/
cp pki/reqs/$client_name.req /tmp

# Move to CA server directory and import the request
cd ~/ca-server || { echo "Failed to change directory to ~/ca-server"; exit 1; }
./easyrsa --batch import-req /tmp/$client_name.req $client_name
if [[ $? -ne 0 ]]; then
    echo "Error in importing $client_name req file" | tee -a $error_log
    exit 1
fi

# Sign the client's request
./easyrsa --batch sign-req client $client_name
if [[ $? -ne 0 ]]; then
    echo "Error in signing $client_name req file" | tee -a $error_log
    exit 1
fi

# Copy the signed certificate
cp pki/issued/$client_name.crt ~/client-configs/keys/

# Create the OpenVPN client configuration
~/client-configs/make_config.sh $client_name
if [[ $? -ne 0 ]]; then
    echo "Error in creating $client_name.ovpn" | tee -a $error_log
    exit 1
fi

# Add IP configuration to the CCD directory
echo "ifconfig-push $ip1 $ip2" >> /etc/openvpn/ccd/$client_name

# Move the .ovpn file to the files_conf directory and check if successful
cp /root/client-configs/files/$client_name.ovpn /root/client-configs/files_conf/$client_name.conf
if [[ -f /root/client-configs/files_conf/$client_name.conf ]]; then
    echo "$client_name.ovpn file created. Please find it at /root/client-configs/files_conf/$client_name.conf" | tee -a $log_file
else
    echo "$client_name client file creation failed" | tee -a $error_log
    exit 1
fi

# Clean up temporary request file
rm /tmp/$client_name.req

# Copy the .ovpn file to the Downloads directory
cp /root/client-configs/files/$client_name.ovpn /home/vuelogix/Downloads
if [[ $? -eq 0 ]]; then
    echo "File $client_name.ovpn copied successfully to /home/vuelogix/Downloads"
else
    echo "Failed to copy $client_name.ovpn to /home/vuelogix/Downloads" | tee -a $error_log
    exit 1
fi

echo "************ VPN client file: /root/client-configs/files/$client_name.ovpn"
