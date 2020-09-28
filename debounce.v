module debounce(
		input in_clk,
		input antinose,
		input clk,
		
		output reg out_clk
				);
 
 reg [2:0] result;
 reg reg1;
 reg reg2;
 
 
 initial 
 begin
	out_clk <= 0;
    result <= 0;
    reg1 <= 0;
    reg2 <= 0;
 end
  
 always @(posedge clk)
  begin 
   
   reg1 <= reg2;
   out_clk <= reg2 && !reg1;
   
   if((in_clk) & (antinose) & (!reg2)) result <= result + 1;
   else if (in_clk) result <= result;
   else result <= 0;
   
   if ((result >= 1) & (in_clk)) reg2 = 1;
   else reg2 <= 0;
   
  end 

endmodule 