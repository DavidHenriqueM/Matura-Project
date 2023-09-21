`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2023 10:48:03 AM
// Design Name: 
// Module Name: word_to_byte_tx
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


module word_to_byte_tx(

    input clock,
    input enable,
    input reset,
    input i_mode_select, //selects mode either bypass 0 or word 1
    input [31:0] i_word,
    input [7:0] i_byte,
    output o_serial,
    //output reg [7:0] r_data,
    output reg o_done //,
    //output reg [2:0] main_state // testing use scope 
    );
    //reg [2:0] main_state = 3'b000;
    
    reg [2:0] main_state = 0;
    reg uart_tx_enable = 0;
    reg [7:0] r_byte = 0;

    parameter s_idle = 3'b000;
    parameter s_data = 3'b001;
    parameter s_done = 3'b010;
    parameter s_wait = 3'b011;
    parameter s_done_trans = 3'b100;
    parameter s_cleanup = 3'b101;

    reg [7:0] r_data = 0;
    
    reg [1:0] tx_cycle_count = 0;
    reg [31:0] r_word = 32'h0;
    
    reg r_mode_select;
    

    wire w_done;
    wire w_serial;


    uart_tx UART_md(
        .clock(clock),
        .reset(reset),
        .enable(uart_tx_enable),
        .in_Byte(r_data),
        .r_done(w_done),
        .serial_out(w_serial)
        );
    
    
    assign o_serial = w_serial;
    
    always @ (posedge clock) begin
        if (!reset) begin
            main_state <= s_idle;
        end else begin
            case(main_state)
                s_idle:
                    begin
                        r_data <= 8'h0;
                        uart_tx_enable <= 0;
                        o_done <= 0;
                        tx_cycle_count <= 0;
                        r_word <= i_word;
                        r_byte <= i_byte;
                        r_mode_select <= i_mode_select;
                        if (enable) begin
                            main_state <= s_data;
                        end
                    end

                s_data:
                    begin
                        uart_tx_enable <= 1;
                        if (r_mode_select) begin
                            r_data <= r_word[8*tx_cycle_count +: 8];
                            main_state <= s_wait;
                        end
                        else begin
                            r_data <= r_byte;
                            if (w_done) begin
                                main_state <= s_done;
                            end
                            else begin
                                main_state <= s_data;
                            end
                        end
                    end
                s_wait:
                    begin
                        if (w_done) begin
                            main_state <= s_done_trans;
                        end
                    end
                s_done_trans:
                    begin
                        if (!w_done) begin
                            if (tx_cycle_count < 3) begin
                                tx_cycle_count <= tx_cycle_count + 1;
                                main_state <= s_data;
                            end
                            else begin
                                main_state <= s_done;
                                uart_tx_enable <= 0;
                            end
                        end
                    end
                s_done:
                    begin
                        o_done <= 1;
                        main_state <= s_cleanup;
                        uart_tx_enable <= 0;
                    end
                s_cleanup:
                    begin
                        o_done <= 1;
                        main_state <= s_idle;
                    end
                default:
                    begin
                        main_state <= s_idle;
                    end
            endcase
        end
    end

endmodule