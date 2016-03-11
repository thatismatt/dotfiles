#!/bin/bash

xrandr --output eDP1 --mode 3200x1800 --pos 0x0 --rate 60.0 \
       --output HDMI1 --off

DEVICE="SYNAPTICS Synaptics Large Touch Screen"
xinput set-prop "$DEVICE"  --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
