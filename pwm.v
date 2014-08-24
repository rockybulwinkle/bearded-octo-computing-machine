`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:25:02 08/23/2014 
// Design Name: 
// Module Name:    pwm 
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
module pwm(
		clk_i,
		reset_n,
		duty_i,
		out,
		timeout
    );
	 
	 parameter RESOLUTION = 12;
	 
	 input clk_i;
	 input reset_n;
	 input[RESOLUTION-1:0] duty_i;
	 
	 output reg out;
	 output reg timeout;
	 
	 reg [RESOLUTION-1:0] counter;
	 
	 initial begin
		out <= 0;
		counter <= 0;
		timeout <= 0;
	 end
	 
	 always @ (posedge clk_i) begin
		if (!reset_n) begin
			counter <= 0;
		end else begin
			counter <= counter + 1;
			out <= counter < duty_i;
			timeout <= counter == 0;
		end
	 end
endmodule
