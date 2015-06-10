#!/bin/bash

for x in 0 1
do
    for y in 30 37 33 31 35 34 36 32
    do echo -en "[\e[${x};${y}mcolour\e[0m] "
    done
    echo ""
done
