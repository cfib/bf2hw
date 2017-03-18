# BF2HW #

Use Brainfuck as a Hardware Description Language!

> Your scientists were so preoccupied with whether or not they could, they did not stop to think if they should.
>
> -- Jurassic Park

Watch a demo: https://asciinema.org/a/dg84cqap9lxbniyy0wvrcf3gp


## How this works ##

1. `bf2c.exe` converts the Brainfuck code to C
2. Bambu synthesizes C to Verilog, includes the I/O modules we specified in
   Verilog (I/O FIFO, UART connection)
3. Yosys synthesizes Verilog to iCE40 netlist
4. Arachne/iCEStorm generates HX8K bitstream

## Getting Started ##

### Prerequisites ###

* PandA Bambu (http://panda.dei.polimi.it/?page_id=31)
* Yosys, Icestorm Toolchain (http://www.clifford.at/icestorm/)
* `figlet` for `demo.sh`
* `tmux` for the ROT13 demo
* `picocom`
* `rot13` for the ROT13 demo (e.g., via `bsdgames` package on Debian)
* `iverilog` for simulation
* `GTKWave` for displaying simulation waveforms
* (optionally) `source-highlight` (and `/usr/bin/src-hilite-lesspipe.sh`) for `demo.sh`
* A Lattice HX8K breakout board

The following udev rule is needed by `comm.sh` to automatically find the HX8K board:

    SUBSYSTEM=="tty",ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010",ATTRS{product}=="Lattice FTUSB Interface Cable", SYMLINK+="ttyHX8K"

This creates a device symlink for the HX8K's FTDI chip

The path to PandA Bambu is set to `$HOME/opt/panda/bin/bambu` in `bambu.sh`.
You may need to change it according to your setup.

### Scripts ###

#### Demo Script ####

`demo.sh <Demo Project>`

Runs the complete flow from Brainfuck to Bitstream.

The following demos are contained in this repo:

* `hello`: Print "Hello World" on terminal after initial input
* `rot13`: ROT13 (Caesar) "cypher"
* `triangle`: Print a Sierpinski Triangle to the terminal after initial input


The ROT13 demo uses `tmux` to split the terminal into a _sender_ and a _receiver_
window.

* In the sender window, the entered plaintext will be echoed as cyphertext. The cyphertext is written to the serial port.
* The receiver window launches `picocom` to listen to the serial port where the hardware is connected. The cyphertext is decyphered by the ROT13 hardware and the plaintext is sent back to the host via serial port.

#### Download Script ####

`comm.sh <Demo Project> [<Serial I/F>]`

Downloads just the bitstream and opens the setup for the demo.
Supports the same set of demos as `demo.sh`.

As a second parameter, the serial interface (e.g., `/dev/ttyUSB0`) may
be given. If it is omitted, `comm.sh` tries to find the serial port
to which the HX8K Breakout Board is connected to via USB VID and PID.

#### Bambu Script ####

`bambu.sh`

Runs PandA Bambu for C to Verilog synthesis. Synthesizes `bf2c_bambu_main.c`
to `synth/top.v`


## Repo Layout ##

    ├── bf2c                      : BF-to-C translator source
    ├── bf-src                    : Brainfuck source code
    ├── impl-hx8k                 : Yosys/Icestorm working directory
    ├── lib                       : Main function, include file for I/O functions
    │   ├── bambu_io_hw           : Verilog code for `bambu_get()` and `bambu_put()` FUs, XML constraints
    │   ├── hx8k-pins             : HX8K breakout board pin mapping
    │   └── toplevel              : Toplevel Verilog code
    │       └── uart              : UART2BUS core
    ├── sim                       : Icarus/GTKwave script
    ├── synth                     : Bambu output directory
    └── tb                        : Testbench directory

## Hardware Working Principle ##

`bf2c` generates C code equivalent to the original Brainfuck source
code. This C code contains calls to the functions `bambu_get()` and
`bambu_put()` that either print or read one character.

`lib/bambu_io_hw` contains custom Verilog implementations for these
functions that store or read one word in a FIFO for each direction
and connect the other FIFO's port to the toplevel.

A UART (UART2BUS from OpenCores) then receives or sends the bytes
over a serial interface.


## Simulation ##

In `sim/`, execute `sim.sh`. This script copies over the `*.mem` files
from `synth/`, compiles all Verilog files using `iverilog`, simulates
with `vvp` and displays the result using `gtkwave`.

When used with the "Hello World" demo, the bytes sent may be observed
in the GTKwave output on the UART Tx parallel input signal `TXDATA`:


| 48 | 65 | 6c | 6c | 6f | 20 | 57 | 6f | 72 | 6c | 64 | 21 | 0a |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
|`H` |`e` |`l` |`l` |`o` |` ` |`W` |`o` |`r` |`l` |`d` |`!` |`\n`|


## FIXMEs ##

*Toplevel Testbench*

The toplevel testbench is very rudimentary. It just sends one byte over
the serial interface to the DUT and then waits for some time. Works
for the `hello` demo, but could definitely use some more work.



