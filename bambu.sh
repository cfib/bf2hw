#!/bin/bash

# ------------------------------------------------------------------
# This script executes Bambu HLS with bf2c_bambu_main.c as input
# ------------------------------------------------------------------

bambu=$HOME/opt/panda/bin/bambu
script=`readlink -e $0`
root_dir=`dirname $script`
io=$root_dir/lib/bambu_io_hw
main=bf2c_bambu_main.c

rm -rf synth
mkdir -p synth
cd synth
$bambu -O3 -v4 --std=c99 $root_dir/$main --reset-type=async --reset-level=high --clock-period=41.67 $io/constraints_STD.xml $io/BF2HW_IPs.xml --file-input-data=$io/bambu_getchar.v,$io/bambu_putchar.v --experimental-setup=BAMBU

