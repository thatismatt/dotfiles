#!/usr/bin/env bash

# screensaver timeout 2 hours
xset s 7200 7200

case "$1" in

    on)
        # The +dpms option enables DPMS (Energy Star) features.
        xset +dpms
        ;;

    off)
        # The -dpms option disables DPMS (Energy Star) features.
        xset -dpms
        ;;

    *)
        echo "Usage `basename $0` (on|off)"
        echo "   on  - dpms on"
        echo "   off - dpms off"
        echo
        ;;

esac

xset q | grep --color=never "DPMS\|Screen Saver" -A2
