.PHONY : all clean prog


all : prog

bf2hw.blif: ../synth/*.v ../lib/toplevel/uart/*.v ../lib/toplevel/*.v
	yosys -v4 -l synth.log -p 'synth_ice40 -top bf2hw_top -blif $@' $^

bf2hw.asc: bf2hw.blif ../lib/hx8k-pins/bf2hw.pcf
	arachne-pnr -d 8k -o bf2hw.asc -p ../lib/hx8k-pins/bf2hw.pcf bf2hw.blif  -P ct256

bf2hw.bin: bf2hw.asc
	icepack bf2hw.asc bf2hw.bin

prog : bf2hw.bin
	iceprog bf2hw.bin

clean : 
	rm bf2hw.blif bf2hw.asc
