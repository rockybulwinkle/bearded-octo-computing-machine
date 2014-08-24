`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:58:09 08/23/2014 
// Design Name: 
// Module Name:    top_level 
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
module top_level(
			fpgaClk_i,
			chan_io,
			sda_io,
			scl_o
    );
	
	parameter RESOLUTION = 8;
	 
	input fpgaClk_i;
	
	inout sda_io;
	output scl_o;
	 
	 
	output chan_io;
	reg reset_n;
	 
	reg [RESOLUTION-1:0] duty_i;
	 
	wire timeout;
	 
	initial begin
		duty_i = 0;
		clkdiv = 0;
	end
	
	reg [31:0] clkdiv;
	always @ (posedge fpgaClk_i) begin
		clkdiv <= clkdiv + 1;
	end
	

		reg [7:0] data_reg_o;
	motor_hub #(.RESOLUTION(RESOLUTION)) instance_name (
    .clk_i(fpgaClk_i), 
    .reset_n(reset_n), 
    .duty_i(data_reg_o+128), 
    .out(chan_io),
	 .timeout(timeout)
    );
	
	
	
	
	reg [3:0] i2c_cmd;
	wire valid, ready;

	reg cmd_en;

	reg [15:0] state;
	reg [7:0] data_i;
	wire [7:0] data_o;
	
	initial begin
		i2c_cmd = 0;
		data_reg_o = 0;
		cmd_en = 0;
		reset_n = 0;
		state = RESET;
	end
	
	localparam RESET = 0;
	
	always @ (posedge clkdiv[2]) begin
		case (state)
			RESET:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 0;
					state <= ready ? 1 : 0;
				end
			1:
				begin
					i2c_cmd <= 1;
					cmd_en <= 1;
					reset_n <= 1;
					state <= (!ready) ? 2 : 1;
				end
			2: begin
					i2c_cmd <= 3;
					cmd_en <= 0;
					reset_n <= 1;
					state <= ready ? 3 : 2;
				end
			3: begin
					i2c_cmd <= 3;
					cmd_en <= 1;
					reset_n <= 1;
					data_i <= 8'hD0;
					state <= (!ready) ? 4:3; 
				end
			4: begin
					i2c_cmd <= 3;
					cmd_en <= 0;
					reset_n <= 1;
					data_i <= 8'hD0;
					state <= ready ? 5 : 4;
				end
			5: begin
					i2c_cmd <= 3;
					cmd_en <= 1;
					reset_n <= 1;
					data_i <= 8'h6B;
					state <= (!ready) ? 6 : 5;
				end
			6: begin
					i2c_cmd <= 3;
					cmd_en <= 0;
					reset_n <= 1;
					data_i <= 8'h6B;
					state <= ready ? 7 : 6;
				end
			7: begin
					i2c_cmd <= 3;
					cmd_en <= 1;
					reset_n <= 1;
					data_i <= 8'h0;
					state <= (!ready) ? 8 : 7;
				end
			8: begin
					i2c_cmd <= 2;
					cmd_en <= 0;
					reset_n <= 1;
					data_i <= 8'h0;
					state <= ready ? 9 : 8;
				end
			9 : begin
					i2c_cmd <= 2;
					cmd_en <= 1;
					reset_n <= 1;
					state <= (!ready) ? 10 : 9;
				 end
			10: 
				begin
					i2c_cmd <= 1;
					cmd_en <= 0;
					reset_n <= 1;
					state <= ready ? 11 : 10;
				end
			11:
				begin
					i2c_cmd <= 1;
					cmd_en <= 1;
					reset_n <= 1;
					state <= (!ready) ? 12 : 11;
				end
			12:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 1;
					state <= (ready) ? 13 : 12;
				end
			13:
				begin
					i2c_cmd <= 3;
					cmd_en <= 1;
					reset_n <= 1;
					data_i <= 8'hD0;
					state <= (!ready) ? 14: 13;
				end
			14:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 1;
					data_i <= 8'hD0;
					state <= ready ? 15 : 14;
				end
			15:
				begin
					i2c_cmd <= 3;
					cmd_en <= 1;
					reset_n <= 1;
					data_i <= 8'h3B;
					state <= (!ready) ? 16 : 15;
				end
			16:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 1;
					data_i <= 8'h43;
					state <= ready ? 17 : 16;
				end
			17:
				begin
					i2c_cmd <= 1;
					cmd_en <= 1;
					reset_n <= 1;
					state <= (!ready) ? 18 : 17;
				end
			18:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 1;
					state <= ready ? 19 : 18;
				end
			19:
				begin
					i2c_cmd <= 3;
					cmd_en <= 1;
					reset_n <= 1;
					data_i <= 8'hD1;
					state <= (!ready) ? 20 : 19;
				end
			20:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 1;
					data_i <= 8'hD1;
					state <= ready ? 21 : 20;
				end
			21:
				begin
					i2c_cmd <= 4;
					cmd_en <= 1;
					reset_n <= 1;
					state <= (!ready) ? 22 : 21;
				end
			22:
				begin
					i2c_cmd <= 0;
					cmd_en <= 0;
					reset_n <= 1;
					state <= ready ? 23 : 22;
				end
			23:
				begin
					i2c_cmd <= 2;
					cmd_en <= 1;
					reset_n <= 1;
					state <= (!ready) ? 10 : 23;
				end
		endcase
	end
	
	
	always @ (posedge clkdiv[0]) begin
		data_reg_o <= valid ? data_o : data_reg_o;
	end
	
	i2c i2c_fuck (
    .clk_i(clkdiv[3]),
    .reset_n(reset_n), 
    .sda_io(sda_io), 
    .scl_o(scl_o), 
    .cmd(i2c_cmd), 
    .data_i(data_i), 
    .data_o(data_o), 
    .cmd_en(cmd_en), 
    .data_valid(valid), 
    .ready(ready)
    );


endmodule
