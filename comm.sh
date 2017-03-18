#!/bin/bash


# BF2HW
# Copyright (C) 2017  Christian Fibich
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# ------------------------------------------------------------------
# This script tries to find the ttyUSB device provided by the HX8K
# breakout board and sets up the demo environment
# ------------------------------------------------------------------

baud=9600


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


# If no tty device is supplied, default to symlinked HX8K device
if [ -z $dev ]; then
    dev="/dev/ttyHX8K"
fi

if [ ! -e "$dev" ]; then
    echo "ERROR: Invalid ttyUSB device"
    echo " * Is your HX8K breakout board plugged in?"
    echo " * Have you added the following udev rule:"
    echo "   SUBSYSTEM==\"tty\",ATTRS{idVendor}==\"0403\",ATTRS{idProduct}==\"6010\",ATTRS{product}==\"Lattice FTUSB Interface Cable\", SYMLINK+=\"ttyHX8K\""
    echo " * Have you supplied the correct path?"
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

