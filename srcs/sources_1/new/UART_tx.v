`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: David Marques 
// 
// Create Date: 11.06.2023 12:57:32
// Design Name: 
// Module Name: UART_tx
// Project Name: 
// Target Devices: Basys 3 FPGA
// Tool Versions: 
// Description: Uart Transmitter
// 
// Dependencies: 100 Mhz Clock 5 Mbaud UART
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// CLKS_PER_BIT = (Clock Frequency/UART buad) in this case 20 clks per bit
// Tis but a state maschine
// drive 32'bz for a byte
//////////////////////////////////////////////////////////////////////////////////


module uart_tx
    #(parameter CLKS_PER_BIT = 20)
    (
    input clock, 
    input enable,
    //input [31:0] i_word,
    input [7:0] in_Byte,
    output reg r_done,
    output reg serial_out,
    //for testing
     output [2:0]o_state,
     output [7:0]o_data
    // output reg o_word_on
    );
    
    // State indication
    parameter s_idle = 3'b000;
    parameter s_enable = 3'b001;
    parameter s_start_bit = 3'b010;
    parameter s_data_bits = 3'b011;
    parameter s_stop_bit = 3'b100;
    parameter s_cleanup = 3'b101;
    parameter s_cleanup2 = 3'b110;

    
    
    reg [2:0] main_state = 0;
    reg [7:0] clock_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] r_data = 0;
    //reg [31:0] r_word = 0;
    //reg [1:0] r_word_count = 0;
    
    reg r_active = 0;

    assign o_state = main_state;
    assign o_data = r_data;
    
    always @ (posedge clock)
        begin
            if(main_state === 3'bzzz) begin
                main_state <= 3'b000;
            end        
            case (main_state)
                s_idle:
                begin
                    serial_out <= 1'b1;
                    r_done <= 1'b0;
                    clock_count <= 0;
                    bit_index <= 0;
                    
                    if (enable) begin
                        //r_data <= in_Byte; //comment out
                        main_state <= s_enable; 
                        end 
                    else begin
                        main_state <= s_idle;
                        end        
                    end  // case s_idle
                s_enable:
                begin
                        r_active <= 1'b1;
                        main_state <= s_start_bit;
                        r_data <= in_Byte; // if this line is commented out
                    end
                s_start_bit:
                begin
                serial_out <= 1'b0;
                
                // wait CLKS_PER_BIT - 1 clock cycles for start bit to finish
                if (clock_count < CLKS_PER_BIT-1)
                    begin
                        clock_count <= clock_count + 1;
                        main_state <= s_start_bit;
                    end 
                else
                    begin
                        clock_count <= 0;
                        main_state <= s_data_bits;
                    end
                end // case : s_start_bit
                s_data_bits :
                begin
                    serial_out <= r_data[bit_index];
                    
                    if (clock_count < CLKS_PER_BIT-1)
                        begin
                           clock_count <= clock_count + 1;
                           main_state <= s_data_bits; 
                        end     
                    else
                        begin
                        clock_count <= 0;
                        
                        // check if all bits are sent
                        if (bit_index < 7)
                            begin
                                bit_index <= bit_index + 1;
                                main_state <= s_data_bits;
                            end
                        else
                            begin
                                bit_index <= 0;
                                main_state <= s_stop_bit;
                            end
                  end
                  
                end // case: s_data_bits
                
                s_stop_bit:
                    begin
                        serial_out <= 1'b1;
                        
                        if (clock_count < CLKS_PER_BIT-1)
                            begin
                               clock_count <= clock_count + 1;
                               main_state <= s_stop_bit;
                            end 
                        else
                            begin
                                r_done = 1'b1;
                                clock_count <= 0;
                                main_state <= s_cleanup;
                                r_active <= 1'b0;
                            end
                    end // case: s_stop_bit
                // cleanup states in order to wait one cycle with done = 1 and done = 0
                s_cleanup:
                    begin
                        r_done <= 1'b0;
                        main_state <= s_cleanup2;
                    end
                s_cleanup2:
                    begin
                        main_state <= s_idle;
                    end
                default :
                    main_state <= s_idle;
            endcase            
        end    
        
    
endmodule
