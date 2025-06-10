#!/bin/bash

GETIPS=$(host domain.com | grep -e "has address" -e "has IPv6" )
ALLIPS=$(echo "${GETIPS}"| grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}|([a-fA-F0-9:]+:+)+[a-fA-F0-9]+' )
IPSARR=(${ALLIPS})
for i in "${IPSARR[@]}";do
         if [[ $i =~ ":" ]]; then 
           sudo ip6tables -A INPUT -s $i -j DROP
           sudo ip6tables -A OUTPUT -d $i -j DROP

           else
           sudo iptables -A INPUT -s $i -j DROP
           sudo iptables -A OUTPUT -d $i -j DROP
           fi
done
