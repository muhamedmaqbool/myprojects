#!/bin/bash
while IFS= read -r ip; do
    if ping -q -c5 "$ip" &>/dev/null; then
        echo "$ip is Pingable"
    else
        echo "$ip Not Pingable"
    fi
done <"$HOME"/iplist.txt
