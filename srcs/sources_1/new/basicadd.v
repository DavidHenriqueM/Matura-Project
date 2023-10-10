`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 08:29:02 AM
// Design Name: 
// Module Name: basicadd
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


module basicadd(
    input clk,
    input reset,
    input enable,
    input [31:0] a1,
    input [31:0] a2,
    output reg [31:0] sum
    );
    
    reg [31:0] regA1;
    reg [31:0] regA2;


    always @(posedge clk) begin
        regA1 <= a1;
        regA2 <= a2;
        if (!reset) begin
            // reset
            sum <= 32'b0;
        end
        else begin
            if(enable) begin
                sum <= regA1 + regA2;
            end else begin
                sum <= 32'b0;
            end 
        end
    end
    
endmodule
