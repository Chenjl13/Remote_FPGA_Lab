`timescale 1ns / 1ps
`define UD #1

module hdmi_test(
    input wire        sys_clk       ,
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
    output            led_int       ,

    output            pix_clk       ,                         
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         

);

parameter   X_WIDTH = 4'd12;
parameter   Y_WIDTH = 4'd12;    

    parameter V_TOTAL = 12'd1125;
    parameter V_FP = 12'd4;
    parameter V_BP = 12'd36;
    parameter V_SYNC = 12'd5;
    parameter V_ACT = 12'd1080;
    parameter H_TOTAL = 12'd2200;
    parameter H_FP = 12'd88;
    parameter H_BP = 12'd148;
    parameter H_SYNC = 12'd44;
    parameter H_ACT = 12'd1920;
    parameter HV_OFFSET = 12'd0;

    wire                        pix_clk    ;
    wire                        cfg_clk    ;
    wire                        locked     ;
    wire                        rstn       ;
    wire                        init_over  ;
    reg  [15:0]                 rstn_1ms   ;
    wire [X_WIDTH - 1'b1:0]     act_x      ;
    wire [Y_WIDTH - 1'b1:0]     act_y      ;    
    wire                        hs         ;
    wire                        vs         ;
    wire                        de         ;
    reg  [3:0]                  reset_delay_cnt;


    pll u_pll (
        .clkin1   (  sys_clk    ),
        .clkout0  (  pix_clk    ),
        .clkout1  (  cfg_clk    ),
        .pll_lock (  locked     )
    );

    ms72xx_ctl ms72xx_ctl(
        .clk         (  cfg_clk    ), 
        .rst_n       (  rstn_out   ), 
                                
        .init_over   (  init_over  ), 
        .iic_tx_scl  (  iic_tx_scl ), 
        .iic_tx_sda  (  iic_tx_sda ), 
        .iic_scl     (  iic_scl    ), 
        .iic_sda     (  iic_sda    )  
    );
   assign    led_int    =     init_over;
    
    always @(posedge cfg_clk)
    begin
    	if(!locked)
    	    rstn_1ms <= 16'd0;
    	else
    	begin
    		if(rstn_1ms == 16'h2710)
    		    rstn_1ms <= rstn_1ms;
    		else
    		    rstn_1ms <= rstn_1ms + 1'b1;
    	end
    end
    
    assign rstn_out = (rstn_1ms == 16'h2710);

    sync_vg #(
        .X_BITS               (  X_WIDTH              ), 
        .Y_BITS               (  Y_WIDTH              ),
        .V_TOTAL              (  V_TOTAL              ),                        
        .V_FP                 (  V_FP                 ),                      
        .V_BP                 (  V_BP                 ),                        
        .V_SYNC               (  V_SYNC               ),                        
        .V_ACT                (  V_ACT                ),                        
        .H_TOTAL              (  H_TOTAL              ),                        
        .H_FP                 (  H_FP                 ),                        
        .H_BP                 (  H_BP                 ),                        
        .H_SYNC               (  H_SYNC               ),                        
        .H_ACT                (  H_ACT                )                         
 
    ) sync_vg                                         
    (                                                 
        .clk                  (  pix_clk               ),                              
        .rstn                 (  rstn_out                 ),                           
        .vs_out               (  vs                   ),                                                                                                                                     
        .hs_out               (  hs                   ),         
        .de_out               (  de                   ),             
        .x_act                (  act_x                ),             
        .y_act                (  act_y                )             
    );
    
    pattern_vg #(
        .COCLOR_DEPP          (  8                    ), 
        .X_BITS               (  X_WIDTH              ),
        .Y_BITS               (  Y_WIDTH              ),
        .H_ACT                (  H_ACT                ),
        .V_ACT                (  V_ACT                )
    ) // Number of fractional bits for ramp pattern
    pattern_vg (
        .rstn                 (  rstn_out                 ),                                             
        .pix_clk              (  pix_clk               ), 
        .act_x                (  act_x                ),

        .vs_in                (  vs                   ),                
        .hs_in                (  hs                   ),                         
        .de_in                (  de                   ),
                                                   
        .vs_out               (  vs_out               ),                     
        .hs_out               (  hs_out               ),                      
        .de_out               (  de_out               ),                    
        .r_out                (  r_out                ),                   
        .g_out                (  g_out                ),                     
        .b_out                (  b_out                ) 
    );

endmodule
