#!/bin/bash

#FONT_NAME="M+ 1m"
FONT_NAME="Iosevka"
FONT_SIZE="11"
USAGE=true

usage() {
    echo "Usage: $0 [-f FONT_NAME] [-s FONT_SIZE]"
}

while getopts ":f:s:" OPT; do
    case $OPT in
        f)
            FONT_NAME=$OPTARG
            USAGE=false
            ;;
        s)
            FONT_SIZE=$OPTARG
            USAGE=false
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage
            exit 1
            ;;
    esac
done

echo "Setting font - name: $FONT_NAME"
echo "               size: $FONT_SIZE"

$USAGE && usage

printf "\033]710;xft:$FONT_NAME:size=$FONT_SIZE\007"
