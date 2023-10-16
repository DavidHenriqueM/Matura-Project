`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2023 09:31:22 AM
// Design Name: 
// Module Name: ringBuffer_tb
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


module ringBuffer_tb;

    reg clk;
    reg rst;
    reg [31:0] mem_DataOut;
    reg mem_done;
    reg exec_done;
    wire mem_enable;
    wire mem_readWrite;
    wire [14:0] mem_address;
    wire [31:0] mem_DataWrite;
    wire [31:0] dataToInterpreter;
    wire exec_sample;

    // Instantiate the ringBuffer module
    ringBuffer uut_ringBuffer (
        .clk(clk),
        .rst(rst),
        .mem_DataOut(mem_DataOut),
        .mem_done(mem_done),
        .exec_done(exec_done),
        .mem_enable(mem_enable),
        .mem_readWrite(mem_readWrite),
        .mem_address(mem_address),
        .mem_DataWrite(mem_DataWrite),
        .dataToInterpreter(dataToInterpreter),
        .exec_sample(exec_sample)
    );


    reg moduleEnable;
    reg memoryEnable1;
    reg memoryEnable2;
    reg memoryEnable3;
    reg readWrite1;
    reg readWrite2;
    reg readWrite3;
    reg [14:0] Address1;
    reg [14:0] Address2;
    reg [14:0] Address3;
    reg [31:0] Data1;
    reg [31:0] Data2;
    reg [31:0] Data3;

    wire [31:0] DataOut1;
    wire [31:0] DataOut2;
    wire [31:0] DataOut3;
    wire done1;
    wire done2;
    wire done3;

    // Instantiate the memoryArbitration module
    memoryArbitration memoryArbitration (
        .clock(clk),
        .reset(rst),
        .moduleEnable(moduleEnable),
        .memoryEnable1(memoryEnable1),
        .memoryEnable2(memoryEnable2),
        .memoryEnable3(memoryEnable3),
        .readWrite1(readWrite1),
        .readWrite2(readWrite2),
        .readWrite3(readWrite3),
        .Address1(Address1),
        .Address2(Address2),
        .Address3(Address3),
        .Data1(Data1),
        .Data2(Data2),
        .Data3(Data3),
        .DataOut1(DataOut1),
        .DataOut2(DataOut2),
        .DataOut3(DataOut3),
        .done1(done1),
        .done2(done2),
        .done3(done3)
    );


    
    // Clock generation
    always begin
        clk = ~clk;
        #5; // 10ns clock period
    end

    // register assingments for interconnecting the two modules
    always @(posedge clk) begin
        mem_DataOut <= DataOut3;
        mem_done <= done3;
        readWrite3 <= mem_readWrite;
        Address3 <= mem_address;
        Data3 <= mem_DataWrite;
        memoryEnable3 <= mem_enable;

    end

    // Initialize signals
    initial begin
        clk = 0;
        rst = 1;
        mem_DataOut = 0;
        mem_done = 0;
        exec_done = 0;

        #10
        rst = 0;
        #10
        rst = 1;

        #655400

        moduleEnable = 1;
        memoryEnable1 = 1;
        readWrite1 = 0;
        Address1 = 15'h0003;
        Data1 = 32'h0000000a;

        #100
        memoryEnable1 = 0;

        #10
        memoryEnable1 = 1;
        readWrite1 = 0;
        Address1 = 15'h0004;
        Data1 = 32'h0000000b;

        #100
        memoryEnable1 = 0;

        #10
        memoryEnable1 = 1;
        readWrite1 = 0;
        Address1 = 15'h0002;
        Data1 = 32'h00000002;

        #100
        memoryEnable1 = 0;

        #500
        exec_done = 1;
        #10
        exec_done = 0;
        #500
        exec_done = 1;
        #10
        exec_done = 0;

        
    end

    // Display some signals
    always @(posedge clk) begin
        $display("Time=%t, mem_enable=%b, mem_readWrite=%b, mem_address=%h, mem_DataWrite=%h, dataToInterpreter=%h, exec_sample=%b",
            $time, mem_enable, mem_readWrite, mem_address, mem_DataWrite, dataToInterpreter, exec_sample);
    end

endmodule