#!/bin/sh
id=$(xinput list | grep xwayland-pointer | awk '{{ print $4  }}' | cut -d"=" -f2)
xinput set-button-map $id 1 1 3 4 5 6 7 2
