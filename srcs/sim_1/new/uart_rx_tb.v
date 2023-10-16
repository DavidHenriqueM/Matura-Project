`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2023 08:46:56 PM
// Design Name: 
// Module Name: uart_rx_tb
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


module uart_rx_tb(

    );

    reg clk;
    wire w_uart;
    wire [7:0]w_uart_rx_out;
    reg [7:0]r_uart_rx_out;
    wire w_uart_rx_done;

    reg r_uart_tx_enable;
    reg [7:0] r_uart_byte;
    wire w_uart_tx_done;
    wire [7:0]o_data;
    wire [2:0]w_state; 
    reg uart_tx_rst = 1;

    uart_rx UartReciever(
    .clock(clk),
    .serial_in(w_uart),
    .o_Byte(w_uart_rx_out),
    .o_done(w_uart_rx_done)
    );

    uart_tx UART_TX(
        .clock(clk),
        .reset(uart_tx_rst),
        .in_Byte(r_uart_byte),
        .enable(r_uart_tx_enable),
        .r_done(w_uart_tx_done),
        .serial_out(w_uart)
        );

    initial begin

        clk <= 0;
        uart_tx_rst <= 1;
        #1 
        uart_tx_rst <= 0;
        #1
        uart_tx_rst <= 1;
        r_uart_byte <= 8'h00;
        r_uart_tx_enable <= 1;
        #8500
        r_uart_byte <= 8'hff;
    end

    always begin
        #5 clk <= ~clk;
    end

    always begin
        $display;
        #1;
    end

    
    always begin
        #100000000 $stop;
    end

endmodule
