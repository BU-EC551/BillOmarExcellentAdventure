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
module vga_display(forward, backward, 
						 jump, attack, down, rst, clk, 
						 R, G, B, HS, VS,
						 MemOE, MemWR, MemAdv, MemWait, MemClk,
						 RamCS, RamCRE, RamUB, RamLB, 
						 MemAdr, MemDB);
	input rst;	// global reset
	input clk;	// 100MHz clk
	input forward;
	input backward; 
	input jump;
	input attack;
	input down;
	output MemOE, MemWR, MemAdv, MemClk, RamCS, RamCRE, RamUB, RamLB;
	output [26:0] MemAdr; 
	input MemWait;
	input [15:0] MemDB; 
	wire [25:0] ram_addr_bg;
	wire [25:0] ram_addr_enemy;
	// color outputs to show on display (current pixel)
	output [2:0] R, G;
	output [1:0] B;
	// Synchronization signals
	output HS;
	output VS;	
	// VGA controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank

	// Horizontal Sprite Constants 
	reg PIKAHITFLAG;
	reg MARIOHITFLAG;
	reg pikadirection;
	reg mariodirection;
	reg [9:0] startx, starty, sprite_num, enemyx, enemy_num, enemyy;
	reg [9:0] xzero;
	reg [9:0] xone;
	reg [9:0] yzero;
	reg [9:0] yone; 
	reg [17:0] move_count;
	reg [4:0] sprite_count;
	reg move_clk, sprite_clk;
	reg direction;
	reg jump_start;
	reg [8:0] jump_count;
	reg [8:0] platform_length;
	reg [8:0] platform_height;
	reg [8:0] platform_startx;
	reg [10:0] over_num;
	reg [4:0] enemy_count1, enemy_count2, enemy_count3, enemy_count4;	
	reg [9:0] mariox, marioy, marionum;
	reg [9:0] pikax, pikay, pika_num;
	reg mariodead, pikdead;	
	reg enemydirection; 	
	reg HITFLAG; 		
	reg enemy1dead;
	reg [4:0] levelnum;	
	reg level1complete;	// boss room
	reg level2complete; 	// swamp
	reg level3complete;	// rooftop
	reg [1:0] atk_count;
	reg [9:0] top_y;
	reg [9:0] base_y;
	reg clk_12Mhz;
	
	
	
	
	
	initial begin
		PIKAHITFLAG <= 0;
		MARIOHITFLAG <= 0;
		pikadirection <= 0;
		mariodirection <= 0;
		atk_count <= 0;
		base_y <= 0;
		top_y <= 0;
		platform_length <= 100;
		platform_height <= 370;
		platform_startx <= 300;
		startx <= 200;
		starty <= 390;
		enemyx <= 600;
		enemyy <= 390;
		enemy_num <= 250;
		xzero <= 0;
		yzero <= 0;
		xone <= 50;
		yone <= 50; 
		sprite_num <= 0;
		sprite_count <= 0;
		jump_count <= 0;
		direction <= 0;
		jump_start <= 0;
		jump_count <= 0;
		over_num <= 0;
		enemydirection <= 0;
		enemy1dead <= 0;
		HITFLAG <= 0;
		levelnum <= 0;
		enemy_count1 <= 2;	// 2 ninjas
		enemy_count2 <= 2;	// ninja + pikachu
		enemy_count3 <= 1;	// mario
		mariox <= 435; 		// his width = 75;
		marioy <= 320; 		// his height = 50
		pikax <= 600;			// his width = 75
		pikay <= 386; 			// his height  = 50
		mariodead <= 0;
		pikdead <= 0;
		marionum <= 0;
		pika_num <= 0;
	end
	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	parameter N2 = 3;	// parameter for clock division
	reg clk_25Mhz;
	reg clk_50Mhz;
	reg [N-1:0] count;
	reg [N2-1:0] count2;
	initial count = 0;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		count2 <= count2 + 1'b1;
		clk_25Mhz <= count[N-1];
		clk_50Mhz <= count2[N2-1];
	end










	//Divide the clock to sample button presses for player movement
	always @ (posedge clk) begin
		move_count <= move_count + 1 'b1;
		if (move_count > 131072)
			move_clk <= 1;
		else
			move_clk <= 0;	
	end
	//Divide clock to sample button presses for sprite animation
	always @ (posedge move_clk) begin
		sprite_count <= sprite_count + 1 'b1;
		if (sprite_count > 16)
			sprite_clk <= 1;
		else
			sprite_clk <= 0;	
	end
	








	always @ (posedge move_clk) begin

		if(!jump_start) begin 		//If the player is falling or standing...
			//If the player is in the range of the platform
			if( (startx + 50 >= platform_startx) && (startx < platform_startx + platform_length) )begin 
				if( starty + 50 > base_y )		//If the player is falling above the platform
					starty <= starty + 1;			//Decrease position
				else if(starty + 50 <= platform_height) begin  //If the falling player has reached the platform...
					base_y <= platform_height;						//Set ground height to platform level
					top_y <= platform_height - 150;			  // Set jump height to account for platform offset
					if(down) begin									//If you want to jump off a platform...
						if(levelnum == 1) begin					//Set jump and ground controls according to the level
							base_y <= 440;
							top_y <= 290;
						end
						
						else if(levelnum == 2) begin
							base_y <= 436;
							top_y <= 286;
						end
					end
				end
			end
			else begin		//If the player is falling or standing NOT on the platform...
				base_y <= 440; //Set height control to ground level to the floor
				top_y <= 290;
			end				
			if( starty + 50 < base_y )	//Decrease y-pos if player is falling to ground level
				starty <= starty + 1;					
			if( jump && (starty + 50 == base_y) ) //If jumping is initiated and player is touching the ground
				jump_start <= 1'b1;					  //Enter jumping state
		end
		
		else begin							//If a jump has been start
			if( starty > top_y )		//Increase y-pos until max height is reached
				starty <= starty - 1;
			else
				jump_start <= 1'b0;	//At max height, initiate falling logic 
		end
	end

			
		
		

	
	always @ (posedge sprite_clk) begin
		
		if(HITFLAG && !enemy1dead) begin
			if(over_num == 1280)
				over_num <= 0;
			else
				over_num <= over_num + 640;
		end
		
		if (levelnum == 0 || levelnum == 31) begin
			if(attack) begin
				levelnum <= 1;
				HITFLAG <= 0;
				MARIOHITFLAG <= 0;
			end
		end
		
		else if(levelnum == 1 && enemy1dead)
			levelnum <= 2;
			
		else if(levelnum == 2 && pikdead)
			levelnum <= 3;	
		
		else if(levelnum > 0 && (HITFLAG || MARIOHITFLAG) )
			levelnum<=31;
	
	
		if (enemy1dead != 1) begin								//If the first enemy isn't dead...
			if(enemyx >= 10 && enemydirection == 1'b0) begin//And the enemy is walking left, but not at edge of screen...			
				enemyx <= enemyx - 7;									//Move the enemy's x-position to the left by 7 pixels
				if(enemy_num >= 400 || enemy_num == 150)			//If the memory offset is at the end of the 'walking' cycle
					enemy_num <= 250;										//Return to start of the cycle
				else if (enemyx < startx + 50 && enemyx > startx) begin	//If the enemy is within range of the player...
					enemy_num <= 450;													//Offset memory to show the enemy 'attack' sprite
					if (enemyy == starty) begin									//If the player hasn't jumped over the enemy...
						HITFLAG <= 1;													//Raise the flag that the player is dead
					end
				end
				
				else 
					enemy_num <= enemy_num + 50;		//Otherwise, continute cycling through sprite 'walking' animation
			end
			
			//The logic is then for when the character is facing the opposite direction,
			//moving the player in the opposite direction, and cycling through different sprites
			
			
			
			
			
			
			
			
			
			
			
			
			else if (enemyx <= 10 || enemydirection == 1'b1) begin
				enemy_num <= 0;
				enemydirection <= 1'b1; 
				enemyx <= enemyx + 7;
				if (enemyx >= 580)
					enemydirection <= 1'b0;
				else if (enemy_num >= 150)
					enemy_num <= 0;
				else if (enemyx + 50 < startx + 50 && enemyx + 50 > startx) begin
					enemy_num <= 200;
					if (enemyy == starty) begin
						HITFLAG <= 1;
					end
				end
				else 
					enemy_num <= enemy_num + 50;
			end
			
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
		
		if ( (levelnum == 1 && HITFLAG) || (levelnum == 2 && PIKAHITFLAG) || (levelnum == 3 && MARIOHITFLAG) )begin
			if (direction) // right 
				sprite_num <= 550;
			else 
				sprite_num <= 500;
		end
		
		
		if (levelnum == 0 || levelnum == 31) begin
			if(attack) begin
				enemyx <= 600;
			end
		end
		
		
		
		
		
		
		
		if(attack) begin	//If the attack button has been pressed...
			if(direction) begin	//And if the character is facing to the right...
				sprite_num <= 200;	//Offset the memory the show the 'attacking' sprite
				if (startx + 60 > enemyx && startx + 60 < enemyx + 50) begin  //If you are in range of the ninja enemy...
					if (levelnum == 1) begin											 // And if you're on level 1..
						enemy_count1 <= enemy_count1 - 1;							//Decrease the number of enemies left
						enemy_num <= 600;												  //Offset memory to show 'dead' ninja sprite
						if (enemy_count1 == 0) begin								 //If all enemies have been killed...
							level1complete <= 1; 									//Level 1 is complete
							enemy1dead <= 1'b1;									  //Set flag that all ninjas are dead	
						end
					end 
				end
				if (startx + 60 > pikax && startx + 60 < pikax + 75) begin   //If you are in the range of pikachu enemy...
					if (levelnum == 2) begin										   //And if your on level2...
						enemy_count2 <= enemy_count2 - 1;						  //Decrease the number of enemies left
						//pika_num <= 450;													 //Offset memory to show 'dead' pikachu
						if (enemy_count2 == 0)begin								//If all enemies are dead...							
							level2complete <= 1;									  //Level2 is complete
							pikdead <= 1;											 //Set the flag that pikachu is daed
						end
					end
				end
				if (startx + 60 > mariox && startx + 60 < mariox + 75) begin  //If you are in the range of mario enemy..
					if (levelnum == 3) begin											 //And if you are on level3...
						enemy_count3 <= enemy_count3 - 1;						   //Decrease the enemy count
						//marionum <= 450;												  //Offset memory to show 'dead' mario
						if (enemy_count3 == 0)begin								 //If all enemies are dead...						
							level3complete <= 1;										//Level2 is complete
							mariodead <= 1;										  //Set flag that mario is dead
						end
					end 
				end			
			end
	
			//The logic is then for when the character is facing the opposite direction,
			//which checks for different sprite boundaries and loads different sprites
	
			else begin
				sprite_num <= 450;
				if (startx - 10 < enemyx + 50 && startx - 10 > enemyx) begin
					if (levelnum == 1) begin
						enemy_count1 <= enemy_count1 - 1;
						if (enemy_count1 == 0)begin
							level1complete <= 1;
							enemy_num <= 600;
							enemy1dead <= 1'b1;
						end
					end 
				end
				if (startx - 10 < pikax + 75 && startx - 10 > pikax) begin
					if (levelnum == 2) begin
						enemy_count2 <= enemy_count2 - 1;
						if (pikdead == 0)begin
							level2complete <= 1;
							pikdead <= 1;
						end
					end
				end
				if (startx - 10 < mariox + 75 && startx - 10 > mariox) begin
					if (levelnum == 3) begin
						enemy_count3 <= enemy_count3 - 1;
						if (mariodead == 0) begin
							level3complete <= 1;
							mariodead <= 1;
						end						
					end 
				end				
			end	
		end
		
		
		
		
		
		
		if(levelnum == 3) begin
			if (mariodead != 1) begin
				if(mariox >= 100 && mariodirection == 1'b0) begin					
					mariox <= mariox - 4;
					if(marionum >= 225)// || marionum == 300)
						marionum <= 0;
					else if (mariox - 5 < startx + 50 && mariox - 5 > startx) begin
						marionum <= 450;
						// RAISE THE HITFLAG
						if (marioy == starty) begin
							MARIOHITFLAG <= 1;
						end
					end
					else 
						marionum <= marionum + 75;
				end
				else if (mariox <= 100 || mariodirection == 1'b1) begin
					//marionum <= 0;
					mariodirection <= 1'b1; 
					mariox <= mariox + 4;
					if (mariox >= 500)
						mariodirection <= 1'b0;
					else if (marionum >= 600) //moving right
						marionum <= 450;
					else if (mariox + 55 < startx + 50 && mariox + 55 > startx) begin
						//marionum <= 200;
						// RAISE THE HITFLAG 
						if (marioy == starty) begin
							MARIOHITFLAG <= 1;
						end
					end
					else 
						marionum <= marionum + 75;
				end			
			end //end mariodead	
		end //end levelnum == 3
		
		
		
		
		
		
		
		
		
		
	end
	



	// Horizontal Sprite Movement 
	always @ (posedge move_clk) begin

			if (forward) begin
				if (startx < 610)
					startx <= startx + 1;
			end
			
			else if (backward) begin
				if (startx > 0)
					startx <= startx - 1;
			end 
			
			
		if (levelnum == 0 || levelnum == 31) begin
			if(attack) begin
				startx <= 200;
			end
		end

		
		if(levelnum == 2) begin
			if (pikdead != 1) begin
				if(pikax >= 10 && pikadirection == 1'b0) begin					
					pikax <= pikax - 2;
					if(pika_num >= 225)// || pika_num == 300)
						pika_num <= 0;
					else if (pikax - 5 < startx + 50 && pikax - 5 > startx) begin
						pika_num <= 450;
						// RAISE THE HITFLAG
						if (pikay == starty) begin
							PIKAHITFLAG <= 1;
						end
					end
					else 
						pika_num <= pika_num + 75;
				end
				else if (pikax <= 10 || pikadirection == 1'b1) begin
					pika_num <= 0;
					pikadirection <= 1'b1; 
					pikax <= pikax + 2;
					if (pikax >= 580)
						pikadirection <= 1'b0;
					else if (pika_num >= 600) //moving right
						pika_num <= 375;
					else if (pikax + 55 < startx + 50 && pikax + 55 > startx) begin
						pika_num <= 200;
						// RAISE THE HITFLAG 
						if (pikay == starty) begin
							PIKAHITFLAG <= 1;
						end
					end
					else 
						pika_num <= pika_num + 75;
				end
			end 	
		end	
	end
	
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
	
	
	
	
	cellular_ram_controller dram(	clk, 					// INPUT 
											MemOE, 				// OUTPUT
											MemWR, 				// OUTPUT 
											MemAdv, 				// OUTPUT 
											MemClk, 				// OUTPUT 
											RamCS, 				// OUTPUT 
											RamCRE, 				// OUTPUT 
											RamUB, 				// OUTPUT 
											RamLB, 				// OUTPUT 
											MemAdr [26:1],		// OUTPUT 	
											MemWait, 			// INPUT 
											MemDB, 				// INPUT 	
											ram_addr_enemy);	// INPUT 

	masterspritectrl msp(
								.enemyx0(enemyx), 
								.enemyy0(enemyy),
								.enemyx1(enemyx + 50),
								.enemyy1(enemyy + 50),
								.playx0(startx), 
								.playy0(starty),
								.playx1(startx + 50),
								.playy1(starty + 50),
								.mariox0(mariox),
								.marioy0(marioy),
								.mariox1(mariox + 75),
								.marioy1(marioy + 50),
								.pikx0(pikax),
								.piky0(pikay),
								.pikx1(pikax + 75),
								.piky1(pikay + 50),
								.hc(hcount), 
								.vc(vcount), 
								.mem_value(MemDB), 					
								.rom_addr(ram_addr_enemy),  		
								.R(R), 
								.G(G), 
								.B(B), 
								.blank(blank),
								.sprite_num(sprite_num),
								.enemynum(enemy_num),
								.levelnum(levelnum),
								.over_num(over_num),
								.marionum(marionum),
								.piknum(pika_num),
								.clk_25Mhz(clk_25Mhz),
								.clk_50Mhz(clk_50Mhz));

endmodule




