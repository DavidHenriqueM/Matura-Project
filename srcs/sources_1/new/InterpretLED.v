`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2023 02:12:43 PM
// Design Name: 
// Module Name: InterpretLED
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


module InterpretLED(
    input clock,
    input reset,
    input sample_command,
    input [31:0] command, 
    output reg ledstate,
    output reg next_instruction
    );
    parameter s_idle              = 0;
    parameter s_interpret_command = 1;
    
    reg state = 0;
    reg [31:0] register_command = 0;

    always @(posedge clock) begin
        if (!reset) begin
            // reset
            ledstate <= 0;
            register_command <= 0;
        end else begin
            case(state)
                s_idle : begin
                    next_instruction <= 0;
                    if(sample_command) begin
                        state <= s_interpret_command;
                        register_command <= command;
                    end else begin
                        register_command <= 0;
                    end
                end

                s_interpret_command : begin
                    if (register_command == 32'h0001) begin
                        ledstate <= 1;
                    end else if (register_command == 32'h0002) begin
                        ledstate <= 0;
                    end
                    next_instruction <= 1;
                    state <= s_idle;
                end
            endcase
        end
    end
    
endmodule
