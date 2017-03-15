module pll(
	input  clock_in,
	output clock_out,
	output reg locked
	);

    assign clock_out = clock_in;
    
    initial begin
        locked <= 1'b0;
        #5;
        locked <= 1'b1;
    end



endmodule
