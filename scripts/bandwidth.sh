#!/bin/bash

if [ -z "$1" ]; then
        echo "Usage: $0 network-interface"
        echo "Where network-interface is one of:"
        ls /sys/class/net/
        exit
fi

INTERFACE=$1

while true
do
        R1=`cat /sys/class/net/$INTERFACE/statistics/rx_bytes`
        T1=`cat /sys/class/net/$INTERFACE/statistics/tx_bytes`
        sleep 1
        R2=`cat /sys/class/net/$INTERFACE/statistics/rx_bytes`
        T2=`cat /sys/class/net/$INTERFACE/statistics/tx_bytes`
        TBPS=`expr $T2 - $T1`
        RBPS=`expr $R2 - $R1`
        TKBPS=`expr $TBPS / 1024`
        RKBPS=`expr $RBPS / 1024`
        echo "$INTERFACE tx: $TKBPS kb/s rx: $RKBPS kb/s"
done
