module lock(
            input code_new_updated,
            input [7:0] check_code,
            input clk_2,
            input clk_300k,
                    
            output reg led_1,
            output reg led_2,
            output reg led_3
            );
 
 reg [4:0] state_1;
 reg [11:0] counter_3;
 reg counter_3_reset;
              
initial 
 begin
  led_1 <= 0;        
  led_2 <= 0;        
  led_3 <= 0;        
  state_1 <= 0;
  counter_3 <= 0;
 end
        
always@ (posedge clk_2)
 begin
 
 //couter  
  if (counter_3_reset) counter_3 <= 0;
   else if (clk_300k) counter_3 <= counter_3 + 1;
  else counter_3 <= counter_3;
  
 case(state_1)
  0:
   begin 
    counter_3_reset <= 1; 
    if ((check_code == 8'h7E)&(code_new_updated)) state_1 <= 1;
     else if ((check_code == 8'h77)&(code_new_updated)) state_1 <= 4;
      else if ((check_code == 8'h58)&(code_new_updated)) state_1 <= 7;
    else state_1 <= 0;       
   end  
  1:
   begin
    counter_3_reset <= 0;
    if(counter_3 >= 151) state_1 <= 2;
    else state_1 <= 1;
   end  
  2:
   begin
    led_1 <= !led_1;
    state_1 <= 3;
   end   
  3:
   begin
    led_1 <= led_1;
    if ((check_code == 8'hF0)&(code_new_updated)) state_1 <= 0;
    else state_1 <= 3;
   end
  4:
   begin
    counter_3_reset <= 0;
    if(counter_3 >= 151) state_1 <= 5;
    else state_1 <= 4;
   end
  5:
   begin
    led_2 <= !led_2;
    state_1 <= 6;
   end   
  6:
   begin
    led_2 <= led_2;
    if ((check_code == 8'hF0)&(code_new_updated)) state_1 <= 0;
    else state_1 <= 6;
   end       
  7:
   begin
    counter_3_reset <= 0;
    if(counter_3 >= 151) state_1 <= 8;
    else state_1 <= 7;
   end  
  8:
   begin
    led_3 <= !led_3;
    state_1 <= 3;
   end   
  9:
   begin
    led_3 <= led_3;
    if ((check_code == 8'hF0)&(code_new_updated)) state_1 <= 0;
    else state_1 <= 3;
   end
   default:
    state_1 <= 0; 
  endcase
  
  
 end                                                           
endmodule 