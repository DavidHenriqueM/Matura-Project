`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 08:50:54 AM
// Design Name: 
// Module Name: TopUART
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


module TopUART(

    input         clk,
    input         rst, // reset
    input         serial_in,
    input         arbitratorDone,
    input  [31:0] dataOutOfMemory,
    output        serial_out,
    output        out_readWrite,
    output [31:0] dataIntoMemory,
    output        memoryEnable,
    output [14:0] memoryAddress
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

    reg [1:0] save_error = 0;

    command_decoder CommandDecoder(
        .clock       (clk),
        .reset       (rst),
        .uart_in     (serial_in),
        .o_command   (cmd_dec_command),
        .o_address   (cmd_dec_address),
        .o_data      (cmd_dec_data),
        .o_readwrite (cmd_dec_readWrite),
        .o_done      (cmd_dec_done),
        .o_error     (cmd_dec_error)
        );

    // intead of memory module we assign from inputs
    // outputs
    assign out_readWrite  = mem_readWrite;
    assign dataIntoMemory = mem_dataIn;
    assign memoryEnable   = mem_enable;
    assign memoryAddress  = mem_address;
    // inputs
    assign mem_dataOut = dataOutOfMemory;


// memory handled in the top state machine alongside the instruction pointer
/*    sram SRAM(
        .clock      (clk),
        .reset      (rst),
        .enable     (mem_enable), 
        .readWrite  (mem_readWrite),
        .dataIn     (mem_dataIn),
        .address    (mem_address),
        .dataOut    (mem_dataOut)
    );*/

    word_to_byte_tx WordToByte(
        .clock         (clk),
        .reset         (rst),
        .enable        (wtb_enable),
        .i_mode_select (wtb_mode_select),
        .i_word        (wtb_word),
        .i_byte        (wtb_byte),
        .o_serial      (serial_out),
        .o_done        (wtb_done)
        );


    /*
    always @(posedge clk or negedge rst) begin  // asynchronous reset
        if (!rst) begin
            // reset
            mem_enable <= 0;
            //mem_readWrite <= 0;
            wtb_enable <= 0;
            wtb_mode_select <= 1;
            wtb_byte <= 0;
            wtb_word <= 0;
            save_error <= 0;
            state <= s_idle;
            //mem_address <= 0;
            //mem_dataIn <= 0;
            
        end else begin
            case(state)
                s_idle : begin
                    mem_dataIn <= 0;
                    mem_address <= 0;
                    mem_readWrite <= 0;
                    mem_enable <= 0;
                    wtb_enable <= 0;
                    save_error <= 0;

                    wtb_byte <= 0; // reset what will be transmitted
                    wtb_word <= 0;

                    if (cmd_dec_done) begin
                        state <= s_is_error;
                    end
                end
                s_is_error : begin
                    if (cmd_dec_error != 2'b00) begin // if not in the error free state
                        state <= s_send_error_message;   
                        save_error <= cmd_dec_error; // we need to register the error value to compare it in the next state
                    end else begin
                        state <= s_check_command;
                    end
                end
                s_send_error_message : begin
                    wtb_enable <= 1;
                    wtb_mode_select <= 0; // byte mode
                    if (save_error == 2'b01) begin
                        wtb_byte <= 1;
                    end else if (save_error == 2'b10) begin
                        wtb_byte <= 2;
                    end else if (save_error == 2'b11) begin
                        wtb_byte <= 3;
                    end
                    save_error <= 0; // reset saved error
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
    end */

    always @(posedge clk /*or negedge rst*/) begin  // synchronous reset
        if (!rst) begin
            // reset
            mem_enable <= 0;
            mem_readWrite <= 0;
            wtb_enable <= 0;
            wtb_mode_select <= 1;
            wtb_byte <= 0;
            wtb_word <= 0;
            save_error <= 0;
            state <= s_idle;
            mem_address <= 0;
            mem_dataIn <= 0;
            
        end else begin
            case(state)
                s_idle : begin
                    mem_dataIn <= 0;
                    mem_address <= 0;
                    mem_readWrite <= 0;
                    mem_enable <= 0;
                    wtb_enable <= 0;
                    save_error <= 0;

                    wtb_byte <= 0; // reset what will be transmitted
                    wtb_word <= 0;

                    if (cmd_dec_done) begin
                        state <= s_is_error;
                    end
                end
                s_is_error : begin
                    if (cmd_dec_error != 2'b00) begin // if not in the error free state
                        state <= s_send_error_message;   
                        save_error <= cmd_dec_error; // we need to register the error value to compare it in the next state
                    end else begin
                        state <= s_check_command;
                    end
                end
                s_send_error_message : begin
                    wtb_enable <= 1;
                    wtb_mode_select <= 0; // byte mode
                    if (save_error == 2'b01) begin
                        wtb_byte <= 1;
                    end else if (save_error == 2'b10) begin
                        wtb_byte <= 2;
                    end else if (save_error == 2'b11) begin
                        wtb_byte <= 3;
                    end
                    save_error <= 0; // reset saved error
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
                s_read_wait : begin
                    if (arbitratorDone) begin
                        state <= s_read; // wait for memory fetch
                    end
                end
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