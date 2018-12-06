#!/bin/bash

case "$HOSTNAME" in

    tillee)

        xrandr --output eDP-1-1 --mode 3200x1800 --pos 0x0 \
               --output HDMI-1-1 --mode 1920x1080 --pos 3200x0

        DEVICE="SYNAPTICS Synaptics Large Touch Screen"
        xinput set-prop "$DEVICE"  --type=float "Coordinate Transformation Matrix" 0.625 0 0 0 1 0 0 0 1

        ;;

    regee)

        xrandr --output VGA-1 --mode 1024x768 --pos 1920x0 \
               --output HDMI-1 --mode 1920x1080

        ;;

    jellee)

        xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 \
               --output HDMI-1 --mode 1920x1080 --pos 1920x0

        ;;
esac
