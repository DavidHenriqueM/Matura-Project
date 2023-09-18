`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2023 09:06:13
// Design Name: 
// Module Name: uart_tx_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx_testbench();

   reg clock; 
   reg enable;
   
   reg [31:0] i_word;
   reg [7:0] in_Byte;
   //reg o_serial_out_expected, o_active_expected, o_done_expected;

   wire o_active, o_serial_out, o_done;
   wire [2:0]o_state;
   wire [7:0]o_data; 
   wire word_on;

    // array of testvectors

   //UUT

    uart_tx UART(
        .clock(clock),
        .enable(enable),
        .i_word(i_word),
        .in_Byte(in_Byte),
        .o_active(o_active),
        .serial_out(o_serial_out),
        .r_done(o_done)//,
        // .o_state(o_state),
        // .o_data(o_data),
        // .o_word_on(word_on)
    );

    initial begin
        enable <= 1;
        clock <= 0;
        i_word <= 32'h41af39b;
        in_Byte <= 8'hz;

    end

    always begin
        #0.1 clock <= ~clock;
    end

    always begin
        $display;
        #1;
    end

    always begin
        #100000000 $stop;
    end

endmodule
