module bf2hw_top(input clk12, input SERIAL_RX, output SERIAL_TX);

    `define D_BAUD_FREQ			12'd4
    `define D_BAUD_LIMIT		16'd621
    
    wire TX_BUSY;
    wire TX_WRITE;
    wire RX_VALID;
    wire [7:0] RX_DATA;
    wire [7:0] TX_DATA;
    wire TX_READY;
    
    wire clock;
    wire locked;
    wire reset;
    reg  [2:0] reset_sync;    
    assign TX_READY = ~TX_BUSY;
    
    pll the_pll (.clock_in(clk12), .clock_out(clock), .locked(locked));
    
    assign reset = reset_sync[2];
    
    initial begin
        reset_sync <= 3'b11;
    end
    
    always @(posedge clock or negedge locked) begin
        if (locked == 1'b0) begin
            reset_sync <= 3'b11;
        end else begin
            reset_sync <= {reset_sync[1:0],1'b0};
        end
    end
    

    uart_top uart (.clock(clock), .reset(reset),.ser_in(SERIAL_RX), .ser_out(SERIAL_TX),
        .rx_data(RX_DATA), .new_rx_data(RX_VALID), 
        .tx_data(TX_DATA), .new_tx_data(TX_WRITE), .tx_busy(TX_BUSY), 
        .baud_freq(`D_BAUD_FREQ), .baud_limit(`D_BAUD_LIMIT), 
        .baud_clk()
    );
        
    main_minimal_interface main(.clock(clock), .reset(reset), 
                                .start_port(1'b1), .RX_VALID(RX_VALID), .RX_DATA(RX_DATA),
                                .TX_READY(TX_READY), .done_port(), .return_port(),
                                .TX_ENABLE(TX_WRITE), .TX_DATA(TX_DATA));

endmodule
