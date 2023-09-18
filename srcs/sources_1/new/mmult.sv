`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2023 02:42:49 PM
// Design Name: 
// Module Name: mmult
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


// 2 by 2 matrix multiplier
// Inputs are named A and B and output is named C
// Each matrix has 4 elements 8 bits wide. Thus the inputs are 4*8 = 32 bits long

module matrix_mult #(
    parameter s_init = 3'b000,
    parameter s_init_wait = 3'b001,
    parameter s_error = 3'b111,
    parameter s_multiply = 3'b010)
    
    (clk,
    reset, // active low reset
    enable, // High throughout the process
    inA,
    inB,
    Ax,
    Ay,
    Bx,
    By,
    outC,
    done); // High indcates that the process is complete

    input bit clk;
    input bit reset; // active low reset
    input bit enable; // High throughout the process
    input bit [8191:0] inA;
    input bit [8191:0] inB;
    input bit [7:0] Ax;
    input bit [7:0] Ay;
    input bit [7:0] Bx;
    input bit [7:0] By;
    output reg[8191:0] outC;
    output reg done;
// temporary registers 
reg [31:0] matrixA [16][16];
reg [31:0] matrixB [16][16];
reg [31:0] matrixC [16][16];




reg signed [63:0] temp; // stores the product of multiplication

reg [2:0]state; //state indication


always_ff @(posedge clk) begin
    case(state)
        s_init:
        begin
            if (Ay == Bx) begin
                state <= s_error;
            end
            else begin
                for (int i = 0; i < Ay; i++) begin
                    for (int j = 0; j < Ax; j++) begin
                        matrixA[i][j] <= inA [Ax * i + j +: 32];
                    end
                end
                for (int i = 0; i < By; i++) begin
                    for (int j = 0; j < Bx; j++) begin
                        matrixB[i][j] <= inB [Ax * i + j +: 32];
                    end
                end
                state <= s_multiply;
            end
        end
        s_multiply:
        begin
            
        end
    endcase // state
end
//parameter 
/*
always @(posedge clock, negedge reset)
begin
    if(reset == 0)begin  // active low reset
        i = 0;
        j = 0;
        k = 0;
        temp = 0;
        first_cycle = 1;
        end_mult = 0;
        done = 0;
        // initialization of matrix elements
        for(i=0; i<=1; i=i+1) begin
            for(j=0; j<=1; j=j+1) begin
            matrixA[i][j] = 32'd0;
            matrixB[i][j] = 32'd0;
            matrixC[i][j] = 32'd0;
            
        end
     end
    end

    else begin
        if(enable == 1)
            if(first_cycle == 1) begin
            // first cycle converts 1-D array inputs to 2-D matices
            for(i = 0;i<=1; i = i+1) begin
                for(j = 0;j<=1; j = j+1) begin
                    matrixA[i][j] = A[(i*2+j)*8+:8];
                    matrixB[i][j] = B[(i*2+j)*8+:8];
                    matrixC[i][j] = 8'd0;
                end
            end
            // re-initialisation of registers
            first_cycle = 0;
            end_mult = 0;
            i = 0;
            j = 0;
            k = 0;
        end
        else if(end_mult == 0) begin // if multiplication hasn't ended keep multiplying
            temp = matrixA[i][k]*matrixB[k][j];
            matrixC[i][j] = matrixC[i][j] + temp[7:0]; // lower half of the product is accumulatively added to form the result
        if(k==1) begin
            k =0;
            if(j == 1) begin
                j = 0;
                if (i == 1)begin
                    i = 0;
                    end_mult = 1;
                end
                else
                    i = i +1;
            end
            else
                j = j + 1;
        end
        else
            k = k + 1;
        end
        else if(end_mult == 1) begin 
        // conversion of 2-D matrix into 1-D array after the termination of the multiplication
            for(i=0; i<=1; i=i+1) begin
                for(j=0; j<=1; j=j+1) begin
                    C[(i*2+j)*8+:8] = matrixC[i][j];
                end
            end
            done = 1;
        end
    end 
end    
*/    
endmodule