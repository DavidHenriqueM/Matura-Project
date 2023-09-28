`timescale 1ns / 1ps

// 256 x 32 memory : 

module sram(
    input             clock, 
    input             reset,
    input             enable,
    input             readWrite,
    input [31:0]      dataIn,
    input [14:0]      address,
    output reg [31:0] dataOut
    );

    parameter ADDRESS_WIDTH = 15;
    parameter DATA_WIDTH = 32;
    parameter DEPTH = 1 << ADDRESS_WIDTH; // 2^15 = 32768 words

    // Internal memory array
    reg [31:0] memory [0:DEPTH-1];

    // Read operation
    always @(posedge clock /* =or negedge reset*/) begin
        if (!reset) begin // synchronous reset
            dataOut <= 32'b0;
        end else begin
            if (enable) begin
                if (address < DEPTH) begin
                    dataOut <= memory[address];
                end
            // Write operation
                if (!readWrite && (address < DEPTH)) begin
                    memory[address] <= dataIn;
                end
            end else begin
                dataOut <= 32'b0;
            end
        end
    end

endmodule
