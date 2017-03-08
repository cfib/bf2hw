#!/bin/bash

# ------------------------------------------------------------------
# This script tries to find the ttyUSB device provided by the HX8K
# breakout board and sets up the demo environment
# ------------------------------------------------------------------

baud=9600

lattice_idVendor="0403"
lattice_idProduct="6010"

dev=""

PROJECT=$1
dev=$2

case $PROJECT in
    rot13|hello|triangle) echo "'$PROJECT' demo selected";;
    *)  echo   "Usage: $0 DEMO"
        echo   "Execute the given DEMO, where DEMO is"
        echo   "    rot13    - ROT13 (caesar) en/decoder"
        echo   "    hello    - Hello World"
        echo   "    triangle - Sierpinski triangle on 80-column display"
        exit -1;;
esac


# If no tty device is supplied, try to find the ttyUSB device
if [ -z $dev ]; then

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
fi

if [ $? != 0 ] || [ -z $dev ]; then
    echo "ERROR: Could not find HX8K breakout board ttyUSB device"
    exit 255
fi

# download the corresponding bitstream
iceprog "impl-hx8k/$PROJECT.bin" || exit -1


stty -F $dev cs8 -parenb -cstopb 9600

# demo setup for the different BF programs
case $PROJECT in
    rot13)     
        # set up a tmux session with rot13 input piped to the serial device
        # in the upper frame, and picocom in the lower frame
        tmux new-session \; \
            send-keys "stdbuf -i0 -o0 rot13 | tee $dev" C-m \; \
            split-window -v \; \
            send-keys "picocom --imap lfcrlf $dev" C-m \; \
            select-pane -t 0 \;;;
    hello)     picocom --imap lfcrlf $dev;;
    triangle)  picocom --imap lfcrlf $dev;;
    *)  echo   "Usage: $0 DEMO"
        echo   "Execute the given DEMO, where DEMO is"
        echo   "    rot13    - ROT13 (caesar) en/decoder (default)"
        echo   "    hello    - Hello World"
        echo   "    triangle - Sierpinski triangle on 80-column display"
        exit -1;;
esac

