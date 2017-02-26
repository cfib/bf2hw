#SOURCE=bf/hello.bf
SOURCE=bf-src/rot13.bf

all : rot13

bf2c.exe : bf2c/bf2c.c
	gcc $^ -o $@

bf2c_bambu_main.c : $(SOURCE) bf2c.exe 
	./bf2c.exe  < $(SOURCE) > bf2c_bambu_main.c

synth/top.v : bf2c_bambu_main.c
	./bambu.sh

impl-hx8k/bf2hw.bin : synth/top.v
	rm -f impl-hx8k/*.mem
	cp synth/array_ref_*.mem impl-hx8k/array.mem
	find synth/ -iname '*.mem' -exec cp {} impl-hx8k/ \;
	make -C impl-hx8k

rot13 : impl-hx8k/bf2hw.bin
	./rot13.sh
