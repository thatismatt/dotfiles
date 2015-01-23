#!/usr/bin/env bash

cd $( dirname $0 )

HDMI=$( xrandr -q | grep HDMI1 )
DEVICE="SYNAPTICS Synaptics Large Touch Screen"

if [[ "$HDMI" =~ " connected " ]]
then
    xrandr --output eDP1  --mode 3200x1800 --pos 0x0 --rate 60.0 \
           --output HDMI1 --mode 1920x1080 --pos 3200x0 --rate 60.0
    xinput set-prop "$DEVICE"  --type=float "Coordinate Transformation Matrix" 0.625 0 0 0 1 0 0 0 1
else
    xrandr --output eDP1  --mode 3200x1800 --pos 0x0 --rate 60.0 \
           --output HDMI1 --off
    xinput set-prop "$DEVICE"  --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
fi

./background.sh

./restart-compton.sh
