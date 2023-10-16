`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2023 09:05:25 AM
// Design Name: 
// Module Name: 1d_to_2d_size
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


module Oned_to_2d_size(
    input  [6:0]  in_sizeX,
    input  [6:0]  in_sizeY,
    input  [13:0] in_sizestring,
    output [6:0]  out_sizeX,
    output [6:0]  out_sizeY,
    output [13:0] out_sizestring
    );

    assign out_sizeX = in_sizestring [6:0];
    assign out_sizeY = in_sizestring [13:7];
    assign out_sizestring [6:0] = in_sizeX;
    assign out_sizestring [13:7] = in_sizeY;

endmodule
