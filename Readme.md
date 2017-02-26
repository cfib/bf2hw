# BF2HW #

Use Brainfuck as a Hardware Description Language!

> Your scientists were so preoccupied with whether or not they could, they did not stop to think if they should.
>
> -- Jurassic Park

## How this works ##

1. `bf2c.exe` converts the Brainfuck code to C
2. Bambu synthesizes C to Verilog, includes the I/O modules we specified in
   Verilog (I/O FIFO, UART connection)
3. Yosys synthesizes Verilog to iCE40 netlist
4. Arachne/iCEStorm generates HX8K bitstream

## Getting Started ##

### Prerequisites ###

* PandA Bambu (panda.dei.polimi.it/?page_id=31)
* Yosys, Icestorm Toolchain (www.clifford.at/icestorm/)
* `tmux`
* `picocom`
* A Lattice HX8K breakout board

### Scripts ###

#### Demo Script ####

`demo.sh <Demo Project>`

Runs the complete flow from Brainfuck to Bitstream.

The following demos are contained in this repo:

* `hello`: Print "Hello World" on terminal after initial input
* `rot13`: ROT13 (Caesar) "cypher"
* `triangle`: Print a Sierpinski Triangle to the terminal after initial input

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
    ├── sim                       : QuestaSim compile script
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

## FIXMEs ##

*FU implementations*

My FU implementations for `bambu_get()` and `bambu_put()` apparently
do not handle `done_port` correctly. A workaround using the upper 
byte of the `uint16_t` return value to indicate readiness has been
implemented.

*Toplevel Testbench*

The toplevel testbench is very rudimentary. It just jiggels the serial
RX line a little bit. Could use some more work.



