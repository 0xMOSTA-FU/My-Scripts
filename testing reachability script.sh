#!/bin/bash

 IP=$1
 PING=$(ping -c 4 $IP)
 TESTREAH=$(echo $PING )
        if [[ $TESTREAH= =~ "ttl" ]]; then 
           echo "the output: $IP IP reachable"
           else
            echo "the output: $IP not reachable"
           fi
