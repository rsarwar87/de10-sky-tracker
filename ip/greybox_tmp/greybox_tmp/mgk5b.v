//lpm_counter CBX_SINGLE_OUTPUT_FILE="ON" LPM_PORT_UPDOWN="PORT_USED" LPM_TYPE="LPM_COUNTER" LPM_WIDTH=0 clock q updown
//VERSION_BEGIN 18.1 cbx_mgl 2018:09:12:14:15:07:SJ cbx_stratixii 2018:09:12:13:04:09:SJ cbx_util_mgl 2018:09:12:13:04:09:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2018  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details.



//synthesis_resources = lpm_counter 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgk5b
	( 
	clock,
	q,
	updown) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	output   q;
	input   updown;

	wire  wire_mgl_prim1_q;

	lpm_counter   mgl_prim1
	( 
	.clock(clock),
	.q(wire_mgl_prim1_q),
	.updown(updown));
	defparam
		mgl_prim1.lpm_port_updown = "PORT_USED",
		mgl_prim1.lpm_type = "LPM_COUNTER",
		mgl_prim1.lpm_width = 0;
	assign
		q = wire_mgl_prim1_q;
endmodule //mgk5b
//VALID FILE
