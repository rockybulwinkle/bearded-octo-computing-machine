`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:34:13 08/24/2014 
// Design Name: 
// Module Name:    i2c 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module i2c(
		clk_i,
		reset_n,
		sda_io,
		scl_o,
		cmd,
		data_i,
		data_o,
		cmd_en,
		data_valid,
		ready
    );
	 
	 /* commands:
	 0: nop
	 1: start
	 2: stop
	 3: send byte
	 4: read byte
	 */
	input clk_i;
	input reset_n;
	inout sda_io;
	input [3:0] cmd;
	input [7:0] data_i;
	output [7:0] data_o;
	input cmd_en;

	output reg scl_o;
	output reg data_valid;
	output reg ready = 0;
	reg sda_oe;
	reg sda_o;
	reg [15:0] state = RESET_STATE;
	reg [15:0] counter;
	reg [7:0] data_reg_i;
	reg [7:0] data_reg_o;
	assign data_o = data_reg_o;
	
	wire sda_io;
	wire sda_i;
	
	assign sda_io = sda_oe? (sda_o ? 1'bz : 1'b0) : 1'bz; //IO logic.
	assign sda_i = sda_io;
	

	
	localparam RESET_STATE = 0;
	localparam START_INIT = 1;
	localparam STOP_INIT = 2;
	localparam SEND_INIT = 3;
	localparam RECV_INIT = 4;
	localparam START_SIG = 5;
	localparam START_WAIT = 6;
	localparam SEND_SETUP = 7;
	localparam SEND_CLK = 8;
	localparam SEND_HOLD = 9;
	localparam SEND_ACK = 10;
	localparam SEND_ACK_WAIT = 11;
	localparam SEND_WAIT = 12;
	
	localparam RECV_SETUP = 13;
	localparam RECV_CLK = 14;
	localparam RECV_HOLD = 15;
	localparam RECV_ACK = 16;
	localparam RECV_ACK_WAIT = 17;
	localparam RECV_WAIT = 18;
	localparam STOP_WAIT = 19;
	
	always @(posedge clk_i) begin
		if (!reset_n) begin
			scl_o <= 1;
			data_valid <= 0;
			ready <= 1;
			sda_oe <= 0;
			sda_o <= 1;
			state <= RESET_STATE;
			counter <= 0;
		end else begin
			case (state)
				RESET_STATE:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 1;
						sda_oe <= 0;
						sda_o <= 1;
						state <= cmd_en? cmd : RESET_STATE;
						counter <= 0;
					end
				START_INIT:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= 1;
						state <= START_SIG;
						counter <= 0;
					end
				START_SIG:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= 0;
						state <= START_WAIT;
						counter <= 0;
					end
				START_WAIT:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 1;
						sda_oe <= 1;
						sda_o <= 0;
						state <= cmd_en ? cmd : START_WAIT;
						counter <= 0;
					end
				SEND_INIT:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= 0;
						state <= SEND_SETUP;
						counter <= 7;
						data_reg_i <= data_i;
					end
				SEND_SETUP:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= data_i[counter];
						state <= SEND_CLK;
						counter <= counter;
						data_reg_i <= data_reg_i;
					end
				SEND_CLK:
					begin
						scl_o <=1 ;
						data_valid <= 0;
						ready<= 0;
						sda_oe <= 1;
						sda_o <= sda_o;
						state <= SEND_HOLD;
						data_reg_i <= data_reg_i;
					end
				SEND_HOLD:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= sda_o;
						counter <= counter - 1;
						state <= (counter == 0) ? SEND_ACK : SEND_SETUP;
						data_reg_i <= data_reg_i;
					end
				SEND_ACK:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 0;
						sda_o <= 1;
						state <= SEND_ACK_WAIT;
						counter <= 0;
					end
				SEND_ACK_WAIT:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 0;
						sda_o <= 1;
						state <= sda_i ? SEND_ACK_WAIT : SEND_WAIT;
						counter <= 0;
					end
				SEND_WAIT:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 1;
						sda_oe <= 0;
						sda_o <= 1;
						state <= cmd_en? cmd : SEND_WAIT;
						counter <= 0;
					end
					
				RECV_INIT:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 0;
						sda_o <= 0;
						state <= RECV_SETUP;
						counter <= 7;
						data_reg_o <= 8'h00;
					end
				RECV_SETUP:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 0;
						state <= RECV_CLK;
						counter <= counter;
						data_reg_o <= data_reg_o;
					end
				RECV_CLK:
					begin
						scl_o <=1 ;
						data_valid <= 0;
						ready<= 0;
						sda_oe <= 0;
						state <= RECV_HOLD;
						counter <= counter;
						data_reg_o <= data_reg_o;
					end
				RECV_HOLD:
					begin
						scl_o <= 0;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 0;
						counter <= counter - 1;
						state <= (counter == 0) ? RECV_ACK : RECV_SETUP;
						data_reg_o <= data_reg_o | (sda_i << counter) ; //little iffy on loading directly from a wire, but it should meet setup requirements.
					end
				RECV_ACK:
					begin
						scl_o <= 1;
						data_valid <= 1;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= 0;
						state <= RECV_ACK_WAIT;
						counter <= 0;
						data_reg_o <= data_reg_o;
					end
				RECV_ACK_WAIT:
					begin
						scl_o <= 1;
						data_valid <= 1;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= 0;
						state <= sda_i ? RECV_ACK_WAIT : RECV_WAIT;
						counter <= 0;
						data_reg_o <= data_reg_o;
					end
				RECV_WAIT:
					begin
						scl_o <= 0;
						data_valid <= 1;
						ready <= 1;
						sda_oe <= 0;
						sda_o <= 1;
						state <= cmd_en? cmd : RECV_WAIT;
						counter <= 0;
						data_reg_o <= data_reg_o;
					end
				STOP_INIT:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 0;
						sda_oe <= 1;
						sda_o <= 0;
						state <= STOP_WAIT;
						counter <= 0;
					end
				STOP_WAIT:
					begin
						scl_o <= 1;
						data_valid <= 0;
						ready <= 1;
						sda_oe <= 1;
						sda_o <= 1;
						state <= cmd_en ? cmd : STOP_WAIT;
						counter <= 0;
					end
			endcase
		end
	end
	
endmodule
