`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.06.2023 14:41:17
// Design Name: 
// Module Name: output_data_controller
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


module read_output_controller(
    input clock,
    input enable,
    input [7:0]i_address,
    output serial_out
    );

    uart_tx UartTransmitter(
        .clock(clock),
        .enable(1),
        .in_Byte(r_uart_tx_dataIn),
        .o_active(w_uart_tx_active),
        .serial_out(serial_out),
        .o_done(w_uart_tx_done)
    );

    reg r_uart_tx_dataIn;
    wire w_uart_tx_active;
    wire w_uart_tx_done;

    memory Mem(
        .enable(r_mem_enable),
        .readWrite(w_mem_readWrite),
        .dataIn(r_mem_dataIn),
        .address(w_address),
        .dataOut(w_mem_dataOut)
    );


    wire w_mem_readWrite;
    reg [7:0]r_address;
    reg r_mem_enable;
    reg [31:0]r_mem_dataIn = 0;
    wire [31:0]w_mem_dataOut;
    reg [1:0]byte_index;
    //reg [31:0] r_data = 32'b0;

    assign w_mem_readWrite = 1 ;
    assign w_address = i_address;

    always @(posedge clock) begin
        r_mem_dataIn <= w_mem_dataOut;
        if (enable) begin
            r_mem_enable <= 1;
            if(w_uart_tx_done == 1 || byte_index == 0) begin
                r_uart_tx_dataIn <= w_mem_dataOut[8*byte_index +: 8];
                byte_index <= byte_index + 1;  
            end
        else begin
            r_mem_enable <= 0;
        end
        end
    end
    

endmodule
