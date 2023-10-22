`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2023 12:22:38
// Design Name: 
// Module Name: top
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

// state maschine that interprets commands

module top(
    input sys_clk,
    input sw_0, // reset
    input RsRx,
    output RsTx,
//    output led_0,
    output led_13,
    output led_14,
    output led_15
    );

    
    wire         mem_readWrite;
    wire [31:0]  mem_dataIn;
    wire         mem_enable;
    wire [14:0]   mem_address;
    wire [31:0] mem_dataOut;

    //registers and wires for memory arbitrator

    reg memJudge_enable = 1;


    wire Judge_mem_enable1;
    wire Judge_mem_enable2;
    wire Judge_mem_enable3;
    wire Judge_mem_readWrite1;
    wire Judge_mem_readWrite2;
    wire Judge_mem_readWrite3;  
    wire [14:0] Judge_Address1;
    wire [14:0] Judge_Address2;
    wire [14:0] Judge_Address3;
    wire [31:0] Judge_data1;
    wire [31:0] Judge_data2;
    wire [31:0] Judge_data3;
    wire [31:0] Judge_DataOut1;
    wire [31:0] Judge_DataOut2;
    wire [31:0] Judge_DataOut3;
    wire Judge_done1;
    wire Judge_done2;
    wire Judge_done3;

    wire        exec_done;
    wire [31:0] exec_data;
    wire        exec_sample;
    wire [2:0]  uart_rx_state;
    wire [2:0]  error_code;

    TopUART TopUART(
       .clk             (sys_clk),
       .rst             (sw_0),
       .serial_in       (RsRx),
       .arbitratorDone  (Judge_done1),
       .dataOutOfMemory (Judge_DataOut1), 
       .serial_out      (RsTx),
       .out_readWrite   (Judge_mem_readWrite1),
       .dataIntoMemory  (Judge_data1),
       .memoryEnable    (Judge_mem_enable1),
       .memoryAddress   (Judge_Address1),
       .uart_rx_state   (uart_rx_state),
       .o_error         (error_code)
    );

    assign led_13 = error_code [0];
    assign led_14 = error_code [1];
    assign led_15 = error_code [2];

    memoryArbitration memJudge(
        .clock         (sys_clk),
        .reset         (sw_0),
        .moduleEnable  (memJudge_enable),
        .memoryEnable1 (Judge_mem_enable1),
        .memoryEnable2 (Judge_mem_enable2),
        .memoryEnable3 (Judge_mem_enable3),
        .readWrite1    (Judge_mem_readWrite1),
        .readWrite2    (Judge_mem_readWrite2),
        .readWrite3    (Judge_mem_readWrite3),
        .Address1      (Judge_Address1),
        .Address2      (Judge_Address2),
        .Address3      (Judge_Address3),
        .Data1         (Judge_data1),
        .Data2         (Judge_data2),
        .Data3         (Judge_data3),
        .DataOut1      (Judge_DataOut1),
        .DataOut2      (Judge_DataOut2),
        .DataOut3      (Judge_DataOut3),
        .done1         (Judge_done1),
        .done2         (Judge_done2),
        .done3         (Judge_done3)
        );

    ringBuffer ringBuffer(
        .clk               (sys_clk),
        .rst               (sw_0),
        .mem_DataOut       (Judge_DataOut2),
        .mem_done          (Judge_done2),
        .exec_done         (exec_done),
        .mem_enable        (Judge_mem_enable2),
        .mem_readWrite     (Judge_mem_readWrite2),
        .mem_address       (Judge_Address2),
        .mem_DataWrite     (Judge_data2),
        .dataToInterpreter (exec_data),
        .exec_sample       (exec_sample)
        );

  
/*    InterpretLED InterpretLED(
        .clock            (sys_clk),
        .reset            (sw_0),
        .sample_command   (exec_sample),
        .command          (exec_data),
        .ledstate         (led_0),
        .next_instruction (exec_done)
        );*/

stackInterpreter StackInterpret(
    .clock               (sys_clk),
    .reset               (sw_0),
    .command_from_buffer (exec_data),
    .command_sample      (exec_sample),
    .memory_data_read    (Judge_DataOut3), 
    .memory_done         (Judge_done3),
    .memory_enable       (Judge_mem_enable3),
    .memory_readWrite    (Judge_mem_readWrite3),
    .memory_address     (Judge_Address3),
    .memory_data_write   (Judge_data3),
    .read_increment      (exec_done)
    
    );


endmodule