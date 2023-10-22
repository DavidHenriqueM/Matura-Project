`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2023 10:26:25 AM
// Design Name: 
// Module Name: stackInterpreter
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


module stackInterpreter(
    input             clock,
    input             reset,
    //input             enable,
    input      [31:0] command_from_buffer,
    input             command_sample,
    input      [31:0] memory_data_read,
    input             memory_done,
    output            memory_enable,
    output            memory_readWrite,
    output     [14:0] memory_address,
    output     [31:0] memory_data_write,
    output reg        read_increment
    );
    
    wire exec_done;
    wire [14:0] exec_output_size;
    wire [31:0] word_from_exec;
    
    reg [14:0] sizeA;
    reg [14:0] sizeB;    

    reg [31:0] word_to_exec;
    reg        exec_sample;


    parameter s_idle = 0;
    parameter s_load_reg = 1;
    parameter s_interpret = 2;
    parameter s_give_output_A = 3;
    parameter s_wait_for_C = 4;
    parameter s_wait_for_done = 5;
    // parameter s_memory_waitA = 6;
    // parameter s_read_acc_A = 7;
    // parameter s_memory_fetchB = 8;
    // parameter s_memory_waitB = 9;
    // parameter s_read_acc_B = 10;
    // parameter s_wait_for_exec = 11;
    // parameter s_wait_for_exec_allocation = 12;

    reg [4:0] state = 0;

    reg [31:0] registered_command [0:3];
    reg [2:0] command_index = 0;

    //reg [1:0] matrix_command [0:3];
    reg [14:0] coressponding_addr [0:2];
    //reg [14:0] coressponding_size [0:3];

    reg [14:0] start_address;
    reg next_matrix_ready;
    wire next_matrix;
    wire loader_done;

    // integer matrix_A_length;
    // integer matrix_B_length;
    // integer matrix_C_length;

    reg loader_enable = 0;

    loader2x2 loader2x2 (
        .clock             (clock),
        .reset             (reset),
        .enable            (loader_enable),
        .memory_done       (memory_done),
        .word_from_memory  (memory_data_read),
        .start_address     (start_address),
        .next_matrix_ready (next_matrix_ready),
        .next_matrix       (next_matrix),
        .memory_enable     (memory_enable),
        .memory_address    (memory_address),
        .word_to_memory    (memory_data_write),
        .done              (loader_done),
        .readWrite         (memory_readWrite)
        );

    //integer matrix_interator = 0;


    // load commmands first
    // load corresponding module with information

    always @(posedge clock) begin
        if (!reset) begin
            // reset
            read_increment <= 0;
            command_index <= 0;
            state <= s_idle;
        end
        else begin
            case(state)
            s_idle : begin
                //matrix_interator <= 0;
                command_index <= 0;
                if (command_sample) begin
                    state <= s_load_reg;
                    registered_command[command_index] <= command_from_buffer;
                    command_index <= 1;
                    read_increment <= 1;
                end
            end
            s_load_reg : begin
                read_increment <= 0;
                if(command_index < 4) begin // loads 4 commands 3 matricies and 1 operation // the operation is implicit not good
                    if(command_sample) begin
                        registered_command [command_index] <= command_from_buffer;
                        command_index <= command_index + 1;
                        read_increment <= 1;
                    end
                end else begin
                    state <= s_interpret;
                    command_index <= 0;
                end
            end
            s_interpret : begin 
                if (command_index < 4) begin
                    //matrix_command [command_index] <= registered_command [command_index][1:0];
                    coressponding_addr [command_index] <= registered_command [command_index] [14:0];
                    command_index <= command_index + 1;
                end else begin
                    state <= s_give_output_A;
                    command_index <= 0;
                end
            end

            s_give_output_A : begin
                loader_enable <= 1;
                start_address <= coressponding_addr[0];
                if (next_matrix) begin
                    start_address <= coressponding_addr[1];
                    next_matrix_ready <= 1;
                    state <= s_wait_for_C;
                end
            end

            s_wait_for_C : begin
            next_matrix_ready <= 0;
                if (next_matrix) begin
                    next_matrix_ready <= 1;
                    start_address <= coressponding_addr[2];
                    state <= s_wait_for_done;
                end
            end

            s_wait_for_done : begin
                if (loader_done) begin
                    read_increment <= 1;
                    state <= s_idle;
                end
            end

            default : state <= s_idle;
            endcase
        end
    end

/*
    always @(posedge clock) begin
        if (reset) begin
            // reset
            
        end
        else if (enable) begin
            case(state)
                s_idle : begin
                    command_index <= 0;
                    matrix_interator <= 0;
                    if (enable && command_sample) begin
                        state <= s_load_reg;
                        registered_command[command_index] <= command_from_buffer;
                        command_index <= command_index + 1;
                        
                    end
                end
                s_load_reg : begin
                    if(command_index < 3) begin
                        if(command_sample) begin
                            registered_command [command_index] <= command_from_buffer;
                            command_index <= command_index + 1;
                        end
                    end else begin
                        state <= s_interpret;
                        command_index <= 0;
                    end
                end 
                s_interpret : begin 
                    if (command_index < 3) begin
                        matrix_command [command_index] <= registered_command [command_index][1:0];
                        coressponding_addr [command_index] <= registered_command [command_index] [16:2];
                        coressponding_size [command_index] <= registered_command [command_index] [31:17];
                        command_index <= command_index + 1;
                    end else begin
                        state <= s_give_output;
                        command_index <= 0;
                    end
                end
                s_give_output : begin
                    sizeA <= coressponding_size [0]; // size stores x in bits [6:0] and y in [13:7]
                    sizeB <= coressponding_size [1];
                    state <= s_give_size;
                end
                s_give_size : begin
                    matrix_A_length <= sizeA [6:0] * sizeA [13:7];
                    matrix_B_length <= sizeB [6:0] * sizeB [13:7];
                    matrix_interator <= 0;
                    state <= s_memory_fetchA;
                end
                s_memory_fetchA : begin
                    memory_enable <= 1;
                    memory_readWrite <= 1; // read
                    memory_address <= coressponding_addr[0] + matrix_interator;
                    state <= s_memory_waitA;
                end
                s_memory_waitA : begin
                    if (memory_done) begin
                        word_to_exec <= memory_data_read;
                        state <= s_read_acc_A;
                    end
                end
                s_read_acc_A : begin
                    memory_enable <= 0;
                    if (exec_done) begin
                        if(matrix_interator < matrix_A_length) begin
                            matrix_interator <= matrix_interator + 1;
                        end else begin
                            matrix_interator <= 0;
                            state <= s_memory_fetchB;

                        end
                    end
                end
                s_memory_fetchB : begin
                    memory_enable <= 1;
                    memory_readWrite <= 1; // read
                    memory_address <= coressponding_addr[1] + matrix_interator;
                    state <= s_memory_waitB;
                end
                s_memory_waitB : begin
                    if (memory_done) begin
                        word_to_exec <= memory_data_read;
                        state <= s_read_acc_B;
                    end
                end
                s_read_acc_B : begin
                    memory_enable <= 0;
                    if (exec_done) begin
                        if(matrix_interator < matrix_A_length) begin
                            matrix_interator <= matrix_interator + 1;
                            matrix_C_length <= exec_output_size[6:0] * exec_output_size[13:7];
                        end else begin
                            matrix_interator <= 0;
                            state <= s_wait_for_exec;
                        end
                    end
                end
                s_wait_for_exec : begin
                    if (exec_done) begin
                        if (matrix_interator < matrix_C_length)
                        memory_enable <= 1;
                        memory_readWrite <= 0; //write
                        memory_address <= coressponding_addr [2] + matrix_interator; 
                        memory_data_write <= word_from_exec;                      
                        state <= s_wait_for_exec_allocation;
                    end else begin
                        state <= s_idle;
                    end
                end // there is no way in hell this code actually works rn
                s_wait_for_exec_allocation : begin
                    if (memory_done) begin
                        matrix_interator <= matrix_interator + 1;
                    end
                end
            endcase
        end
    end*/

endmodule
