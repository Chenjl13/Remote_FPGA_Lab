`timescale 1ns / 1ps

`define UD #1
module fram_buf #(
    parameter                     MEM_ROW_WIDTH        = 15    ,
    parameter                     MEM_COLUMN_WIDTH     = 10    ,
    parameter                     MEM_BANK_WIDTH       = 3     ,
    parameter                     CTRL_ADDR_WIDTH = MEM_ROW_WIDTH + MEM_BANK_WIDTH + MEM_COLUMN_WIDTH,
    parameter                     MEM_DQ_WIDTH         = 32    ,
    parameter                     H_NUM                = 12'd1280,
    parameter                     V_NUM                = 12'd720,
    parameter                     PIX_WIDTH            = 16
)(
    input                         vin_clk,
    input                         wr_fsync,
    input                         wr_en,
    input  [PIX_WIDTH- 1'b1 : 0]  wr_data,
    output reg                    init_done=0,
    
    input                         ddr_clk,
    input                         ddr_rstn,
    
    input                         vout_clk,
    input                         rd_fsync,
    input                         rd_en,
    output                        vout_de,
    output [PIX_WIDTH- 1'b1 : 0]  vout_data,
    
    output [CTRL_ADDR_WIDTH-1:0]  axi_awaddr     ,
    output [3:0]                  axi_awid       ,
    output [3:0]                  axi_awlen      ,
    output [2:0]                  axi_awsize     ,
    output [1:0]                  axi_awburst    ,
    input                         axi_awready    ,
    output                        axi_awvalid    ,
                                                  
    output [MEM_DQ_WIDTH*8-1:0]   axi_wdata      ,
    output [MEM_DQ_WIDTH -1 :0]   axi_wstrb      ,
    input                         axi_wlast      ,
    output                        axi_wvalid     ,
    input                         axi_wready     ,
    input  [3 : 0]                axi_bid        ,                                      
                                                  
    output [CTRL_ADDR_WIDTH-1:0]  axi_araddr     ,
    output [3:0]                  axi_arid       ,
    output [3:0]                  axi_arlen      ,
    output [2:0]                  axi_arsize     ,
    output [1:0]                  axi_arburst    ,
    output                        axi_arvalid    ,
    input                         axi_arready    ,
                                                  
    output                        axi_rready     ,
    input  [MEM_DQ_WIDTH*8-1:0]   axi_rdata      ,
    input                         axi_rvalid     ,
    input                         axi_rlast      ,
    input  [3:0]                  axi_rid            
);
    parameter LEN_WIDTH       = 32;
    parameter LINE_ADDR_WIDTH = 22;
    parameter FRAME_CNT_WIDTH = CTRL_ADDR_WIDTH - LINE_ADDR_WIDTH;
    
    wire                        ddr_wreq;     
    wire [CTRL_ADDR_WIDTH- 1'b1 : 0] ddr_waddr;    
    wire [LEN_WIDTH- 1'b1 : 0]  ddr_wr_len;   
    wire                        ddr_wrdy;     
    wire                        ddr_wdone;    
    wire [8*MEM_DQ_WIDTH-1 : 0] ddr_wdata;    
    wire                        ddr_wdata_req;
    
    wire                        rd_cmd_en   ;
    wire [CTRL_ADDR_WIDTH-1:0]  rd_cmd_addr ;
    wire [LEN_WIDTH- 1'b1: 0]   rd_cmd_len  ;
    wire                        rd_cmd_ready;
    wire                        rd_cmd_done;
                                
    wire                        read_ready  = 1'b1;
    wire [MEM_DQ_WIDTH*8-1:0]   read_rdata  ;
    wire                        read_en     ;
    wire                        ddr_wr_bac;

    wr_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),
        .ADDR_OFFSET      (  32'd0            ),
        .H_NUM            (  H_NUM            ),
        .V_NUM            (  V_NUM            ),
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),
        .LEN_WIDTH        (  LEN_WIDTH        ),
        .PIX_WIDTH        (  PIX_WIDTH        ),
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  )
    ) wr_buf (                                       
        .ddr_clk          (  ddr_clk          ),
        .ddr_rstn         (  ddr_rstn         ),
                                              
        .wr_clk           (  vin_clk          ),
        .wr_fsync         (  wr_fsync         ),
        .wr_en            (  wr_en            ),
        .wr_data          (  wr_data          ),
        
        .rd_bac           (  ddr_wr_bac       ),                                      
        .ddr_wreq         (  ddr_wreq         ),
        .ddr_waddr        (  ddr_waddr        ),
        .ddr_wr_len       (  ddr_wr_len       ),
        .ddr_wrdy         (  ddr_wrdy         ),
        .ddr_wdone        (  ddr_wdone        ),
        .ddr_wdata        (  ddr_wdata        ),
        .ddr_wdata_req    (  ddr_wdata_req    ),
                                              
        .frame_wcnt       (                   ),
        .frame_wirq       (  frame_wirq       )
    );
    
    always @(posedge ddr_clk)
    begin
        if(frame_wirq)
            init_done <= 1'b1;
        else
            init_done <= init_done;
    end 
    
    rd_buf #(
        .ADDR_WIDTH       (  CTRL_ADDR_WIDTH  ),
        .ADDR_OFFSET      (  32'h0000_0000    ),
        .H_NUM            (  H_NUM            ),
        .V_NUM            (  V_NUM            ),
        .DQ_WIDTH         (  MEM_DQ_WIDTH     ),
        .LEN_WIDTH        (  LEN_WIDTH        ),
        .PIX_WIDTH        (  PIX_WIDTH        ),
        .LINE_ADDR_WIDTH  (  LINE_ADDR_WIDTH  ),
        .FRAME_CNT_WIDTH  (  FRAME_CNT_WIDTH  )
    ) rd_buf (
        .ddr_clk         (  ddr_clk           ),
        .ddr_rstn        (  ddr_rstn          ),

        .vout_clk        (  vout_clk          ),
        .rd_fsync        (  rd_fsync          ),
        .rd_en           (  rd_en             ),
        .vout_de         (  vout_de           ),
        .vout_data       (  vout_data         ),
        
        .init_done       (  init_done         ),
      
        .ddr_rreq        (  rd_cmd_en         ),
        .ddr_raddr       (  rd_cmd_addr       ),
        .ddr_rd_len      (  rd_cmd_len        ),
        .ddr_rrdy        (  rd_cmd_ready      ),
        .ddr_rdone       (  rd_cmd_done       ),
                                              
        .ddr_rdata       (  read_rdata        ),
        .ddr_rdata_en    (  read_en           )
    );
    
    wr_rd_ctrl_top#(
        .CTRL_ADDR_WIDTH  (  CTRL_ADDR_WIDTH  ),
        .MEM_DQ_WIDTH     (  MEM_DQ_WIDTH     )
    )wr_rd_ctrl_top (                         
        .clk              (  ddr_clk          ),           
        .rstn             (  ddr_rstn         ),           
                                              
        .wr_cmd_en        (  ddr_wreq         ),
        .wr_cmd_addr      (  ddr_waddr        ),
        .wr_cmd_len       (  ddr_wr_len       ),
        .wr_cmd_ready     (  ddr_wrdy         ),
        .wr_cmd_done      (  ddr_wdone        ),
        .wr_bac           (  ddr_wr_bac       ),                                     
        .wr_ctrl_data     (  ddr_wdata        ),
        .wr_data_re       (  ddr_wdata_req    ),
                                              
        .rd_cmd_en        (  rd_cmd_en        ),
        .rd_cmd_addr      (  rd_cmd_addr      ),
        .rd_cmd_len       (  rd_cmd_len       ),
        .rd_cmd_ready     (  rd_cmd_ready     ), 
        .rd_cmd_done      (  rd_cmd_done      ),
                                              
        .read_ready       (  read_ready       ),    
        .read_rdata       (  read_rdata       ),    
        .read_en          (  read_en          ),                                          
                        
        .axi_awaddr       (  axi_awaddr       ),  
        .axi_awid         (  axi_awid         ),
        .axi_awlen        (  axi_awlen        ),
        .axi_awsize       (  axi_awsize       ),
        .axi_awburst      (  axi_awburst      ),
        .axi_awready      (  axi_awready      ),
        .axi_awvalid      (  axi_awvalid      ),
                                              
        .axi_wdata        (  axi_wdata        ),
        .axi_wstrb        (  axi_wstrb        ),
        .axi_wlast        (  axi_wlast        ),
        .axi_wvalid       (  axi_wvalid       ),
        .axi_wready       (  axi_wready       ),
        .axi_bid          (  4'd0             ),
        .axi_bresp        (  2'd0             ),
        .axi_bvalid       (  1'b0             ),
        .axi_bready       (                   ),
                                              
        .axi_araddr       (  axi_araddr       ),    
        .axi_arid         (  axi_arid         ),
        .axi_arlen        (  axi_arlen        ),
        .axi_arsize       (  axi_arsize       ),
        .axi_arburst      (  axi_arburst      ),
        .axi_arvalid      (  axi_arvalid      ), 
        .axi_arready      (  axi_arready      ),
                                              
        .axi_rready       (  axi_rready       ),
        .axi_rdata        (  axi_rdata        ),
        .axi_rvalid       (  axi_rvalid       ),
        .axi_rlast        (  axi_rlast        ),
        .axi_rid          (  axi_rid          ),
        .axi_rresp        (  2'd0             )
    );


endmodule
