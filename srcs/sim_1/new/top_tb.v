`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2023 06:11:47 PM
// Design Name: 
// Module Name: top_tb
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


module top_tb();

    reg sys_clk;
    reg sw_0;
    wire RsTx;
    wire RsRx;  // Connect this to your module's RsRx

    reg        wtb_enable;
    reg        wtb_mode_select;
    reg [31:0] wtb_word;
    reg [7:0]  wtb_byte;
    wire wtb_done;

    word_to_byte_tx WordToByte(
        .clock         (sys_clk),
        .enable        (wtb_enable),
        .i_mode_select (wtb_mode_select),
        .i_word        (wtb_word),
        .i_byte        (wtb_byte),
        .o_serial      (RsRx),
        .o_done        (wtb_done)
        );


    // Instantiate the top-level module
    top dut (
        .sys_clk(sys_clk),
        .sw_0(sw_0),
        .RsRx(RsRx),
        .RsTx(RsTx)
    );

    // Clock generation
    always begin
        #5 sys_clk = ~sys_clk; // Toggle the clock every 5 time units
    end

    initial begin
        sys_clk <= 0;
        sw_0 <=  1;
        #1 sw_0 <= 0;
        #1 sw_0 <= 1;
        wtb_byte <= 8'h00;
        wtb_mode_select <= 0;
        #9 wtb_enable <= 1;
        #2000 wtb_byte <= 8'hab;
        #2000 wtb_byte <= 8'h10;
        #2000 wtb_mode_select <= 1;
        wtb_word <= 32'h00ff12cd;
        #4000 wtb_byte <= 8'h01;
        wtb_mode_select <= 0;
        #2000 wtb_byte <= 8'hab;
        #2000 wtb_byte <= 8'h10;
        #1000 wtb_enable <= 0;
    end

endmodule
