`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:42:34 04/16/2015 
// Design Name: 
// Module Name:    enemysprite 
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
module masterspritectrl(enemyx0, enemyy0, enemyx1, enemyy1, 
								playx0, playy0, playx1, playy1,
								mariox0, marioy0, mariox1, marioy1,
								pikx0, piky0, pikx1, piky1,
								hc, vc, mem_value, rom_addr, 
								R, G, B, blank, sprite_num, enemynum, levelnum, over_num, marionum, piknum,
								clk_25Mhz, clk_50Mhz);
	
	input [10:0] enemyx0, enemyy0, enemyx1, enemyy1, playx0, playy0, playx1, playy1;	// Coordinates of where the image will be placed
	input [10:0] mariox0, marioy0, mariox1, marioy1, pikx0, piky0, pikx1, piky1;
	input [10:0] hc, vc;	// Coordinates of the current pixel
	input [15:0] mem_value;	// Memory value at address "rom_addr" used to be 7:0
	input blank;
	input [9:0] sprite_num, enemynum;
	input [9:0] marionum, piknum;
	input [10:0] over_num;
	input [4:0] levelnum;
	input clk_50Mhz, clk_25Mhz;
	output reg [25:0] rom_addr;	// ROM address used to be 15:0
	output reg [2:0] R, G;
	output reg [1:0] B;	// RGB values outputs;
	reg newrom;
	reg [9:0] xa, ya, xb, yb; 
	reg [9:0] xt1, yt1, xg1, yg1;
	reg [9:0] xe1, ye1;
	reg [9:0] marx, mary, pikax, pikay;
	reg [9:0] swampx, swampy;
	reg [9:0] roofx, roofy;
	wire [7:0] color_byte;
	reg [10:0] hcr, vcr;
	//assign color_byte =((hc % 2) && (vc % 2)) ?   : ;    //8'b11100000: 8'b00000000;//
	reg [8:0] mem_byte;
	reg byte_num;
	initial byte_num <= 1;
	
	parameter playerstart = 614401;
	parameter pikastart = 2215401;
	parameter mariostart = 2260401;// + 52500 for next sprite
	parameter level1start = 307201;
	parameter titlescreen = 0;
	parameter enemystart = 644401;
	parameter gameoverscreen = 679401;
	parameter level2start = 1601001;		//swamp
	parameter level3start = 1908201;		//rooftop
	
	///////////////////////////////////
	// LOAD ORDER
	// 1. TITLE SCREEN
	// 2. level1start (boss room)
	// 3. playerstart (Omar sprite)
	// 4. enemystart (Red Ninja with Death)
	// 5. gameoverscreen 
	// 6. level2start (SWAMP)
	// 7. level3start (ROOFTOP) 
	// 8. pikachu
	// 9. mario
	///////////////////////////////////
	
	/*
	
	always @ (posedge clk_50Mhz) begin
	
	
	
	
	
	end
	*/
	
	
	
	
	always @ (posedge clk_25Mhz) begin
						
			if (hc >= playx0 & hc < playx1)		// make sure thath x1-x0 = image_width
				xb = hc - playx0;	// offset the coordinates
			else
				xb = 0;	
			if (vc >= playy0 & vc < playy1)		// make sure that y1-y0 = image_height
				yb = vc - playy0;				//offset the coordinates
			else
				yb = 0;		
				
				
						
			if (levelnum == 0) begin			// TITLE SCREEN
				if (hc >= 0 & hc < 640)			// make sure thath x1-x0 = image_width
					xt1 = hc - 0;
				else
					xt1 = 0;
					
				if (vc >= 0 & vc < 480)		   // make sure that y1-y0 = image_height
					yt1 = vc - 0;					//offset the coordinates
				else
					yt1 = 0;
					
				rom_addr = (yt1 * 640 + xt1 + titlescreen) / 2;	
				
				if (xt1==0 || yt1==0)		// set the color output
					{R,G,B} = 8'd0;	
				else
					{R,G,B} = mem_value[7:0];

					
			end	
			
			
			else if (levelnum == 1) begin					//If your are on Level 1
																	
				if (hc >= enemyx0 & hc < enemyx1)		//If the VGA is displaying a pixel in the x-range of the player
					xe1 = hc - enemyx0;						//Offset the coordinates
				else
					xe1 = 0;					
				if (vc >= enemyy0 & vc < enemyy1)		//If the VGA is displaying a pixel in the y-range of the player
					ye1 = vc - enemyy0;						//Offset the coordinates
				else
					ye1 = 0;							
			

				if (hc >= 0 & hc < 640)						//If the VGA is displaying a pixel in the x-range of the player
					xa = hc - 0;								//Offset the coordinates
				else
					xa = 0;
					
				if (vc >= 0 & vc < 480)		  				//If the VGA is displaying a pixel in the y-range of the player
					ya = vc - 0;								//Offset the coordinates
				else
					ya = 0;

				if ((xb==0 || yb==0) && (xe1==0 || ye1 == 0) )	//If player or enemy sprites do not overlap with background
					rom_addr = (ya * 640 + xa + level1start) / 2;//Offset the memory read to load background RGB
				else if(xe1==0 || ye1 == 0)							//If the player sprite overlaps with background
					rom_addr = (yb * 600 + xb + sprite_num + playerstart) / 2;//Offset the memory read to load player RGB
				else															//If the enemy sprite overlaps with background
					rom_addr = (ye1 * 700 + xe1 + enemynum + enemystart) / 2; //Offset the memory read to load player RGB
					
				
				if (xa==0 || ya==0)							//If we are not in range of the display
					{R,G,B} = 8'd0;							//Output black
				else												//If we are in range of display
					{R,G,B} = mem_value[7:0];				//Output the memory read RGB value.
			end
			
			//This logic is then repeated for each level, as the enemy and background sprite offsets are different
			
			
			
			
			
			else if (levelnum == 2) begin			// swamp
				if (hc >= 0 & hc < 640)			// make sure thath x1-x0 = image_width
					swampx = hc - 0;
				else
					swampx = 0;
					
				if (vc >= 0 & vc < 480)		   // make sure that y1-y0 = image_height
					swampy = vc - 0;					//offset the coordinates
				else
					swampy = 0;
					
				//////////////////////////////////////////////////////////////
																	// PIKACHU
				if (hc >= pikx0 & hc < pikx1)		// make sure thath x1-x0 = image_width
					pikax = hc - pikx0;	// offset the coordinates
				else
					pikax = 0;					
				if (vc >= piky0 & vc < piky1)		// make sure that y1-y0 = image_height
					pikay = vc - piky0;				//offset the coordinates
				else
					pikay = 0;							
				//////////////////////////////////////////////////////////////
					
				if ((xb==0 || yb==0) && (pikax==0 || pikay == 0) )	
					rom_addr = (swampy * 640 + swampx + level2start) / 2;
				else if(pikax ==0 || pikay == 0)
					rom_addr = (yb * 600 + xb + sprite_num + playerstart) / 2; //Dont change for any level
				else
					rom_addr = (pikay * 900 + pikax + piknum + pikastart) / 2; // calculate the address	
				
				
				if (swampx==0 || swampy==0)		// set the color output
					{R,G,B} = 8'd0;	
				else
					{R,G,B} = mem_value[7:0];
					
			end
			
			else if (levelnum == 3) begin			// roof
				if (hc >= 0 & hc < 640)			// make sure thath x1-x0 = image_width
					roofx = hc - 0;
				else
					roofx = 0;
					
				if (vc >= 0 & vc < 480)		   // make sure that y1-y0 = image_height
					roofy = vc - 0;					//offset the coordinates
				else
					roofy = 0;
					
				//////////////////////////////////////////////////////////////
																	// MARIO
				if (hc >= mariox0 & hc < mariox1)		// make sure thath x1-x0 = image_width
					marx = hc - mariox0;	// offset the coordinates
				else
					marx = 0;					
				if (vc >= marioy0 & vc < marioy1)		// make sure that y1-y0 = image_height
					mary = vc - marioy0;				//offset the coordinates
				else
					mary = 0;							
				//////////////////////////////////////////////////////////////
						
					
				if ((xb==0 || yb==0) && (marx==0 || mary == 0) )	
					rom_addr = (roofy * 640 + roofx + level3start) / 2;
				else if(marx ==0 || mary == 0)
					rom_addr = (yb * 600 + xb + sprite_num + playerstart) / 2; //Dont change for any level
				else
					rom_addr = (mary * 1050 + marx + marionum + mariostart) / 2; // calculate the address	
				
				if (roofx==0 || roofy==0)		// set the color output
					{R,G,B} = 8'd0;	
				else
					{R,G,B} = mem_value[7:0];
					
			end	
			
			else if (levelnum == 31) begin			// TITLE SCREEN
				if (hc >= 0 & hc < 640)			// make sure thath x1-x0 = image_width
					xg1 = hc - 0;
				else
					xg1 = 0;
					
				if (vc >= 0 & vc < 480)		   // make sure that y1-y0 = image_height
					yg1 = vc - 0;					//offset the coordinates
				else
					yg1 = 0;
					
				rom_addr = (yg1 * 1920 + xg1 + gameoverscreen + over_num) / 2;	
				
				if (xg1==0 || yg1==0)		// set the color output
					{R,G,B} = 8'd0;	
				else
					{R,G,B} = mem_value[7:0];					
			end	
			
			
			
			
			
	end
	

	
	
endmodule
