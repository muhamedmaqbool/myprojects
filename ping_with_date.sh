#!/bin/bash

if [[ $# -ne 1 ]]
then
    echo "run the script with ip adress as shown below"
    echo "$0 <ip address>"
    exit 1
fi

ping $1 | while read i;
do 
  echo "$(date):   $i";
done >> $1.csv
