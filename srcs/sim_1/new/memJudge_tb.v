`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 10:53:50 AM
// Design Name: 
// Module Name: memJudge_tb
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


module memJudge_tb(
    );

reg clk;
reg rst;

reg modEnable = 1;
reg memoryEnable1;
reg memoryEnable2;
reg readWrite1;
reg readWrite2;

reg [14:0] Address1;
reg [14:0] Address2;

reg [31:0] Data1;
reg [31:0] Data2;

wire [31:0] dataOut1;
wire [31:0] dataOut2;
 
wire done1;
wire done2;

memoryArbitration memJudge(
    .clock         (clk),
    .reset         (rst),
    .moduleEnable  (modEnable),
    .memoryEnable1 (memoryEnable1),
    .memoryEnable2 (memoryEnable2),
    .readWrite1    (readWrite1),
    .readWrite2    (readWrite2),
    .Address1      (Address1),
    .Address2      (Address2),
    .Data1         (Data1),
    .Data2         (Data2),
    .DataOut1      (dataOut1),
    .DataOut2      (dataOut2),
    .done1         (done1),
    .done2         (done2)  
    );

initial begin
    clk <= 0;
    rst <= 1;
    modEnable <= 1;
    memoryEnable1 <= 0;
    memoryEnable2 <= 0;
    #10 rst <= 0;
    #20 rst <= 1;
    #100000 memoryEnable1 <= 1;
    readWrite1 <= 1; // read
    Address1 <= 15'h0000;

end

always begin
    #5 clk <= ~clk;
end
endmodule
