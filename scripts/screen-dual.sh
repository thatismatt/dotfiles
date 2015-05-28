#!/usr/bin/env bash

case "$HOSTNAME" in

    tillee)

        xrandr --output eDP1 --mode 3200x1800 --pos 0x0 --rate 60.0 \
               --output HDMI1 --mode 1920x1080 --pos 3200x0 --rate 60.0

        DEVICE="SYNAPTICS Synaptics Large Touch Screen"
        xinput set-prop "$DEVICE"  --type=float "Coordinate Transformation Matrix" 0.625 0 0 0 1 0 0 0 1

        # horizontal & low res
        # xrandr --output eDP1  --mode 1920x1080 --pos 0x0    --rate 60.0 \
        #        --output HDMI1 --mode 1920x1080 --pos 1920x0 --rate 60.0

        # vertical
        # xrandr --output HDMI1 --mode 1920x1080 --pos 0x0    --rate 60.0 \
        #        --output eDP1  --mode 3200x1800 --pos 0x1080 --rate 60.0

        ;;

    regee)

        xrandr --output VGA-1 --mode 1024x768 --pos 1920x0 \
               --output HDMI-1 --mode 1920x1080

        ;;
esac
