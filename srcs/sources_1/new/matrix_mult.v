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


// 2 by 2 matrix multiplier

// Each matrix has 4 elements 32 bits wide

module matrix_mult(
    input clock,
    input reset, // active low reset
    input enable, // High throughout the process
    input  [127:0] A,
    input  [127:0] B,
    // input [1:0] Ax,
    // input [1:0] Ay,
    // input [1:0] Bx,
    // input [1:0] By,
    output  reg[127:0] C,
    output reg done // High indcates that the process is complete
    );

// temporary registers 
//reg signed [31:0] matrixA [1:0][1:0];
//reg signed [31:0] matrixB [1:0][1:0];
//reg signed [31:0] matrixC [1:0][1:0];


// deterministic approach in one clock cycle

reg signed [31:0] a;
reg signed [31:0] b;
reg signed [31:0] c;
reg signed [31:0] d;

reg signed [31:0] w;
reg signed [31:0] x;
reg signed [31:0] y;
reg signed [31:0] z;

reg [1:0] operation_iterator;

// 00 is the most significant entry

always @(posedge clock) begin
       a <= A [31:0];
       b <= A [63:32];
       c <= A [95:64];
       d <= A [127:96];

       w <= B [31:0];
       x <= B [63:32];
       y <= B [95:64];
       z <= B [127:96];
    if (!reset) begin
        // reset
        C <= 128'h0;
        done <= 0;
        operation_iterator <= 0;
    end
    else if (enable) begin
        if (operation_iterator == 0) begin
            C [31:0]   <= (a*w) + (b+y);
            operation_iterator <= 1;
            done <= 0;
        end 
        if (operation_iterator == 1) begin
            C [63:32]  <= (a*x) + (b+z);
            operation_iterator <= 2;
            done <= 0;
        end
        if (operation_iterator == 2) begin
            C [95:64]  = (c*w) + (d*y);
            operation_iterator <= 3;
            done <= 0;
        end
        if (operation_iterator == 3) begin
            C [127:96] = (c*x) + (d*z);
            operation_iterator <= 0;
            done <= 1;
        end
    end else begin
        done <= 0;
    end
end

// integer i,j,k; // for the loops
// reg first_cycle; // indicates first clock cycle after enable high
// reg end_mult = 0; //goes high when multiplication is completed
// reg signed [63:0] temp; // stores the product of multiplication

 

/*always @(posedge clock) begin
    if(!reset)begin  // active low reset synchronous
        i = 0;
        j = 0;
        k = 0;
        temp = 0;
        first_cycle <= 1;
        end_mult <= 0;
        done <= 0;
        // initialization of matrix elements
        for(i=0; i<=1; i=i+1) begin
            for(j=0; j<=1; j=j+1) begin
            matrixA[i][j] <= 32'h0;
            matrixB[i][j] <= 32'h0;
            matrixC[i][j] <= 32'h0;        
            end
        end
    end else begin
        if(enable) begin
            if(first_cycle == 1) begin 
                for(i = 0; i <= 1; i = i+1) begin
                    for(j = 0; j <= 1; j = j+1) begin
                        matrixA[i][j] <= A[(i*2+j)*32+:32];
                        matrixB[i][j] <= B[(i*2+j)*32+:32];
                        matrixC[i][j] <= 32'h0;
                    end
                end
                first_cycle <= 0;
                end_mult <= 0;
                i = 0;
                j = 0;
                k = 0;
            end else if (end_mult == 0) begin // if multiplication hasn't ended keep multiplying
                temp = matrixA[i][k]*matrixB[k][j];
                matrixC[i][j] <= matrixC[i][j] + temp[31:0]; // lower half of the product is accumulatively added to form the result
            end
            if (k == 1) begin
                k = 0;
                if (j == 1) begin
                    j = 0;
                    if (i == 1) begin
                        i = 0;
                        end_mult = 1;
                    end else begin
                        i = i +1;
                    end
                end else begin
                    j = j + 1;
                end
            end else begin
                k = k + 1;
            end if (end_mult == 1) begin 
            // conversion of 2-D matrix into 1-D array after the termination of the multiplication
                for (i=0; i<=1; i=i+1) begin
                    for (j=0; j<=1; j=j+1) begin
                        C[(i*2+j)*32+:32] <= matrixC[i][j];
                    end
                end
                done <= 1;
            end
        end
    end 
end*/    
   
endmodule
