`timescale 1ns / 1ps

module tb();

    reg clk;
    reg serial_in;
    wire serial_out;
    
    initial begin
        $dumpfile("bf2hw.vcd");
        $dumpvars;
        clk <= 1'b0;
        serial_in <= 1'b1;
        #1000;
        serial_in <= 1'b0;
        #1041666;
        serial_in <= 1'b1;
        #15000000;
        $finish;
    end
    
    always
        #20.67 clk = !clk;
        
    bf2hw_top dut(clk,serial_in,serial_out);

endmodule
