#!/bin/bash

# BF2HW
# Copyright (C) 2017  Christian Fibich
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

PROJECT=$1
SOURCE_DIR=bf-src

# ------------------------------------------------------------------
# This script executes the entire demo flow
# ------------------------------------------------------------------


# Uncomment the following two lines if you have source-highlight and
# want C syntax highlighting in less(1) output
#export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
#export LESS=' -R -N '

case $PROJECT in
    rot13|hello|triangle) echo "'$PROJECT' demo selected";;
    *)  echo   "Usage: $0 DEMO"
        echo   "Execute the given DEMO, where DEMO is"
        echo   "    rot13    - ROT13 (caesar) en/decoder"
        echo   "    hello    - Hello World"
        echo   "    triangle - Sierpinski triangle on 80-column display"
        exit -1;;
esac

SOURCE="$SOURCE_DIR/$PROJECT.bf"

clear
echo ""
figlet -ct -f banner "Brainf*** to Hardware" || echo "Brainf*** to Hardware"
echo "With PandA Bambu & yosys/arachne-pnr/icestorm"
echo "Press ENTER to continue"
read

clear
echo "**************************************************************"
echo "Showing original BF code... "
echo "**************************************************************"
echo "Press ENTER to continue"
read

less $SOURCE

# Build BF to C converter
gcc -o bf2c.exe bf2c/bf2c.c -DMEMORY_SIZE=256

if [ $? != 0 ]; then
    echo "gcc failed"
    exit -1
fi

clear
echo "**************************************************************"
echo "Translating BF code to C"
echo "**************************************************************"
echo "Press ENTER to continue"
read

# Convert BF source to C, format it to be better human-readable
./bf2c.exe  < $SOURCE | astyle --style=kr > bf2c_bambu_main.c

if [ $? != 0 ]; then
    echo "bf2c failed"
    exit -1
fi


clear
echo "**************************************************************"
echo "Showing C translation of BF code... "
echo "**************************************************************"
echo "Press ENTER to continue"
read

less bf2c_bambu_main.c

clear
echo "**************************************************************"
echo "Running Bambu C-to-Verilog HLS"
echo "**************************************************************"
echo "Press ENTER to continue"
read

# Run Bambu
./bambu.sh

if [ $? != 0 ]; then
    echo "bambu failed"
    exit -1
fi

clear
echo "**************************************************************"
echo "Showing Verilog code generated by Bambu HLS... "
echo "**************************************************************"
echo "Press ENTER to continue"
read

less synth/top.v

clear
echo "**************************************************************"
echo "Running FPGA flow (yosys+arachne-pnr+icestorm) "
echo "**************************************************************"
echo "Press ENTER to continue"
read

# Run Yosys/Arachne/icepack
rm -f impl-hx8k/*.mem
touch impl-hx8k/array.mem
find synth -iname '*.mem' -exec cp {} impl-hx8k \;
make -C impl-hx8k bf2hw.bin
mv impl-hx8k/bf2hw.bin "impl-hx8k/$PROJECT.bin"

if [ $? != 0 ]; then
    echo "fpga flow failed"
    exit -1
fi

clear
echo "**************************************************************"
echo "Showing bitstream implemented by yosys/arachne-pnr/icestorm... "
echo "**************************************************************"
echo "Press ENTER to continue"
read

less impl-hx8k/bf2hw.asc

clear
echo "**************************************************************"
echo "Downloading bitstream, starting terminal "
echo "**************************************************************"
echo "Press ENTER to continue"
read

./comm.sh $PROJECT || echo "comm.sh failed. Run it manually as follows: comm-sh <PROJECT> <SERIAL PORT>"

