`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2023 08:54:46 PM
// Design Name: 
// Module Name: com_dec_tb
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


module com_dec_tb(

    );
    


    reg clk;
    reg [31:0] r_testdata;
    reg [31:0] r_inword;
    reg [7:0] r_testcommand;
    reg [7:0] r_testaddress;
    reg [7:0]  r_uart_byte; 
    reg r_uart_tx_enable;
    //reg [3:0] r_state;
    wire [3:0] w_state;


    // registers for WTB
    reg r_WTB_enable;
    reg r_WTB_mode_select;
    reg [31:0] r_WTB_word;
    reg [7:0] r_WTB_byte;

    // wires for WTB

    wire w_WTB_serial;
    wire w_WTB_done;
    wire [2:0] w_WTB_state;

    wire w_uart_out;
    wire w_uart_tx_done;
    wire [7:0] w_command;
    wire [14:0] w_address;
    wire [31:0] w_data;
    wire w_cmd_dec_done;
    wire [1:0] w_error;

    reg [7:0] r_command_out;
    reg [7:0] r_address_out;
    reg [31:0] r_data_out;

    reg [1:0] state_counter = 0;
    reg [1:0] done_counter = 0;
    reg clk_count = 0;

    command_decoder CommandDecoder(
        .clock(clk),
        .uart_in(w_WTB_serial),
        .o_command(w_command),
        .o_address(w_address),
        .o_data(w_data),
        .o_done(w_cmd_dec_done),
        .o_error(w_error)
        );
    
    word_to_byte_tx WTB(
        .clock(clk),
        .enable(r_WTB_enable),
        .i_mode_select(r_WTB_mode_select),
        .i_word(r_WTB_word),
        .i_byte(r_WTB_byte),
        .o_serial(w_WTB_serial),
        .o_done(w_WTB_done)
        );
    initial begin

        //r_WTB_enable <= 1;
        clk <= 1;
        r_WTB_byte = 8'h00;
        r_WTB_mode_select <= 0;
        #15 r_WTB_enable <= 1;
        #86860 r_WTB_byte <= 8'hab;
        #86860 r_WTB_byte <= 8'h10;
        #86860 r_WTB_mode_select <= 1;
         r_WTB_word <= 32'h00ff12cd;
         r_WTB_enable <= 1;
        #86860 r_WTB_enable <= 0;

        #10000000
        //r_WTB_enable <= 1;

        r_WTB_byte = 8'h01;
        r_WTB_mode_select <= 0;
        #15 r_WTB_enable <= 1;
        #86860 r_WTB_byte <= 8'hcd;
        #86860 r_WTB_byte <= 8'h25;
        #86860 r_WTB_enable <= 0;

    end

    /*always @(w_cmd_dec_done) begin
        r_WTB_enable <= 0;
    end*/
    
    
    always begin
        #5 clk <= ~clk;
    end


    


   
endmodule
