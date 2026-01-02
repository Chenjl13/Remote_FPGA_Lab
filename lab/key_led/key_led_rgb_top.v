`timescale 1ns / 1ps

`define UD #1
module key_led_top(
    input           clk,
    input           key,
    
    output [7:0]    led
);

   wire [1:0] ctrl;
   
   key_ctl key_ctl(
       .clk        (  clk  ),
       .key        (  key  ),
                 
       .ctrl       (  ctrl  )
   );
   
   led u_led(
       .clk   (  clk   ),
       .ctrl  (  ctrl  ),
                      
       .led   (  led   ) 
   );

endmodule
