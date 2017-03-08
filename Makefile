#SOURCE=bf/hello.bf
PROJECT?=rot13

ifeq ($(PROJECT),hello)
	SOURCE=bf-src/hello.bf
endif
ifeq ($(PROJECT),fizzbuzz)
	SOURCE=bf-src/fizzbuzz.bf
endif
ifeq ($(PROJECT),rot13)
	SOURCE=bf-src/rot13.bf
endif

.PHONY: all demo

all :
	@echo "To build/flash the hardware, use:"
	@echo "    make demo PROJECT=<project name>"
	@echo 
	@echo "Select one of the following projects:"
	@echo "    rot13    - ROT13 encoder/decoder (default)"
	@echo "    hello    - Hello world"
	@echo "    fizzbuzz - FizzBuzz programming exercise"

bf2c_bambu_main.c : $(SOURCE) bf2c.exe 
	./bf2c.exe  < $(SOURCE) > bf2c_bambu_main.c

synth/top.v : bf2c_bambu_main.c
	./bambu.sh

impl-hx8k/bf2hw.bin : synth/top.v
	rm -f impl-hx8k/*.mem
	touch impl-hx8k/array.mem
	cp synth/array_ref_*.mem impl-hx8k/array.mem
	make -C impl-hx8k

demo : impl-hx8k/bf2hw.bin
	./rot13.sh


