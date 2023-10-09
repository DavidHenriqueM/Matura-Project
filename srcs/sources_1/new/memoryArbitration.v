`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 02:24:57 PM
// Design Name: 
// Module Name: memoryArbitration
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


module memoryArbitration(
    input clock,
    input reset,
    input moduleEnable,
    input memoryEnable1,
    input memoryEnable2,
    input [14:0] Address1,
    input [14:0] Address2,
    input [31:0] Data1,
    input [31:0] Data2,
    output reg [31:0] DataOut1,
    output reg [31:0] DataOut2,
    output reg done1,
    output reg done2    
    );
    
    parameter s_idle = 2'b00;


    reg [2:0] state;

        sram SRAM(
        .clock      (sys_clk),
        .reset      (sw_0),
        .enable     (mem_enable), 
        .readWrite  (mem_readWrite),
        .dataIn     (mem_dataIn),
        .address    (mem_address),
        .dataOut    (mem_dataOut)
    );
endmodule
