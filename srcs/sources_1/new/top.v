`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2023 12:22:38
// Design Name: 
// Module Name: top
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

// state maschine that interprets commands

module top(
    input sys_clk,
    input sw_0, // reset
    input RsRx,
    output RsTx
    );

    parameter s_idle =               4'b0000;
    parameter s_is_error =           4'b0001;
    parameter s_send_error_message = 4'b0010;
    parameter s_check_command =      4'b0011;
    parameter s_read_wait =          4'b0100;
    parameter s_read =               4'b0101;
    parameter s_write =              4'b0110;

    // wires for command decoder
    wire        cmd_dec_done;
    wire [7:0]  cmd_dec_command;
    wire [14:0] cmd_dec_address;
    wire [31:0] cmd_dec_data;
    wire [1:0]  cmd_dec_error;
    wire        cmd_dec_readWrite;


    //wires for memory
    reg         mem_readWrite;
    reg [31:0]  mem_dataIn;
    reg         mem_enable;
    reg [14:0]   mem_address;
    wire [31:0] mem_dataOut;

    // wires for the word to byte module

    reg        wtb_enable = 0;
    reg        wtb_mode_select;
    reg [31:0] wtb_word = 32'h0;
    reg [7:0]  wtb_byte;
    wire       wtb_done;

    reg [2:0] state = s_idle;

    


    command_decoder CommandDecoder(
        .clock       (sys_clk),
        .reset       (sw_0),
        .uart_in     (RsRx),
        .o_command   (cmd_dec_command),
        .o_address   (cmd_dec_address),
        .o_data      (cmd_dec_data),
        .o_readwrite (cmd_dec_readWrite),
        .o_done      (cmd_dec_done),
        .o_error     (cmd_dec_error)
        );


    sram SRAM(
        .clock      (sys_clk),
        .reset      (sw_0),
        .enable     (mem_enable), 
        .readWrite  (mem_readWrite),
        .dataIn     (mem_dataIn),
        .address    (mem_address),
        .dataOut    (mem_dataOut)
    );

    word_to_byte_tx WordToByte(
        .clock         (sys_clk),
        .enable        (wtb_enable),
        .i_mode_select (wtb_mode_select),
        .i_word        (wtb_word),
        .i_byte        (wtb_byte),
        .o_serial      (RsTx),
        .o_done        (wtb_done)
        );



    always @(posedge sys_clk or negedge sw_0) begin
        if (!sw_0) begin
            // reset
            mem_enable <= 0;
            mem_readWrite <= 0;
            wtb_enable <= 0;
            wtb_mode_select <= 1;
            state <= s_idle;
            
        end else begin
            case(state)
                s_idle : begin
                    mem_enable <= 0;
                    wtb_enable <= 0;
                    if (cmd_dec_done) begin
                        state <= s_is_error;
                    end
                end
                s_is_error : begin
                    if (cmd_dec_error != 2'b00) begin // if not in the error free state
                        state <= s_send_error_message;    
                    end else begin
                        state <= s_check_command;
                    end
                end
                s_send_error_message : begin
                    wtb_enable <= 1;
                    wtb_mode_select <= 0; // byte mode
                    if (cmd_dec_error == 2'b01) begin
                        wtb_byte <= 8'b00000001;
                    end else if (cmd_dec_error == 2'b10) begin
                        wtb_byte <= 8'b00000010;
                    end else if (cmd_dec_error == 2'b11) begin
                        wtb_byte <= 8'b00000011;
                    end
                    state <= s_idle; // should I do this like this we arent outputing to any other module so I can just go look for new input
                    // how do I handle wtb being busy --> Just load to register ~ meh
                end
                s_check_command : begin
                    mem_enable <= 1;
                    mem_readWrite <= cmd_dec_readWrite;
                    mem_address <= cmd_dec_address;
                    if (cmd_dec_command == 8'h01) begin
                        state <= s_read_wait;
                    end
                    if (cmd_dec_command == 8'h00) begin
                        state <= s_write;
                        mem_dataIn <= cmd_dec_data;
                    end
                end
                s_read_wait : state <= s_read; // wait for memory fetch
                s_read : begin
                    mem_enable <= 0;
                    wtb_enable <= 1;
                    wtb_mode_select <= 1; // word mode
                    wtb_word <= mem_dataOut;
                    state <= s_idle;
                end
                s_write : state <= s_idle; // memory is being written
                default : state <= s_idle;
            endcase
        end
    end

endmodule