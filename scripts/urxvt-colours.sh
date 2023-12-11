#!/bin/bash

# https://unix.stackexchange.com/questions/232881/urxvt-change-background-color-on-the-fly

# see ~/.Xresources
# URxvt.foreground:  #aaaaaa
# URxvt.background:  #0a0d0e

case $1 in

    l|light)
        printf '\033]10;#222222\007'
        printf '\033]11;#eeeeee\007'
        ;;

    d|dark)
        printf '\033]10;#aaaaaa\007'
        printf '\033]11;#0a0d0e\007'
        ;;

    *)
        echo "Usage $0 dark|d|light|l"

esac
