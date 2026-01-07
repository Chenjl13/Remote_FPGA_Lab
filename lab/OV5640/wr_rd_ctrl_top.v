`timescale 1ns / 1ps
`define UD #1

module wr_rd_ctrl_top # (
    parameter                    CTRL_ADDR_WIDTH      = 28,
    parameter                    MEM_DQ_WIDTH         = 16
) (
    input                        clk         ,
    input                        rstn        ,
    
    input                        wr_cmd_en   ,
    input  [CTRL_ADDR_WIDTH-1:0] wr_cmd_addr ,
    input  [31: 0]               wr_cmd_len  ,
    output                       wr_cmd_ready,
    output                       wr_cmd_done,
    
    output                       wr_bac,
    input  [MEM_DQ_WIDTH*8-1:0]  wr_ctrl_data,
    output                       wr_data_re  ,
    
    input                        rd_cmd_en   ,
    input  [CTRL_ADDR_WIDTH-1:0] rd_cmd_addr ,
    input  [31: 0]               rd_cmd_len  ,
    output                       rd_cmd_ready, 
    output                       rd_cmd_done,
    
    input                        read_ready,    
    output [MEM_DQ_WIDTH*8-1:0]  read_rdata,    
    output                       read_en,    
                                      
    output [CTRL_ADDR_WIDTH-1:0] axi_awaddr,  
    output [3:0]                 axi_awid,
    output [3:0]                 axi_awlen,
    output [2:0]                 axi_awsize,
    output [1:0]                 axi_awburst,
    input                        axi_awready,
    output                       axi_awvalid,
                                             
    output [MEM_DQ_WIDTH*8-1:0]  axi_wdata,
    output [MEM_DQ_WIDTH -1 :0]  axi_wstrb,
    input                        axi_wlast,
    output                       axi_wvalid,
    input                        axi_wready,
    input  [3 : 0]               axi_bid,
    input  [1 : 0]               axi_bresp,
    input                        axi_bvalid,
    output                       axi_bready,
                                             
    output [CTRL_ADDR_WIDTH-1:0] axi_araddr,    
    output [3:0]                 axi_arid,
    output [3:0]                 axi_arlen,
    output [2:0]                 axi_arsize,
    output [1:0]                 axi_arburst,
    output                       axi_arvalid, 
    input                        axi_arready,
                                             
    output                       axi_rready,
    input  [MEM_DQ_WIDTH*8-1:0]  axi_rdata,
    input                        axi_rvalid,
    input                        axi_rlast,
    input  [3:0]                 axi_rid,
    input  [1:0]                 axi_rresp   
);

    wire                        wr_en;            
    wire [CTRL_ADDR_WIDTH-1:0]  wr_addr;            
    wire [3:0]                  wr_id;            
    wire [3:0]                  wr_len;            
    wire                        wr_done;            
    wire                        wr_ready;            
    wire                        wr_data_en;            
    wire [MEM_DQ_WIDTH*8-1:0]   wr_data;            
          
    wire                        rd_en;
    wire [CTRL_ADDR_WIDTH-1:0]  rd_addr;           
    wire [3:0]                  rd_id;           
    wire [3:0]                  rd_len;            
    wire                        rd_done_p;   

    wr_cmd_trans#(
        .CTRL_ADDR_WIDTH  (  CTRL_ADDR_WIDTH  ),
        .MEM_DQ_WIDTH     (  MEM_DQ_WIDTH     )
    ) wr_cmd_trans (                      
        .clk              (  clk              ),
        .rstn             (  rstn             ),
                    
        .wr_cmd_en        (  wr_cmd_en        ),
        .wr_cmd_addr      (  wr_cmd_addr      ),
        .wr_cmd_len       (  wr_cmd_len       ),
        .wr_cmd_ready     (  wr_cmd_ready     ),
        .wr_cmd_done      (  wr_cmd_done      ),
        .wr_bac           (  wr_bac           ),
        .wr_ctrl_data     (  wr_ctrl_data     ),
        .wr_data_re       (  wr_data_re       ),
                                
        .wr_en            (  wr_en            ),       
        .wr_addr          (  wr_addr          ),      
        .wr_id            (  wr_id            ),        
        .wr_len           (  wr_len           ),       
        .wr_data_en       (  wr_data_en       ),
        .wr_data          (  wr_data          ),
        .wr_ready         (  wr_ready         ),
        .wr_done          (  wr_done          ),
                                              
        .rd_cmd_en        (  rd_cmd_en        ),
        .rd_cmd_addr      (  rd_cmd_addr      ),
        .rd_cmd_len       (  rd_cmd_len       ),
        .rd_cmd_ready     (  rd_cmd_ready     ),
        .rd_cmd_done      (  rd_cmd_done      ),
        .read_en          (  read_en          ),
                                              
        .rd_en            (  rd_en            ),                 
        .rd_addr          (  rd_addr          ),           
        .rd_id            (  rd_id            ),           
        .rd_len           (  rd_len           ),           
        .rd_done_p        (  rd_done_p        )     
    );

    wr_ctrl #(
        .CTRL_ADDR_WIDTH  (  CTRL_ADDR_WIDTH  ),
        .MEM_DQ_WIDTH     (  MEM_DQ_WIDTH     )
    )wr_ctrl(                        
        .clk              (  clk              ),
        .rst_n            (  rstn             ), 
                                              
        .wr_en            (  wr_en            ),
        .wr_addr          (  wr_addr          ),     
        .wr_id            (  wr_id            ),
        .wr_len           (  wr_len           ),
        .wr_cmd_done      (  wr_done          ),
        .wr_ready         (  wr_ready         ),
        .wr_data_en       (  wr_data_en       ),
        .wr_data          (  wr_data          ),
        .wr_bac           (  wr_bac           ),
                                              
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
        .axi_bid          (  axi_bid          ),
        .axi_bresp        (  axi_bresp        ),
        .axi_bvalid       (  axi_bvalid       ),
        .axi_bready       (  axi_bready       ),
        .test_wr_state    (                   )
    );

    rd_ctrl #(
        .CTRL_ADDR_WIDTH  (  CTRL_ADDR_WIDTH  ),
        .MEM_DQ_WIDTH     (  MEM_DQ_WIDTH     ) 
    )rd_ctrl(                               
        .clk              (  clk              ),
        .rst_n            (  rstn             ),
                                                                                  
        .read_addr        (  rd_addr          ),
        .read_id          (  rd_id            ),
        .read_len         (  rd_len           ),
        .read_en          (  rd_en            ),
        .read_done_p      (  rd_done_p        ),
                                                                                 
        .read_ready       (  read_ready       ),
        .read_rdata       (  read_rdata       ),
        .read_rdata_en    (  read_en          ),
                                                                                   
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
        .axi_rresp        (  axi_rresp        )
    );

endmodule
