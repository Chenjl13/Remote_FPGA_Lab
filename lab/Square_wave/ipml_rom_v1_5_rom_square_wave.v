module ipml_rom_v1_5_rom_square_wave
 #(
    parameter  c_SIM_DEVICE     = "LOGOS"      ,
    parameter  c_ADDR_WIDTH     = 10           ,           
    parameter  c_DATA_WIDTH     = 32           ,           
    parameter  c_OUTPUT_REG     = 0            ,           
    parameter  c_RD_OCE_EN      = 0            ,
    parameter  c_CLK_EN         = 0            ,
    parameter  c_ADDR_STROBE_EN = 0            ,
    parameter  c_RESET_TYPE     = "ASYNC_RESET",           
    parameter  c_POWER_OPT      = 0            ,           
    parameter  c_CLK_OR_POL_INV = 0            ,                 
    parameter  c_INIT_FILE      = "NONE"       ,           
    parameter  c_INIT_FORMAT    = "BIN"                  
    
 )
  (
   
    input  wire [c_ADDR_WIDTH-1 : 0]  addr        ,
    output wire [c_DATA_WIDTH-1 : 0]  rd_data     ,
    input  wire                       clk         ,
    input  wire                       clk_en      ,
    input  wire                       addr_strobe ,
    input  wire                       rst         ,
    input  wire                       rd_oce       
  );

ipml_spram_v1_5_rom_square_wave
 #(
    .c_SIM_DEVICE     (c_SIM_DEVICE),
    .c_ADDR_WIDTH     (c_ADDR_WIDTH),                                    
    .c_DATA_WIDTH     (c_DATA_WIDTH),                                     
    .c_OUTPUT_REG     (c_OUTPUT_REG),                                      
    .c_RD_OCE_EN      (c_RD_OCE_EN),
    .c_ADDR_STROBE_EN (c_ADDR_STROBE_EN),
    .c_CLK_EN         (c_CLK_EN),
    .c_RESET_TYPE     (c_RESET_TYPE),           
    .c_POWER_OPT      (c_POWER_OPT),                        
    .c_CLK_OR_POL_INV (c_CLK_OR_POL_INV),             
    .c_INIT_FILE      (c_INIT_FILE),                            
    .c_INIT_FORMAT    (c_INIT_FORMAT),                           
    .c_WR_BYTE_EN     (0),                                              
    .c_BE_WIDTH       (1),                      
    .c_RAM_MODE       ("ROM"),
    .c_WRITE_MODE     ("NORMAL_WRITE")                                    
 )  U_ipml_spram_rom_square_wave                               
  (
   
    .addr        (addr),
    .wr_data     (),
    .rd_data     (rd_data),
    .wr_en       (1'b0),
    .clk         (clk),
    .clk_en      (clk_en),
    .addr_strobe (addr_strobe),
    .rst         (rst),
    .wr_byte_en  (),
    .rd_oce      (rd_oce) 
  );
 

endmodule

