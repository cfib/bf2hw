// BF2HW
// Copyright (C) 2017  Christian Fibich
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

//
// IP for the bambu_putchar() function. Writes a single character
//

module bambu_putchar (input clock, input reset, input start_port, output reg done_port, input [7:0] c, output reg [7:0] TX_DATA, output reg TX_ENABLE, input TX_READY);
    
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
    reg [2:0] tx_state;
    reg TX_READY_reg;
    wire TX_READY_posedge;

    localparam FIFO_STATE_IDLE = 2'b01,
               FIFO_STATE_WRITE = 2'b10;
    
    localparam TX_STATE_IDLE = 3'b001,
               TX_STATE_TX_BYTE = 3'b010,
               TX_STATE_WAIT_TX_READY = 3'b100;

    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            fifo_write <= 1'b0;
            done_port  <= 1'b0;
            fifo_state <= FIFO_STATE_IDLE;
        end else begin
            done_port  <= 1'b0;
            fifo_write <= 1'b0;
            if (fifo_state == FIFO_STATE_IDLE) begin
                if (start_port) begin
                    fifo_in    <= c;
                    fifo_state <= FIFO_STATE_WRITE;
                end
            end else begin
                if (fifo_full == 1'b0) begin
                    fifo_write <= 1'b1;
                    fifo_state <= FIFO_STATE_IDLE;
                    done_port  <= 1'b1;
                end
            end
        end
    end

    assign TX_READY_posedge = TX_READY & ~TX_READY_reg;

    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            tx_state  <= TX_STATE_IDLE;
            TX_DATA   <= 8'b0;
            TX_ENABLE <= 1'b0;
            fifo_read <= 1'b0;
            TX_READY_reg <= 1'b0;
        end else begin
            fifo_read <= 1'b0;
            TX_ENABLE <= 1'b0;
            TX_READY_reg <= TX_READY;
            case(tx_state)
                TX_STATE_IDLE : begin
                    if (fifo_empty == 1'b0 && TX_READY == 1'b1) begin
                        fifo_read <= 1'b1;
                        tx_state  <= TX_STATE_TX_BYTE;
                    end
                end
                TX_STATE_TX_BYTE : begin
                    TX_DATA   <= fifo_out;
                    TX_ENABLE <= 1'b1;
                    tx_state  <= TX_STATE_WAIT_TX_READY;
                end
                TX_STATE_WAIT_TX_READY : begin
                    if (TX_READY_posedge == 1'b1)
                        tx_state <= TX_STATE_IDLE;
                end
            endcase
        end
    end

endmodule
