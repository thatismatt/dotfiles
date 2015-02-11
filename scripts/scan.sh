#!/bin/bash

MODE_ARG="--mode=color" # gray
RESOLUTION=$1
shift

case "$RESOLUTION" in

    hi)
        RESOLUTION_ARG="--resolution=300" # max 1200
        ;;

    lo)
        RESOLUTION_ARG="--resolution=75"
        ;;

    *)
        echo "Usage `basename $0` (hi|lo)"
        exit
        ;;

esac

hp-scan $MODE_ARG $RESOLUTION_ARG "$@"
