`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2023 11:43:07 AM
// Design Name: 
// Module Name: com_dec_combined_tb
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


module com_dec_combined_tb(


    );


    reg clk;
    reg [31:0] r_testdata;
    reg [31:0] r_inword;
    reg [7:0] r_testcommand;
    reg [7:0] r_testaddress;
    reg [7:0]  r_uart_byte; 
    reg r_uart_tx_enable;
    //reg [3:0] r_state;
    //wire [3:0] w_state;

    wire w_uart_out;
    wire w_uart_tx_done;
    wire [7:0] w_command;
    wire [7:0] w_address;
    wire [31:0] w_data;
    wire w_cmd_dec_done;

    reg [7:0] r_command_out;
    reg [7:0] r_address_out;
    reg [31:0] r_data_out;

    reg [1:0] state_counter = 0;
    reg [1:0] done_counter = 0;

    command_decoder CommandDecoder(
        .clock(clk),
        .uart_in(w_uart_out),
        .o_command(w_command),
        .o_address(w_address),
        .o_data(w_data),
        .o_done(w_cmd_dec_done)//,
        //.state(w_state)
        );
    
    uart_tx UART_TX(

        .clock(clk),
        .enable(r_uart_tx_enable),
        .i_word(r_inword),
        .in_Byte(r_uart_byte),
        .r_done(w_uart_tx_done),
        .serial_out(w_uart_out)

        );

    initial begin
        r_uart_tx_enable <= 1;
        clk <= 0;
        r_inword <= 32'bz;
        r_testcommand <= 8'h0;
        r_testaddress <= 8'h1;
        r_testdata <= 32'haf32cd85;
    end

    always begin
        #10 clk <= ~clk;
    end


    always @(w_uart_tx_done) begin
        //r_state <= w_state;
        // if (state_counter > 2'b10) begin
        //     state_counter <= 2'b00;
        // end
        done_counter <= done_counter + 1;
        #1;
        case(state_counter)
            2'b00:
                begin
                    r_inword <= 32'hz;
                    r_uart_byte <= r_testcommand;
                    r_command_out <= w_command;
                    
                    if (done_counter > 0) begin
                        done_counter <= 0;
                        state_counter <= 2'b01;
                    end
                end
            2'b01:
                begin
                    r_inword <= 32'hz;
                    r_uart_byte <= r_testaddress;
                    r_address_out <= w_address;
                    if (done_counter > 0) begin
                        done_counter <= 0;
                        state_counter <= 2'b10;
                    end
                end
            2'b10:
                begin
                    r_inword <= r_testdata;
                    r_data_out <= w_data;
                    if (done_counter > 3) begin
                        done_counter <= 0;
                        state_counter <= 2'b00;
                    end
                end

            default: 
                begin
                    state_counter <= 2'b00;
                end
        endcase
    end

    always begin
        $display;
        #1;
    end

    always @ (r_command_out or r_address_out or r_data_out) begin

        if (r_command_out !== r_testcommand) begin
                $display("commmand test failed");
                #1; 
            end   
        if (r_address_out !== r_testaddress) begin
                $display("address test failed");
                #1;  
            end 
        if (r_data_out !== r_testdata) begin
                $display("data test failed");
                #1;  
            end
        else begin
            #1;
        end
    end

    always begin
        #1000000 $stop;
    end

endmodule