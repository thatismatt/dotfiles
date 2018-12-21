#!/bin/bash

#FONT_NAME="M+ 1m"
FONT_NAME="Iosevka"
FONT_SIZE="14"

while getopts ":f:s:" OPT; do
    case $OPT in
        f)
            FONT_NAME=$OPTARG
            ;;
        s)
            FONT_SIZE=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

echo "Setting font - name: $FONT_NAME"
echo "               size: $FONT_SIZE"

printf "\033]710;xft:$FONT_NAME:size=$FONT_SIZE\007"
