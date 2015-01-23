#!/usr/bin/env bash

cd $( dirname $0 )

case "$1" in

    s|single)
        ./screen-single.sh
        ;;

    d|dual)
        ./screen-dual.sh
        ;;

    *)
        echo "Usage `basename $0` (s|single|d|dual)"
        ;;

esac

./background.sh

./restart-compton.sh
