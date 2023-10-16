`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2023 02:54:06 PM
// Design Name: 
// Module Name: matrix_mult
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

module matrix_mult (
    input clock,
    input reset,
    input sample_load,
    input [14:0] sizeA,
    input [14:0] sizeB,
    output done,
    output sample,
    output [31:0] sample_value,
    output [14:0] resulting_size
);

    reg [31:0] matrixA [0:31][0:31];
    reg [31:0] matrixB [0:31][0:31];
    reg [31:0] matrixC [0:31][0:31];




endmodule
