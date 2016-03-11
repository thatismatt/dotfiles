#!/bin/bash

# Mirror the laptop display to the HDMI

if [[ -z "$1" ]]; then
    RESOLUTION="1680x1050"
else
    RESOLUTION=$1
fi

xrandr --output eDP1  --mode $RESOLUTION --pos 0x0 \
       --output HDMI1 --mode $RESOLUTION --pos 0x0
