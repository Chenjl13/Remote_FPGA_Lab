`timescale 1ns / 1ps
`define UD #1

module i2c_eeprom_test(
    input     clk,
    input     [2:0]key,
    input     rstn,
    
    output    [7:0]led,
    output    scl,
    inout     sda
);
    wire    [2:0]btn_deb;
    btn_deb_fix #(                    
        .BTN_WIDTH   (  4'd3        ), 
        .BTN_DELAY   (20'h7_ffff    )
    ) u_btn_deb                           
    (                            
        .clk         (  clk      ),
        .btn_in      (  key      ),
                  
        .btn_deb_fix     (  btn_deb  ) 
    );


    reg [2:0]btn_deb_reg ;
    always @(posedge clk)
    begin
        btn_deb_reg <= btn_deb;
    end

    reg wr;
    always @(posedge clk)
    begin
        if(!rstn)
            wr <= 1'b1;
        else if(!btn_deb[0] && btn_deb_reg[0])
            wr <= 1'b1;
        else if(!btn_deb[1] && btn_deb_reg[1])
            wr <= 1'b0;
        else
            wr <= wr;         
    end


    reg        iic_pluse;
    always @(posedge clk)
    begin
        if(!rstn)
            iic_pluse <= 1'b0;
        else if(!btn_deb[2] && btn_deb_reg[2])
            iic_pluse <= 1'b1;
        else
            iic_pluse <= 1'b0;
    end

    
    wire          busy;
    wire          byteover;
    wire [7:0]    data_out;
    wire          sda_in;     
    wire          sda_out;
    wire          sda_out_en;  

    iic_dri #(
        .CLK_FRE      (  27'd50_000_000  ),
        .IIC_FREQ     (  20'd400_000     ),
        .T_WR         (  10'd5           ),
        .DEVICE_ID    (  8'hA0           ),
        .ADDR_BYTE    (  2'd1            ),
        .LEN_WIDTH    (  8'd8            ),
        .DATA_BYTE    (  2'd1            ) 
    )iic_dri(                       
        .clk          (  clk             ),
        .rstn         (  rstn            ),
        .pluse        (  iic_pluse       ),
        .w_r          (  wr            ),
        .byte_len     (  8'd8            ),
                                         
        .addr         (  8'd0            ),
        .data_in      (  8'b10101010           ),
                                         
        .busy         (  busy            ),
        .byte_over    (  byte_over       ),
                                         
        .data_out     (  data_out        ),
                  
        .scl          (  scl             ),
        .sda_in       (  sda_in          ),             
        .sda_out      (  sda_out         ),      
        .sda_out_en   (  sda_out_en      )                 
    );

GTP_IOBUF #(
    .IOSTANDARD("DEFAULT"),
    .SLEW_RATE("SLOW"),
    .DRIVE_STRENGTH("8"),
    .TERM_DDR("ON")
) iobuf (
    .IO(sda), 
    .O(sda_in),   
    .I(sda_out), 
    .T(~sda_out_en)  
);

assign led=data_out;

endmodule
