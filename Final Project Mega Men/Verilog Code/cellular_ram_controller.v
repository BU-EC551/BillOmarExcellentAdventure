`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:53 03/23/2015 
// Design Name: 
// Module Name:    cellular_ram_controller 
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
module cellular_ram_controller(clk, OE, WE, ADV, CLK, CE, CRE, UB, LB, A,
									WAIT, DQ, ram_addr);
//asynchronous read 
input WAIT, clk; 
input [15:0] DQ;
input [25:0] ram_addr;
output OE, WE, ADV, CLK, CE, CRE, UB, LB;
output [25:0] A;


assign A = ram_addr;//for testing

assign OE=0; // asynchronous reading
assign WE=1;
assign ADV=0;
assign CLK=0;
assign CE=0;
assign CRE=0;
assign UB=0;
assign LB=0;
				


endmodule
