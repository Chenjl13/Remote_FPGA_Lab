`timescale 1ns / 1ps
`define UD #1
module btn_deb_fix#(
    parameter        BTN_WIDTH = 4'd8,
    parameter        BTN_DELAY = 20'h7_ffff
)
(
    input                      clk,  
    input      [BTN_WIDTH-1:0] btn_in,
    
    output reg [BTN_WIDTH-1:0] btn_deb_fix
);

    reg [19:0]          cnt[BTN_WIDTH-1:0];
    reg [BTN_WIDTH-1:0] flag;
   
    reg [BTN_WIDTH-1:0] btn_in_reg;

    always @(posedge clk)
    begin
    	btn_in_reg <= `UD btn_in;
    end 

    genvar i;
    generate
        for(i=0;i<BTN_WIDTH;i=i+1)
        begin
            always @(posedge clk)
            begin
            	if (btn_in_reg[i] ^ btn_in[i]) 
            		flag[i] <= `UD 1'b1;
            	else if (cnt[i]==BTN_DELAY) 
            		flag[i] <= `UD 1'b0;
                else
                    flag[i] <= `UD flag[i];
            end 
            
            always @(posedge clk)
            begin
            	if(cnt[i]==BTN_DELAY)       
            		cnt[i] <= `UD 20'd0;
            	else if(flag[i])            
            		cnt[i] <= `UD cnt[i] + 1'b1;
            	else                        
            		cnt[i] <= `UD 20'd0;
            end 

            always @(posedge clk)
            begin
            	if(flag[i])                 
            		btn_deb_fix[i] <= `UD btn_deb_fix[i];
            	else                        
            		btn_deb_fix[i] <= `UD btn_in[i];
            end 
        end
    endgenerate

endmodule
