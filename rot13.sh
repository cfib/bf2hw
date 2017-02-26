#!/bin/bash

baud=9600

lattice_idVendor="0403"
lattice_idProduct="6010"

dev=""

for devpath in $(find /sys/bus/usb/devices/usb*/ -path '*tty*' -name dev); do
    usbdir="$(dirname $devpath)/../../../../"
    devid=$(cat $devpath)
    idVendor=$(cat $usbdir/idVendor)
    idProduct=$(cat $usbdir/idProduct)
    if [ $idVendor != $lattice_idVendor ] || [ $idProduct != $lattice_idProduct ]; then
        continue
    fi
    dev=$(udevadm info -rq name "/sys/dev/char/$devid/")
done

if [ $? != 0 ] || [ -z $dev ]; then
    echo "ERROR: Could not find HX8K breakout board ttyUSB device"
    exit 255
fi

stty -F $dev cs8 -parenb -cstopb 9600

tmux new-session \; \
    send-keys "stdbuf -i0 -o0 rot13 | tee $dev" C-m \; \
    split-window -v \; \
    send-keys "picocom --imap lfcrlf $dev" C-m \; \
    select-pane -t 0 \;



