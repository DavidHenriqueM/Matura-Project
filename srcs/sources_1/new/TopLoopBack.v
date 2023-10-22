`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2023 01:54:58 PM
// Design Name: 
// Module Name: TopLoopBack
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


module TopLoopBack(
    input sys_clk,
    input sw_0,
    input RsRx,
    output RsTx
    );
    
    parameter s_idle = 0;
    parameter s_wait_count = 1;
    parameter s_transmit = 2;
    parameter s_transmit2 = 3;

    parameter CHR_LENGTH = 8680; // 10 * CLKS_PER_BAUD
    
    integer cycle_count;
    reg [7:0] done_count;
    
    reg uart_tx_enable = 0;
    wire [7:0] w_uart_rx_out;
    reg  [7:0] uart_tx_in = 0;

    wire w_tx_done;

    reg [3:0] state;

    uart_tx UART_md(
    .clock(sys_clk),
    .reset(sw_0),
    .enable(uart_tx_enable),
    .in_Byte(uart_tx_in),
    .r_done(w_tx_done),
    .serial_out(RsTx)
    );

    wire w_rx_done;

    uart_rx UartReciever(
    .clock(sys_clk),
    .reset(sw_0),
    .serial_in(RsRx),
    .o_Byte(w_uart_rx_out),
    .o_done(w_rx_done)
    );

    always @(posedge sys_clk) begin
        if(!sw_0) begin
            uart_tx_enable <= 0;
            uart_tx_in <= 0;
            state <= s_idle;
            cycle_count <= 0;
            done_count <= 0;
        end else begin
            case(state)
                s_idle : begin
                    if(RsRx == 1'b0) begin // start bit detection
                        state <= s_wait_count;
                    end
                end
                s_wait_count : begin
                    if (cycle_count < (CHR_LENGTH - 1)) begin
                        if (w_rx_done) begin
                           done_count <= done_count + 1; 
                        end
                        cycle_count <= cycle_count + 1;
                    end else begin
                        state <= s_transmit;
                    end
                end
                s_transmit : begin
                    uart_tx_enable <= 1;
                    uart_tx_in <= w_uart_rx_out;
                    state <= s_transmit2;
                end
                s_transmit2 : begin
                    uart_tx_enable <= 0;
                end
                default : begin
                    state <= s_idle;
                end
            endcase 
        end
    end
    
endmodule
