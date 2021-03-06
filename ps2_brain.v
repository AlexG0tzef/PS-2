module ps2_brain(
         input clk_brain,
         input Caps,
         input Scroll,
         input Num,
         
         input ID_Check,
         
         input [7:0] Delay_Rate,      
         input Delay_Rate_Updated,
         
         input read_update,
         input [7:0] read_date_update,
         
         input check_ps2_beasy,
         
         input brain_clk_300k,
         
         output reg code_new,
         output reg [7:0] new_code,
         
         output reg write_update,
         output reg [7:0] write_data_update
         
         );
        
 reg [7:0] brain_state;
  
 reg [7:0] Caps_Old;
 reg [7:0] Scroll_Old;
 reg [7:0] Num_Old; 
 
 reg [7:0] delay_rate_mem;
 
 reg [2:0] requested_action;
 
 reg ps2_beasy_check;
 
 reg [9:0] brain_counter_40;
 reg brain_counter_40_reset;
 
 initial
  begin
   brain_state <= 0;
   
   Caps_Old <= 0;
   Scroll_Old <= 0;
   Num_Old <= 0;
   
   delay_rate_mem <= 0;
  
   requested_action <= 0;
   
   ps2_beasy_check <= 0;
  end
  
 always@(posedge clk_brain)
  begin
  
  //couter  
  if (brain_counter_40_reset) brain_counter_40 <= 0;
   else if (brain_clk_300k) brain_counter_40 <= brain_counter_40 + 1;
  else brain_counter_40 <= brain_counter_40;
  
  //main state machine
   case(brain_state)
    0:
     begin
	  brain_counter_40_reset <= 1;
	 
      Caps_Old <= Caps;
      Scroll_Old <= Scroll;
      Num_Old <= Num;
      
      write_update <= 1'b0;
      
      delay_rate_mem <= Delay_Rate;
      
      ps2_beasy_check <= check_ps2_beasy;
      
      if (ps2_beasy_check == 1'b1) brain_state <= 1;
       else if (ID_Check) brain_state <= 2; 
	    else if (Delay_Rate_Updated) brain_state <= 3; 
	     else if ((Caps != Caps_Old)|(Scroll != Scroll_Old)|(Num != Num_Old)) brain_state <= 4;
	  else brain_state <= 0;  
	 end  
	1: 
	 begin
      if (read_date_update == 8'hFA) brain_state <= 8;
      else brain_state <= 7; 
     end
    2: //send command IDCheck (0xF2) to kayboard
     begin
      requested_action <= 0;
      write_data_update <= 8'hF2;
      write_update <= 1'b1;
      brain_state <= 0;
     end 
    3: //send command delay/rate (0xF3) (part1) to keyboard
     begin
      requested_action <= 1;
      write_update <= 1'b1;
      write_data_update <= 8'hF3;
      brain_state <= 0;
     end 
    4: //send command set leds(0xED) (part1) to keyboard
     begin
      requested_action <= 2;
      write_update <= 1'b1;
      write_data_update <= 8'hED;
      brain_state <= 0;
     end   
    5: //send command delay/rate(value) (part2) to keyboard
     begin
      brain_counter_40_reset <= 0;
      requested_action <= 0;
      write_update <= 1'b1;
      write_data_update <= delay_rate_mem;
      if (brain_counter_40 >= 900) brain_state <= 0;
      else brain_state <= 5; 
     end   
    6: //send command set leds(value) (part2) to keyboard   
     begin
      brain_counter_40_reset <= 0;
      requested_action <= 0;
      write_update <= 1'b1;
      if (brain_counter_40 >= 900) brain_state <= 9;
      else brain_state <= 6; 
     end
    7: //send scan_code
     begin
      new_code <= read_date_update;
      code_new <= read_update;  
      brain_state <= 0;
     end
    8: //chech requested action
     begin 
      if (requested_action == 1) brain_state <= 5; 
	   else if (requested_action == 2) brain_state <= 6; 
	    else if (requested_action == 0) brain_state <= 0;
	 end
	9:
	 begin 
      write_update <= 1'b1;
      write_data_update <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Caps, Num, Scroll};
      brain_state <= 0;
     end 
	              
    default:
     brain_state <= 0;
   endcase                                                            
  end
 endmodule 
             