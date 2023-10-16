`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 02:24:57 PM
// Design Name: 
// Module Name: memoryArbitration
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


module memoryArbitration(
    input clock,
    input reset,
    input moduleEnable,
    input memoryEnable1,
    input memoryEnable2,
    input memoryEnable3,
    input readWrite1,
    input readWrite2,
    input readWrite3,
    input [14:0] Address1,
    input [14:0] Address2,
    input [14:0] Address3,
    input [31:0] Data1,
    input [31:0] Data2,
    input [31:0] Data3,
    output reg [31:0] DataOut1,
    output reg [31:0] DataOut2,
    output reg [31:0] DataOut3,
    output reg done1,
    output reg done2,
    output reg done3    
    );
    
    parameter s_idle = 4'b0000;
    parameter s_one = 4'b0001;
    parameter s_one_wait = 4'b0010;
    parameter s_one_wait2 = 4'b0011;
    parameter s_two = 4'b0100;
    parameter s_two_wait = 4'b0101;
    parameter s_two_wait2 = 4'b0110;
    parameter s_three = 4'b0111;
    parameter s_three_wait = 4'b1000;
    parameter s_three_wait2 = 4'b1001;
    parameter s_clear_memory = 4'b1010;
    parameter s_clear_memory_wait = 4'b1011;

    reg [3:0] state;

    reg mem_enable;
    reg mem_readWrite;
    reg [14:0] mem_address = 0;
    reg [31:0] mem_dataIn;
    wire [31:0] mem_dataOut;

    reg [14:0] clear_address;

    reg  mem_enable_reg1, mem_enable_reg2 ,mem_enable_reg3; 

    sram SRAM(
        .clock      (clock),
        .reset      (reset),
        .enable     (mem_enable), 
        .readWrite  (mem_readWrite),
        .dataIn     (mem_dataIn),
        .address    (mem_address),
        .dataOut    (mem_dataOut)
    );


    always @(posedge clock) begin
        if (!reset) begin
            // reset 
            state <= s_clear_memory;
            mem_enable <= 0;
            clear_address <= mem_address - 1;
            mem_dataIn <= 32'b0;
            mem_enable <= 1;
            mem_readWrite <= 0;

        end else begin
            case(state)
            s_idle : begin
                mem_enable <= 0;
                done1 <= 0;
                done2 <= 0;
                done3 <= 0;
                if(moduleEnable) begin
                    mem_enable_reg1 <= memoryEnable1;
                    mem_enable_reg2 <= memoryEnable2;
                    mem_enable_reg3 <= memoryEnable3;

                    if (memoryEnable1) begin
                        state <= s_one; 
                    end else if (memoryEnable2) begin
                        state <= s_two;
                    end else if (memoryEnable3) begin
                        state <= s_three; 
                    end
                end
            end
            s_one : begin
                mem_enable <= 1;
                mem_readWrite <= readWrite1;
                mem_address <= Address1;
                mem_dataIn <= Data1;
                state <= s_one_wait;
            end
            s_one_wait : begin
                state <= s_one_wait2;
            end
            s_one_wait2 : begin
                DataOut1 <= mem_dataOut;
                done1 <= 1;
                if (mem_enable_reg2) begin
                    state <= s_two;
                end else begin
                    state <= s_idle;
                end
            end
            s_two : begin
                mem_enable <= 1;
                mem_readWrite <= readWrite2;
                mem_address <= Address2;
                mem_dataIn <= Data2;
                state <= s_two_wait;
            end
            s_two_wait : begin
                state <= s_two_wait2;
            end
            s_two_wait2 : begin
                DataOut2 <= mem_dataOut;
                done2 <= 1;
                if (mem_enable_reg3) begin
                    state <= s_three;
                end else begin
                    state <= s_idle;
                end
            end
            s_three : begin
                mem_enable <= 1;
                mem_readWrite <= readWrite3;
                mem_address <= Address3;
                mem_dataIn <= Data3;
                state <= s_three_wait;
            end
            s_three_wait : begin
                state <= s_three_wait2;
            end
            s_three_wait2 : begin
                DataOut3 <= mem_dataOut;
                done3 <= 1;
                state <= s_idle;
            end
            s_clear_memory : begin
                if(mem_address == clear_address) begin
                    state <= s_idle;
                end else begin
                    mem_address <= mem_address + 1;
                    mem_dataIn <= 32'b0;
                    mem_enable <= 1;
                    mem_readWrite <= 0; //write
                    state <= s_clear_memory_wait;
                end    
            end
            s_clear_memory_wait : state <= s_clear_memory;
            default : state <= s_idle;
            endcase
        end
    end
endmodule
