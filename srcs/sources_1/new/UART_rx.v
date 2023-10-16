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
    #(parameter CLKS_PER_BIT = 868)

    (
    input clock,
    input reset,
    input serial_in,
    output [7:0] o_Byte,
    output o_done,
    output reg [2:0] state
    );
    
    // State indication
    localparam s_idle = 3'b000; // we get a synthesis error if we do not use a localparam 
    localparam s_start_bit = 3'b001;
    localparam s_data_bits = 3'b010;
    localparam s_stop_bit = 3'b011;
    localparam s_cleanup = 3'b111;
    
    //reg data_R = 1;
    reg data = 1'b1;
    
    //reg[2:0] state = 0;
    integer clock_count = 0;
    integer data_value = 0;
    reg[2:0] bit_index = 0;
    reg[7:0] r_Byte = 0;
    reg r_done = 0;

    
    
    
    always @(posedge clock) begin
        if (!reset) begin
            data <= 1'b1;
            r_done <= 0;
            r_Byte <= 8'b0;
            state <= s_idle;
        end else begin
            //register the incoming data
            data <= serial_in;

            case(state)
                s_idle : begin

                    r_done <= 1'b0;
                    clock_count <= 0;
                    data_value <= 0;
                    bit_index <= 0;
            
                    if(data == 1'b0) begin // start bit detection
                        state <= s_start_bit;
                    end else begin
                        state <= s_idle;
                    end
                end
                s_start_bit : begin
                    if (clock_count > (CLKS_PER_BIT - 1)) begin
                        // state transition
                        state <= s_data_bits;
                        clock_count <= 0;                            
                    // end else if (clock_count == (CLKS_PER_BIT) / 2) begin
                    //     // sample
                    //     if (data != 1'b0) begin
                    //         state <= s_idle;
                    //     end
                    //     clock_count <= clock_count +1;
                    end else begin
                        // increment counter
                        clock_count <= clock_count +1;
                    end
                end
                    
                 s_data_bits :
                    begin
                        if (clock_count > (CLKS_PER_BIT - 1)) begin
                            // state transition
                            if (bit_index == 7) begin
                                state <= s_stop_bit;
                                bit_index <= 0; 
                            end else begin
                                bit_index <= bit_index + 1;
                            end
                            clock_count <= 0;
                            if (data_value > (CLKS_PER_BIT/2)) begin
                                r_Byte[bit_index] <= 1'b1;
                            end else begin
                                r_Byte[bit_index] <= 1'b0;
                            end
                            data_value <= 0;        
                        end else begin
                            // increment counter
                            clock_count <= clock_count + 1;
                            if (data) begin
                                data_value <= data_value + 1;
                            end
                        end
                    end
                   
                s_stop_bit : begin
                    // wait for stop bit to finish
                    clock_count <= clock_count + 1;

                    if ((clock_count > (CLKS_PER_BIT/2) && !data) ||
                        (clock_count > (CLKS_PER_BIT -1))) begin
                        r_done <= 1'b1;
                        state <= s_cleanup;                      
                    end
                end
                s_cleanup : begin
                        state <=  s_idle;
                        r_done <= 1'b0;
                    end
                    
                    default :
                        state <= s_idle;
                endcase
            end
        end
           
       assign o_done = r_done;
       assign o_Byte = r_Byte;     
                   
                        
endmodule
