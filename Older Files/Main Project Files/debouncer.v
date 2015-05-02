`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module debouncer(input clock, input trigger, output reg clean);

	parameter DELAY = 500000;   // .01 sec with a 50MHz clock

   reg [18:0] count;
   reg new;

   always @(posedge clock) begin
      if (trigger != new) begin 
			new <= trigger; count <= 0; 
	   end
      else if (count == DELAY) begin
			clean <= new;
		end
      else begin 
			count <= count+1;
	   end 
   end   

endmodule 