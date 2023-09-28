`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2023 12:21:37
// Design Name: 
// Module Name: uart_rx
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2023 12:21:37
// Design Name: 
// Module Name: uart_rx
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


module uart_rx
    #(parameter CLKS_PER_BIT = 20)
    (
    input clock,
    input serial_in,
    output [7:0] o_Byte,
    output o_done
    );
    
    // State indication
    localparam s_idle = 3'b000; // we get a synthesis error if we do not use a localparam 
    localparam s_start_bit = 3'b001;
    localparam s_data_bits = 3'b010;
    localparam s_stop_bit = 3'b011;
    localparam s_cleanup = 3'b111;
    
    reg data_R = 1'b1;
    reg data = 1'b1;
    
    reg[2:0] state = 0;
    reg[7:0] clock_count = 0;
    reg[2:0] bit_index = 0;
    reg[7:0] r_Byte = 0;
    reg r_done = 0;

    // Double register the incoming data
    
    always @ (posedge clock)
        begin
            data_R <= serial_in;
            data <= data_R;
        end
        
    always @(posedge clock)
        begin
            case(state)
                s_idle:
                    begin
                        r_done <= 1'b0;
                        clock_count <= 0;
                        bit_index <= 0;
                        
                        if(data == 1'b0) // start bit detection
                            state <= s_start_bit;
                        else
                            state <= s_idle;
                    end
                s_start_bit:
                    begin
                        if (clock_count == (CLKS_PER_BIT-1)/2) // check the middle to ensure it's still low
                            begin
                                 if(data == 1'b0)
                                    begin
                                        clock_count <= 0;
                                        state <= s_data_bits;
                                    end
                                 else
                                    state <= s_idle;
                             end
                         else
                            begin
                                clock_count <= clock_count +1;
                                state <= s_start_bit;
                            end
                    end
                    
                 s_data_bits :
                    begin
                        if(clock_count < CLKS_PER_BIT-1)
                            begin
                                clock_count <= clock_count + 1;
                                state <= s_data_bits;
                            end
                        else
                            begin
                                clock_count <= 0;
                                r_Byte[bit_index] <= data;
                            if (bit_index < 7)
                                begin
                                    bit_index <= bit_index + 1;
                                    state <= s_data_bits;
                                end
                            else
                                begin
                                    bit_index <= 0;
                                    state <= s_stop_bit;
                                end
                            end
                        end 
                   
                s_stop_bit :
                    begin
                        // wait for stop bit to finish
                        if(clock_count < CLKS_PER_BIT-1)
                            begin
                                clock_count <= clock_count + 1;
                                state <= s_stop_bit;
                            end
                        else
                            begin
                                r_done <= 1'b1;
                                clock_count <= 0;
                                state <= s_cleanup;
                            end
                        end
                    s_cleanup:
                        begin
                            state <=  s_idle;
                            r_done <= 1'b0;
                        end
                    
                    default :
                        state <= s_idle;
                endcase
           end
           
       assign o_done = r_done;
       assign o_Byte = r_Byte;     
                   
                        
endmodule