# iVerilog Compile Script
rm -f *.mem
cp ../synth/*.mem .

iverilog ../lib/toplevel/sync_fifo.v       \
         ../lib/toplevel/uart/uart_top.v   \
         ../lib/toplevel/uart/uart_rx.v    \
         ../lib/toplevel/uart/baud_gen.v   \
         ../lib/toplevel/uart/uart_tx.v    \
         ../tb/pll.v                       \
         ../lib/toplevel/bf2hw_top.v       \
         ../synth/top.v                    \
         ../synth/bambu_putchar.v          \
         ../synth/bambu_getchar.v          \
         ../tb/bf2hw_tb.v                  

vvp a.out
gtkwave wave.gtkw

