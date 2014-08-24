`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:40:27 08/23/2014 
// Design Name: 
// Module Name:    motor_hub 
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
module motor_hub(
		clk_i,
		reset_n,
		duty_i,
		out,
		timeout
    );
	 parameter RESOLUTION = 12;
	 
	 input clk_i;
	 input reset_n;
	 input [RESOLUTION-1:0] duty_i;
	 
	 output out;
	 output timeout;
	 
	pwm #(.RESOLUTION(RESOLUTION)) motor_0(
    .clk_i(clk_i), 
    .reset_n(reset_n), 
    .duty_i(duty_i), 
    .out(out),
	 .timeout(timeout)
    );

endmodule
