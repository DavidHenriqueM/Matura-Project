`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2023 04:33:10 PM
// Design Name: 
// Module Name: word_to_byte_tb
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


module word_to_byte_tb(
    );

    reg clk = 0;
    reg enable = 0;
    reg [31:0] i_word = 0;
    reg [7:0] i_byte = 0;
    reg mode_select = 0;

    wire [7:0] w_data;
    wire w_done;
    wire w_serial;
    wire [2:0] w_main_state;

    

    word_to_byte_tx WTB(
        .clock(clk),
        .enable(enable),
        .i_mode_select(mode_select),
        .i_word(i_word),
        .i_byte(i_byte),
        .o_serial(w_serial),
        .r_data(w_data),
        .o_done(w_done),
        .main_state(w_main_state)
        );

    initial begin
        clk <= 0;
        enable <= 0;
        mode_select <= 0;
        fork
            #5 i_word <= 32'h00ff90af;
            #5 i_byte <= 8'h00;
            #10 enable <= 1;
            #5 mode_select <= 0;
            #1800 enable <= 1;
            #1800 i_byte <= 8'hcd;
        join
    end

    

    always begin
        #5 clk <= ~clk;
    end
endmodule
