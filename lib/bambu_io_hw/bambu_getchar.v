// BF2HW
// Copyright (C) 2017  Christian Fibich
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

//
// IP for the bambu_getchar() function. Reads a single character
//


module bambu_getchar (input clock, input reset, input start_port, output reg done_port, output reg [7:0] return_port, input [7:0] RX_DATA, input RX_VALID);
    
    reg  [7:0] data_reg;
    reg        fifo_read;
    wire [7:0] fifo_out;
    wire       fifo_empty;
    reg  [7:0] fifo_in;
    reg        fifo_write;
    wire       fifo_full;

    sync_fifo #(.width(8))
       the_fifo (.clk(clock), .reset(reset), .wr_enable(fifo_write), .rd_enable(fifo_read),
                 .empty(fifo_empty), .full(fifo_full), .rd_data(fifo_out), .wr_data(fifo_in),
                 .count());

    reg [1:0] fifo_state;
    reg [2:0] rx_state;

    localparam FIFO_STATE_IDLE = 2'b01,
               FIFO_STATE_WRITE = 2'b10;
    
    localparam RX_STATE_IDLE = 3'b01,
               RX_STATE_WAIT_DATA = 3'b10,
               RX_DONE       = 3'b100;
               


    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            fifo_write <= 1'b0;
            fifo_state <= FIFO_STATE_IDLE;
        end else begin
            fifo_write <= 1'b0;
            if (fifo_state == FIFO_STATE_IDLE) begin
                if (RX_VALID) begin
                    fifo_in    <= RX_DATA;
                    fifo_state <= FIFO_STATE_WRITE;
                end
            end else begin
                if (fifo_full == 1'b0) begin
                    fifo_write <= 1'b1;
                    fifo_state <= FIFO_STATE_IDLE;
                end
            end
        end
    end

    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            rx_state  <= RX_STATE_IDLE;
            fifo_read <= 1'b0;
            done_port <= 1'b0;
            return_port <= 8'b0;
        end else begin
            fifo_read <= 1'b0;
            done_port <= 1'b0;
            case(rx_state)
                RX_STATE_IDLE : begin
                    if (start_port) begin
                        rx_state  <= RX_STATE_WAIT_DATA;
                    end
                end
                RX_STATE_WAIT_DATA : begin
                    if (fifo_empty == 1'b0) begin
                        fifo_read <= 1'b1;
                        rx_state  <= RX_DONE;
                    end
                end
                RX_DONE : begin
                    done_port   <= 1'b1;
                    return_port <= fifo_out;
                    rx_state    <= RX_STATE_IDLE;
                end
            endcase
        end
    end

endmodule
