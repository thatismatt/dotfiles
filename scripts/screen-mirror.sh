#!/bin/bash

# Mirror the laptop display to the HDMI

if [[ -z "$1" ]]; then
    RESOLUTION="1920x1080"
else
    RESOLUTION=$1
fi

xrandr --output eDP-1  --mode $RESOLUTION --pos 0x0 \
       --output HDMI-1 --mode $RESOLUTION --pos 0x0

DEVICE="SYNAPTICS Synaptics Large Touch Screen"
xinput set-prop "$DEVICE"  --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
