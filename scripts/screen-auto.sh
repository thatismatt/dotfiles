#!/bin/bash

cd $( dirname $0 )

echo "[SCREEN AUTO] Detecting screens..."

SCREEN_COUNT=$( xrandr | grep ' connected ' | wc -l )

case "$SCREEN_COUNT" in

    1)
        echo "[SCREEN AUTO] One screen detected."
        ./screen-single.sh
        ;;

    2)
        echo "[SCREEN AUTO] Two screens detected."
        ./screen-dual.sh
        ;;

    *)
        echo "[SCREEN AUTO] I don't know how to auto configure $SCREEN_COUNT screens."
        ;;

esac
