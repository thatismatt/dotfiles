#!/bin/bash

BACKLIGHT_PATH="/sys/class/backlight/intel_backlight"

while [[ ! -z "$@" ]] ; do
    case $1 in
        -get|-g)
            cat $BACKLIGHT_PATH/brightness
            shift
            exit 0
            ;;
        -max|-m)
            cat $BACKLIGHT_PATH/max_brightness
            shift
            exit 0
            ;;
        -set|-s)
            if [[ -z "$2" ]] ; then
                echo $2 | sudo tee $BACKLIGHT_PATH/brightness &> /dev/null
                echo "-set|-s requires a brightness argument"
            elif [[ "max" -eq "$2" ]] ; then
                cat $BACKLIGHT_PATH/max_brightness | sudo tee $BACKLIGHT_PATH/brightness &> /dev/null
                exit 0
            else
                echo $2 | sudo tee $BACKLIGHT_PATH/brightness &> /dev/null
                exit 0
            fi
            ;;
        *)
            echo "Unknown arg:" $1
            ;;
    esac
    shift
done

echo "Usage $0 [-max|-m] [-get|g] [-set|-s <brightness>]"
exit 1
