#!/usr/bin/env bash
#USAGE:script to analyse transfer rate and timings


if [[ $# -ne 2 ]]
then
     echo "you want to run this script by mentioning source and destination along with the script as shown below:"
     echo " $0 <source> <destination>"
     exit 1
fi


a=$1
b=$2
rsync -av --progress $1 $2

