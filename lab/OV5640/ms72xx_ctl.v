`timescale 1ns / 1ps
`define UD #1
module ms72xx_ctl(
    input       clk,
    input       rst_n,
    
    output      init_over,
    output      iic_tx_scl,
    inout       iic_tx_sda,
    output      iic_scl,
    inout       iic_sda
);
    reg rstn_temp1,rstn_temp2;
    reg rstn;
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            rstn_temp1 <= 1'b0;
        else
            rstn_temp1 <= rst_n;
    end
    
    always @(posedge clk)
    begin
        rstn_temp2 <= rstn_temp1;
        rstn <= rstn_temp2;
    end
    
    wire         init_over_rx;
    wire   [7:0] device_id_rx;
    wire         iic_trig_rx ;
    wire         w_r_rx      ;
    wire  [15:0] addr_rx     ;
    wire  [ 7:0] data_in_rx  ;
    wire         busy_rx     ;
    wire  [ 7:0] data_out_rx ;
    wire         byte_over_rx;
    
    wire   [7:0] device_id_tx;
    wire         iic_trig_tx ;
    wire         w_r_tx      ;
    wire  [15:0] addr_tx     ;
    wire  [ 7:0] data_in_tx  ;
    wire         busy_tx     ;
    wire  [ 7:0] data_out_tx ;
    wire         byte_over_tx;
    
    ms7200_ctl ms7200_ctl(
        .clk             (  clk           ),
        .rstn            (  rstn          ),
                              
        .init_over       (  init_over_rx  ),
        .device_id       (  device_id_rx  ),
        .iic_trig        (  iic_trig_rx   ),
        .w_r             (  w_r_rx        ),
        .addr            (  addr_rx       ),
        .data_in         (  data_in_rx    ),
        .busy            (  busy_rx       ),
        .data_out        (  data_out_rx   ),
        .byte_over       (  byte_over_rx  )
    );
    
    ms7210_ctl ms7210_ctl(
        .clk             (  clk           ),
        .rstn            (  init_over_rx  ),
                              
        .init_over       (  init_over     ),
        .device_id       (  device_id_tx  ),
        .iic_trig        (  iic_trig_tx   ),
        .w_r             (  w_r_tx        ),
        .addr            (  addr_tx       ),
        .data_in         (  data_in_tx    ),
        .busy            (  busy_tx       ),
        .data_out        (  data_out_tx   ),
        .byte_over       (  byte_over_tx  )
    );
    
    wire         sda_in;
    wire         sda_out;
    wire         sda_out_en;  
    iic_dri #(
        .CLK_FRE        (  27'd10_000_000  ),
        .IIC_FREQ       (  20'd400_000     ),
        .T_WR           (  10'd1           ),
        .ADDR_BYTE      (  2'd2            ),
        .LEN_WIDTH      (  8'd3            ),
        .DATA_BYTE      (  2'd1            )
    )iic_dri_rx(                       
        .clk            (  clk             ),
        .rstn           (  rstn            ),
        .device_id      (  device_id_rx    ),
        .pluse          (  iic_trig_rx     ),
        .w_r            (  w_r_rx          ),
        .byte_len       (  4'd1            ),
                   
        .addr           (  addr_rx         ),
        .data_in        (  data_in_rx      ),
                     
        .busy           (  busy_rx         ),
        .byte_over      (  byte_over_rx    ),
        .data_out       (  data_out_rx     ),
                                           
        .scl            (  iic_scl         ),
        .sda_in         (  sda_in          ),
        .sda_out        (  sda_out         ),
        .sda_out_en     (  sda_out_en      )
    );
    
    assign iic_sda = sda_out_en ? sda_out : 1'bz;
    assign sda_in = iic_sda;
    
    wire         sda_tx_in;
    wire         sda_tx_out;
    wire         sda_tx_out_en;  
    iic_dri #(
        .CLK_FRE        (  27'd10_000_000  ),
        .IIC_FREQ       (  20'd400_000     ),
        .T_WR           (  10'd1           ),
        .ADDR_BYTE      (  2'd2            ),
        .LEN_WIDTH      (  8'd3            ),
        .DATA_BYTE      (  2'd1            )
    )iic_dri_tx(                       
        .clk            (  clk             ),
        .rstn           (  rstn            ),
        .device_id      (  device_id_tx    ),
        .pluse          (  iic_trig_tx     ),
        .w_r            (  w_r_tx          ),
        .byte_len       (  4'd1            ),
                   
        .addr           (  addr_tx         ),
        .data_in        (  data_in_tx      ),
                     
        .busy           (  busy_tx         ),
        .byte_over      (  byte_over_tx    ),
        .data_out       (  data_out_tx     ),
                                           
        .scl            (  iic_tx_scl      ),
        .sda_in         (  sda_tx_in       ),
        .sda_out        (  sda_tx_out      ),
        .sda_out_en     (  sda_tx_out_en   )
    );
    
    assign iic_tx_sda = sda_tx_out_en ? sda_tx_out : 1'bz;
    assign sda_tx_in = iic_tx_sda;
    
endmodule
