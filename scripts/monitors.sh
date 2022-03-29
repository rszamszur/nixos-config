#!/usr/bin/env bash

if [ -n "$DEBUG" ]; then
    set -x
fi

set -o errexit
set -o nounset
set -o pipefail

if [[ "$1" == "ON" ]]; then
    xrandr --output eDP-1 --mode 1920x1080 --rate 60.00 --output DP-2-3 --right-of eDP-1 --mode 2560x1440 --rate 60.00 --primary --output DP-2-1 --mode 1920x1080 --rate 60.00 --right-of DP-2-3 --rotate right
fi

if [[ "$1" == "OFF" ]]; then
    xrandr --output eDP-1 --mode 1920x1080 --rate 60.00 --primary --output DP-2-3 --off --output DP-2-1 --off
fi
