`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    12:59:40 04/12/2011 
// Design Name: EC311 Support Files
// Module Name:    vga_display 
// Project Name: Lab5 / Lab6 / Project
// Target Devices: xc6slx16-3csg324
// Tool versions: XILINX ISE 13.3
// Description: 
//
// Dependencies: vga_controller_640_60
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_display(forward, backward, jump, attack, rst, clk, R, G, B, HS, VS);
	input rst;	// global reset
	input clk;	// 100MHz clk
	input forward;
	input backward; 
	input jump;
	input attack;
	// color outputs to show on display (current pixel)
	output [2:0] R, G;
	output [1:0] B;
	
	wire [2:0] R1, R2, R3, R4, G1, G2, G3, G4;
	wire [1:0] B1, B2, B3, B4;
	// Synchronization signals
	output HS;
	output VS;
	
	assign R = R1 | R2 | R3 | R4;
	assign G = G1 | G2 | G3 | G4;
	assign B = B1 | B2 | B3 | B4;
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	wire figure;	// the figure you want to display
	

	
	// memory interface:
	wire [15:0] addra, addra2, addra3, addra4;//15 bits to 16 now!!! 4/13
	wire [7:0] douta, douta2, douta3, douta4;

	
	// Horizontal Sprite Constants 
	reg [9:0] startx, starty, sprite_num, enemyx, enemy_num;
	reg [9:0] base_y;
	reg [9:0] top_y;
	reg [9:0] xzero;
	reg [9:0] xone;
	reg [9:0] yzero;
	reg [9:0] yone; 
	reg [17:0] ball_count;
	reg [4:0] sprite_count;
	reg ball_clk, sprite_clk;
	reg direction;
	reg jump_start;
	reg [8:0] jump_count;
	reg [8:0] platform_length;
	reg [8:0] platform_height;
	reg [8:0] platform_startx;
	reg jump_direction;

	// L or R? 0 for L, 1 for R
	reg enemydirection; 
	
	reg [63:0] temp;
	assign q = temp[000000];
	
	initial begin
		platform_length <= 250;
		platform_height <= 400;
		platform_startx <= 300;
		base_y <= 470;
		top_y <= 320;
		startx <= 200;
		starty <= 420;
		enemyx <= 600;
		enemy_num <= 250;
		xzero <= 0;
		yzero <= 0;
		xone <= 50;
		yone <= 50; 
		sprite_num <= 0;
		sprite_count <= 0;
		ball_count <= 0;
		direction <= 0;
		jump_start <= 0;
		jump_count <= 0;
		jump_direction <= 0;
		enemydirection <= 0;
	end
	
	
	always @ (posedge clk) begin
		ball_count <= ball_count + 1 'b1;
		if (ball_count > 131072)
			ball_clk <= 1;
		else
			ball_clk <= 0;	
	end
	
	always @ (posedge ball_clk) begin
		sprite_count <= sprite_count + 1 'b1;
		if (sprite_count > 16)
			sprite_clk <= 1;
		else
			sprite_clk <= 0;	
	end
	
	

	always @ (posedge ball_clk) begin


		if(!jump_start) begin //Falling or standing
			if( (startx + 50 >= platform_startx) && (startx < platform_startx + platform_length) )begin
				if( starty + 50 > base_y )
					starty <= starty + 1;
				else if(starty + 50 <= platform_height) begin
					base_y <= platform_height;
					top_y <= platform_height - 50;
				end
			end
			else begin
				base_y <= 470;
				top_y <= 320;
			end
				
				
			if( starty + 50 < base_y )
				starty <= starty + 1;					
			if( jump && ( (starty + 50 == base_y) ||  (starty + 49 == platform_height) ) )
				jump_start <= 1'b1;
			
		end
		
		else begin	//jumping

		   if( (startx + 50 >= platform_startx) && (startx < platform_startx + platform_length) ) begin
				if(starty + 50 == platform_height)
					top_y <= platform_height - 100;
			end

			if( starty > top_y )
				starty <= starty - 1;
			else
				jump_start <= 1'b0;
		end
		
		
	end








			
	
			

			
	reg HITflag; 		

	
	always @ (posedge sprite_clk) begin
	
		
		if(enemyx >= 10 && enemydirection == 1'b0) begin
			
			enemyx <= enemyx - 7;
			if(enemy_num >= 400 || enemy_num == 150)
				enemy_num <= 250;
			else if (enemyx - 55 < startx + 5 && enemyx - 55 > startx - 5) begin
				enemy_num <= 450;
				// RAISE THE HITFLAG 
				end
			else 
				enemy_num <= enemy_num + 50;
		end
		else if (enemyx <= 10 || enemydirection == 1'b1) begin
			enemy_num <= 0;
			enemydirection <= 1'b1; 
			enemyx <= enemyx + 7;
			if (enemyx >= 580)
				enemydirection <= 1'b0;
			else if (enemy_num >= 150)
				enemy_num <= 0;
			else if (enemyx + 55 < startx + 5 && enemyx + 55 > startx - 5) begin
				enemy_num <= 200;
				// RAISE THE HITFLAG 
				end
			else 
				enemy_num <= enemy_num + 50;
		end
			
		
		if(forward) begin		
			if( (sprite_num >= 150) || !direction)
				sprite_num <= 0;
			else
				sprite_num <= sprite_num + 50;
				
			direction <= 1'b1;
		end
		
		else if(backward) begin
			if( (sprite_num >= 400) || direction)
				sprite_num <= 250;
			else
				sprite_num <= sprite_num + 50;
			direction <= 1'b0;
		end
		
		else begin
			if(direction)	
				sprite_num <= 0;
			else
				sprite_num <= 250;	
				
			direction <= direction;
		end
		
		
		if(attack) begin
			if(direction)
				sprite_num <= 200;
			else
				sprite_num <= 450;
				
			if(startx + 55 >= enemyx) begin
				if(enemyx >= 10) begin
					enemyx <= 600;
					enemy_num <= 250;//450 before
				end
				else begin
					//enemyx <= 10;
					//enemy_num <= 200;
				end
			end
		end
		

		
	end


	

	// Horizontal Sprite Movement 
	always @ (posedge ball_clk) begin

			if (forward) begin
				//if (startx < 580)
					startx <= startx + 1;
			end
			
			else if (backward) begin
				//if (startx > 0)
					startx <= startx - 1;
			end 


	end 
	

	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	initial count = 0;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
	// Call driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank)
	);
	
	
	vga_bsprite sprites_mem_Bill(
		.x0(startx), 
		.y0(starty),
		.x1(startx + 50),
		.y1(starty + 50),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta), 
		.rom_addr(addra), 
		.R(R1), 
		.G(G1), 
		.B(B1), 
		.blank(blank),
		.sprite_num(sprite_num)
	);
	/*
	PCSprite sprites_mem_Omar(
		.x0(startx), 
		.y0(starty),
		.x1(startx + 50),
		.y1(starty + 50),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta), 
		.rom_addr(addra), 
		.R(R1), 
		.G(G1), 
		.B(B1), 
		.blank(blank),
		.sprite_num(sprite_num)
	);*/
	
	
	/*
	vga_bsprite sprites_mem_blue(
		.x0(enemyx), 
		.y0(420),
		.x1(enemyx + 50),
		.y1(470),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta2), 
		.rom_addr(addra2), 
		.R(R2), 
		.G(G2), 
		.B(B2), 
		.blank(blank),
		.sprite_num(enemy_num)
	);
	*/
	
	platsprite sprites_mem_platform(
		.x0(300), 
		.y0(400),
		.x1(550),
		.y1(410),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta4), 
		.rom_addr(addra4), 
		.R(R4), 
		.G(G4), 
		.B(B4), 
		.blank(blank),
		.sprite_num(0)
	);
	
	
	
		backsprite sprites_mem_background(
		.x0(0), 
		.y0(470),
		.x1(640),
		.y1(480),
		.hc(hcount), 
		.vc(vcount), 
		.mem_value(douta3), 
		.rom_addr(addra3), 
		.R(R3), 
		.G(G3), 
		.B(B3), 
		.blank(blank),
		.sprite_num(0)
	);
	
	
	
	

	
	//game_over_mem memory_1 (
	//background memory_2(
	
	RedNinja memory_3(
		.clka(clk_25Mhz), // input clka
		.addra(addra), // input [14 : 0] addra
		.douta(douta) // output [7 : 0] douta
	);

	
	BlueNinja memory_4(
		.clka(clk_25Mhz),
		.addra(addra2),
		.douta(douta2)
	);
	
	brickshort memory_5(
		.clka(clk_25Mhz),
		.addra(addra3),
		.douta(douta3)
		);
		
	platform memory_6(
		.clka(clk_25Mhz),
		.addra(addra4),
		.douta(douta4)
		);








	/*
	OmarPC memory_6(
		.clka(clk_25Mhz),
		.addra(addra),
		.douta(douta)
		);
	*/










endmodule




