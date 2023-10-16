`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2023 09:04:25
// Design Name: 
// Module Name: command_decoder
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


module command_decoder
    #(parameter CLKS_FOR_TIMEOUT = 100000000) // timeout after 1s 10^8 clock cycles
    (
    input clock,
    input uart_in,
    input reset, // active low
    // data_in and in_spoof_done for testing
    //input [7:0] data_in, // no longer neccessary
    //input  in_spoof_done,

    output reg [7:0] o_command,
    output reg [14:0] o_address,
    output reg [31:0] o_data,
    output reg o_done,
    output reg o_readwrite,
    // for testing give state as output
    //output reg [4:0] state, // not needed use scope for testing
    output reg [2:0] o_error,
    output [2:0] uart_rx_state
    );
    
    reg [3:0] state;

    localparam s_idle = 4'b0000;
    localparam s_command_byte = 4'b0001;
    localparam s_interpret_command = 4'b0010;
    localparam s_address_byte = 4'b0011;
    localparam s_address_wait_2 = 4'b0100;
    localparam s_address_2 = 4'b0101;
    localparam s_data_init = 4'b0110;
    localparam s_data_bytes = 4'b0111;
    localparam s_data_wait = 4'b1000;
    localparam s_done = 4'b1001; 
    localparam s_cleanup = 4'b1010;
    localparam s_error_command = 4'b1011;
    localparam s_error_noaddress = 4'b1100;
    localparam s_error_nodone = 4'b1101;


    //reg [3:0] state = 4'b0000; // compiler does wierd things aparently

    reg [7:0] r_Byte = 0;
    reg [3:0] byte_index = 0;
    //reg [31:0] r_data = 0;
    //reg r_command = 0;
    //reg [7:0] r_address = 0;

    reg is_data;

    integer wait_cycle_count = 0;

    wire [7:0]w_uart_rx_out;
    wire w_uart_rx_done;
    

    uart_rx UartReciever(
    .clock(clock),
    .reset(reset),
    .serial_in(uart_in),
    .o_Byte(w_uart_rx_out),
    .o_done(w_uart_rx_done),
    .state(uart_rx_state)
    );
    
    // allow for testing
    reg [7:0] r_inByte = 0;
    reg donesignal = 0;

    always @(posedge clock /* or negedge reset */) // synchronous reset
        begin
            //r_inByte <= data_in; // for testing
            //r_inByte <= w_uart_rx_out; // under standard operation
            //donesignal <= in_spoof_done; // for testing
            //donesignal <= w_uart_rx_done; // under standard operation
            if(!reset) begin
                state <= s_idle;
                o_error <= 0;
                wait_cycle_count <= 0;
                o_done <= 1'b0;
                byte_index <= 0;
                o_command <= 0;
                o_address <= 0;
                o_data <= 0;
                o_readwrite <= 0;
                is_data <= 0;
            end else begin
                case (state)
                    s_idle:
                    begin
                        o_error <= 0;
                        wait_cycle_count <= 0;
                        o_done <= 1'b0;
                        is_data <= 0;
                        byte_index <= 0;
                        state <= s_command_byte;
                    end
                    s_command_byte : begin
                        if (w_uart_rx_done)
                            begin
                                o_command <= w_uart_rx_out;
                                state <= s_interpret_command;
                            end
                    end
                    s_interpret_command : begin
                        if (o_command == 8'h01) begin
                            is_data <= 0;
                            o_readwrite <= 1;
                            state <= s_address_byte;
                        end else if (o_command == 8'h02) begin
                            o_readwrite <= 0;
                            is_data <= 1;
                            state <= s_address_byte;
                        end else begin
                            state <= s_done;
                            o_error <= 3'b001;
                            o_done <= 1'b1;
                        end

                    end
                    s_address_byte : begin
                        if (w_uart_rx_done) begin
                                state <= s_address_2;
                                o_address[7:0] <= w_uart_rx_out;
                                wait_cycle_count <= 0;
                        end else begin
                            if(wait_cycle_count > CLKS_FOR_TIMEOUT) begin
                                state <= s_done;
                                wait_cycle_count <= 0;
                                o_error <= 3'b010;
                                o_done <= 1'b1;
                            end else begin
                                wait_cycle_count <= wait_cycle_count + 1;
                            end
                        end
                    end
                    s_address_2 : begin
                        if (w_uart_rx_done) begin
                                o_address[14:8] <= w_uart_rx_out[6:0];
                                wait_cycle_count <= 0;
                                if (is_data) begin
                                    state <= s_data_bytes;
                                end else begin
                                    state <= s_done;
                                    o_done <= 1'b1;
                                end
                        end else begin
                            if(wait_cycle_count > CLKS_FOR_TIMEOUT) begin
                                state <= s_done;
                                wait_cycle_count <= 0;
                                o_error <= 3'b011;
                                o_done <= 1'b1;
                            end else begin
                                wait_cycle_count <= wait_cycle_count + 1;
                            end
                        end
                    end
                    s_data_bytes : begin
                        if (byte_index < 4) begin
                            if (w_uart_rx_done) begin
                                o_data[8*byte_index +: 8] <= w_uart_rx_out;
                                byte_index <= byte_index + 1;
                                wait_cycle_count <= 0;
                            end else begin
                                if(wait_cycle_count > CLKS_FOR_TIMEOUT) begin
                                    state <= s_done;
                                    wait_cycle_count <= 0;
                                    o_error <= 3'b100 + byte_index;
                                    o_done <= 1'b1;
                                end else begin
                                    wait_cycle_count <= wait_cycle_count + 1;
                                end
                            end
                        end else begin
                            byte_index <= 0;
                            state <= s_done;
                            o_done <= 1'b1;
                        end
                    end
                        /*

                        if (w_uart_rx_done)
                            begin
                                state <= s_command_byte;
                            end

                        else
                            begin
                                state <= s_idle;
                            end
                    end
                    s_command_byte : begin
                            o_command <= w_uart_rx_out;
                            state <= s_address_wait_1;
                        end
                    s_address_wait_1 : begin
                        if (wait_cycle_count > 2) begin //waits two clock cycles
                            state <= s_address_byte;
                            wait_cycle_count <= 0;    
                        end
                        else begin
                            wait_cycle_count <= wait_cycle_count + 1;
                        end
                    end
                    s_address_byte : begin
                            if (w_uart_rx_done) begin                        
                                o_address[7:0] <= w_uart_rx_out;
                                state <= s_address_wait_2;
                                wait_cycle_count <= 0;
                            end
                            else begin
                                if(wait_cycle_count > CLKS_FOR_TIMEOUT) begin
                                    state <= s_error_noaddress;
                                    wait_cycle_count <= 0;
                                    o_error <= 2'b10;
                                    o_done <= 1'b1;
                                end
                                else begin
                                    wait_cycle_count <= wait_cycle_count + 1;
                                end
                            end
                        end
                    s_address_wait_2: //holds for 2 extra clock cycles
                        begin
                            if (wait_cycle_count > 1) begin
                                state <= s_address_2;
                                wait_cycle_count <= 0;    
                            end
                            else begin
                                wait_cycle_count <= wait_cycle_count + 1;
                            end
                        end
                    s_address_2:
                        begin
                           if (w_uart_rx_done) begin
                               o_address[14:8] <= w_uart_rx_out[6:0];
                                if (o_command == 8'h01) begin
                                    o_done <= 1'b1;
                                    o_readwrite <= 1;
                                    state <= s_done;
                                end
                                if (o_command == 8'h00) begin
                                    o_readwrite <= 0;
                                    state <= s_data_init;
                                end
                                if (o_command != 8'h01 && o_command != 8'h00) begin
                                    state <= s_error_command;
                                    o_error <= 2'b01;
                                    o_done <= 1'b1;
                                end
                            end else begin
                                if(wait_cycle_count > CLKS_FOR_TIMEOUT) begin
                                    state <= s_error_noaddress;
                                    wait_cycle_count <= 0;
                                    o_error <= 2'b10;
                                    o_done <= 1'b1;
                                end
                                else begin
                                    wait_cycle_count <= wait_cycle_count + 1;
                                end
                            end 
                        end
                    s_data_init:
                        begin
                            if (wait_cycle_count > 0) begin
                                state <= s_data_wait;
                                wait_cycle_count <= 0;    
                            end
                            else begin
                                wait_cycle_count <= wait_cycle_count + 1;
                            end
                        end
                    s_data_bytes:
                        begin
                            //if(w_uart_rx_done) begin
                                o_data[8*byte_index +: 8] <= w_uart_rx_out;
                                state <= s_data_wait;
                                wait_cycle_count <= 0;
                            //end
                            
                    
                        end
                    s_data_wait:
                        begin
                            if (w_uart_rx_done) begin
                                if(byte_index < 3) begin
                                    byte_index <= byte_index + 1;
                                    state <= s_data_bytes;
                                end
                                else begin
                                    o_done <= 1'b1;
                                    state <= s_done;
                                end
                            end
                            else begin
                                if(wait_cycle_count > CLKS_FOR_TIMEOUT) begin
                                    state <= s_error_nodone;
                                    o_error <= 2'b11;
                                    wait_cycle_count <= 0;
                                    o_done <= 1'b1; 
                                end
                                else begin
                                    wait_cycle_count <= wait_cycle_count + 1;
                                end
                            end
                        end
*/
                  s_done :
                        begin
                            o_done <= 0;
                            state <= s_cleanup;
                        end
                    s_cleanup : begin
                            state <= s_idle;
                            o_done <= 1'b0;
                            o_error <= 0;
                            wait_cycle_count <= 0;
                        end 
/*
                    s_error_command:
                        begin
                            o_done <= 0;
                            o_error <= 2'b01;
                            state <= s_cleanup;
                        end
                    s_error_nodone:
                        begin
                            o_done <= 0;
                            o_error <= 2'b11;
                            state <= s_cleanup;
                        end
                    s_error_noaddress:
                        begin
                            o_done <= 0;
                            o_error <= 2'b10;
                            state <=  s_cleanup;
                        end*/

                    default : begin
                        state <= s_idle; 
                    end    
                endcase
            end
        end


endmodule