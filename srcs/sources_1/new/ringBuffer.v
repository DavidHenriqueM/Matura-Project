`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 09:23:01 AM
// Design Name: 
// Module Name: ringBuffer
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


module ringBuffer(
    input             clk,
    input             rst,
    input      [31:0] mem_DataOut,
    input             mem_done,
    input             exec_done,
    //input             is_reset,
    output reg        mem_enable,
    output reg        mem_readWrite,
    output reg [14:0] mem_address,
    output reg [31:0] mem_DataWrite,
    output reg [31:0] dataToInterpreter,
    output reg        exec_sample
    );
    
    parameter s_idle                     = 0;
    parameter s_check_write_pointer      = 1;
    parameter s_check_write_pointer_wait = 2;
    parameter s_check_readpointer        = 3;
    parameter s_wait_for_mem_write       = 4;
    parameter s_give_exec_data           = 5;
    parameter s_wait_exec_read           = 6;
    parameter s_wait_for_exec            = 7;
    parameter s_update_Pointer           = 8;
    parameter s_wait_for_update          = 9;



    reg [3:0] readPointer  = 0;
    reg [3:0] writePointer = 0;
    
    integer cycle_count = 0;

    reg [3:0] state = 0;


    always @(posedge clk) begin
        if (!rst) begin
            // synchronous reset 
            mem_enable <= 0;    
            readPointer <= 0;
            dataToInterpreter <= 32'b0;
            cycle_count <= 0;
            exec_sample <= 0;
            mem_readWrite <= 1;
        end
        else begin
            case(state)
                s_idle : begin
                    state <= s_check_write_pointer;
                end
                s_check_write_pointer : begin
                    mem_enable <= 1;
                    mem_address <= 15'h0002;
                    mem_readWrite <= 1; //read
                    state <= s_check_write_pointer_wait;
                end
                s_check_write_pointer_wait : begin
                    mem_enable <= 0;
                    if (cycle_count < 10) begin // int the case that memory arbitration is not available ie in reset
                        if (mem_done) begin
                            writePointer <= mem_DataOut;
                            cycle_count <= 0;
                            state <= s_check_readpointer;
                        end else begin
                            cycle_count <= cycle_count + 1;
                        end
                    end else begin
                        state <= s_idle;
                        cycle_count <= 0;
                    end
                end
                s_check_readpointer : begin
                    if (readPointer != writePointer) begin // buffer isn't empty
                        state <= s_wait_for_mem_write;
                        mem_enable <= 1;
                        mem_address <= readPointer + 3 ; // take account 3 occuppied memory slots 0000 0001 (readpointer) 0002 (writepointer)
                    end else begin
                        state <= s_idle; // idle if buffer is empty
                    end
                end
                s_wait_for_mem_write : begin
                mem_enable <= 0;
                    if (mem_done) begin
                        state <= s_give_exec_data; // read data in read pointer slot
                        mem_enable <= 0;
                    end
                end
                s_give_exec_data : begin
                    mem_enable <= 1;
                    mem_readWrite <= 1; // read
                    mem_address <= readPointer + 3;
                    state <= s_wait_exec_read;
                end
                s_wait_exec_read : begin
                mem_enable <= 0;
                    if (mem_done) begin
                        dataToInterpreter <= mem_DataOut;
                        exec_sample <= 1;
                        state <= s_wait_for_exec;
                    end
                end
                s_wait_for_exec : begin
                exec_sample <= 0;
                    if (exec_done) begin
                        readPointer <= readPointer + 1;
                        state <= s_update_Pointer;
                    end
                end
                s_update_Pointer : begin
                    mem_enable <= 1;
                    mem_address <= 15'h0001;
                    mem_readWrite <= 0; // write
                    mem_DataWrite <= readPointer;
                    state <= s_wait_for_update;
                end
                s_wait_for_update : begin
                mem_enable <= 0;
                    if (mem_done) begin
                        state <= s_idle;
                    end
                end
            endcase
        end
    end
endmodule
