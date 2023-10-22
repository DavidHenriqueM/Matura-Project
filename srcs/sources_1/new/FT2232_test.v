`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 10:10:23 AM
// Design Name: 
// Module Name: FT2232_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: This is ment to test the the FTDI 2232hq uart transciever on the Basys 3 FPGA board
// 
//////////////////////////////////////////////////////////////////////////////////

// bre if this breaks im kinda not in a great place

module FT2232_test(
    input sys_clk,
    input RsRx,
    output reg RsTx
    );

always @(posedge sys_clk) begin //sequential assignment allows for the use of a debug core
    RsTx <= RsRx;
end


endmodule
