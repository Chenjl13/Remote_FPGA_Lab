`timescale 1ns / 1ps

`define UD #1
module led(
    input         clk,
    input  [1:0]  ctrl,
                  
    output [7:0]  led
);

    reg [24:0] led_light_cnt = 25'd0;
    reg [ 7:0] led_status = 8'b1000_0000;
    
    //  time counter
    always @(posedge clk)
    begin
        if(led_light_cnt == 25'd24_999_999)
            led_light_cnt <= `UD 25'd0;
        else
            led_light_cnt <= `UD led_light_cnt + 25'd1; 
    end
    
    reg [1:0] ctrl_1d=0;    
    always @(posedge clk)
    begin
        if(led_light_cnt == 25'd0)
            ctrl_1d <= ctrl;
    end

    always @(posedge clk)
    begin
        if(led_light_cnt == 25'd24_999_999)
        begin
            case(ctrl)
                2'd0 : 
                begin
                    if(ctrl_1d != ctrl)
                        led_status <= `UD 8'b1000_0000;
                    else
                        led_status <= `UD {led_status[0],led_status[7:1]};
                end
                2'd1 :  
                begin
                    if(ctrl_1d != ctrl)
                        led_status <= `UD 8'b1010_1010;
                    else
                        led_status <= `UD ~led_status;
                end
                2'd2 :  
                begin
                    if(ctrl_1d != ctrl )
                        led_status <= `UD 8'b0111_1111;
                    else
                        led_status <= `UD {led_status[0],led_status[7:1]};
                end
            endcase
        end
    end

    assign led = led_status;

endmodule
