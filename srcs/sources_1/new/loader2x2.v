`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 09:05:37 AM
// Design Name: 
// Module Name: loader2x2
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


module loader2x2
    #(parameter MATRIX_LENGTH = 4)

    (
    input clock,
    input reset,
    input enable,
    input memory_done,
    input [31:0] word_from_memory,
    input [14:0] start_address,
    input next_matrix_ready,
    output reg next_matrix,
    output reg memory_enable,
    output reg [14:0] memory_address,
    output reg [31:0] word_to_memory,
    output reg done,
    output reg readWrite
    );


    localparam s_idle = 0;
    localparam s_fetch_mem = 1;
    localparam s_load_value_to_matrix = 2;
    localparam s_wait_for_next_matrix = 3;
    localparam s_enable_exec = 4;
    localparam s_wait_for_exec_done = 5;
    localparam s_memory_give_c = 6;
    localparam s_load_matrix_c = 7;
    localparam s_memory_wait_c = 8;

    reg [3:0] state = 0;

    reg [3:0] matrix_index = 0;
    reg A_or_B; // 0 for A, 1 for B

    
    reg [127:0] matrix_to_exec_A;
    reg [127:0] matrix_to_exec_B;
    wire [127:0] matrix_to_mem_C;
    reg         matrix_enable;

    wire matrix_mult_done;

    

    matrix_mult matrix_mult2x2 (
        .clock  (clock),
        .reset  (reset),
        .enable (matrix_enable),
        .A      (matrix_to_exec_A),
        .B      (matrix_to_exec_B),
        .C      (matrix_to_mem_C),
        .done   (matrix_mult_done)
        );

    always @(posedge clock) begin
        if (!reset) begin
            matrix_to_exec_A <= 0;
            matrix_to_exec_B <= 0;
            next_matrix <= 0;
            matrix_index <= 0;
            A_or_B <= 0;
            done <= 0;
            state <= s_idle;
        end else begin
            case(state)
                s_idle : begin
                    done <= 0;
                    matrix_to_exec_A <= 0;
                    next_matrix <= 0;  
                    matrix_to_exec_B <= 0;
                    matrix_index <= 0;
                    A_or_B <= 0;
                    if (enable) begin

                        state <= s_fetch_mem;
                    end
                end
                s_fetch_mem : begin
                    readWrite <= 1; 
                    memory_address <= start_address + matrix_index;
                    memory_enable <= 1;

                    state <= s_load_value_to_matrix;
                end
                s_load_value_to_matrix : begin
                    memory_enable <= 0; 
                    if (memory_done) begin
                        if (matrix_index < 4) begin
                            if (!A_or_B) begin // matrix A
                                matrix_to_exec_A [matrix_index*32 +: 32] <= word_from_memory;
                            end else begin // matrix B
                                matrix_to_exec_B [matrix_index*32 +: 32] <= word_from_memory;
                            end
                            matrix_index <= matrix_index + 1;

                            state <= s_fetch_mem;
                        end else begin
                            matrix_index <= 0;
                            if (A_or_B) begin // matrix B done

                                state <= s_enable_exec;
                            end else begin
                                next_matrix <= 1;
                                A_or_B <= 1;

                                state <= s_wait_for_next_matrix;
                            end
                        end
                    end
                end
                s_wait_for_next_matrix : begin
                    next_matrix <= 1;
                    if (next_matrix_ready) begin
                        state <= s_fetch_mem;
                    end
                end
                s_enable_exec : begin
                    matrix_enable <= 1;
                    state <= s_wait_for_exec_done;
                end
                s_wait_for_exec_done : begin
                    if (matrix_mult_done) begin
                        matrix_enable <= 0;
                        next_matrix <= 1;
                        state <= s_load_matrix_c;
                    end
                end
            
                s_load_matrix_c : begin
                    next_matrix <= 1;
                    if (next_matrix_ready) begin
                       state <= s_memory_give_c; 
                    end 
                end
                s_memory_give_c : begin
                    memory_enable <= 1;
                    readWrite <= 0;
                    memory_address <= start_address + matrix_index;
                    word_to_memory <= matrix_to_mem_C [matrix_index * 32 +: 32];
                    state <= s_memory_wait_c;
                end

                s_memory_wait_c : begin
                    memory_enable <= 0;
                    if (memory_done) begin
                        if (matrix_index < 4) begin
                            state <= s_memory_give_c;
                        end
                    end else begin
                        matrix_index <= 0;
                        done <= 1;
                        state <= s_idle;
                    end
                end

                default : begin
                    state <= s_idle;
                end
            endcase
        end
    end

    
endmodule
