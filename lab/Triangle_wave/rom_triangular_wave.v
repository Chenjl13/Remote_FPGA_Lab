module rom_triangular_wave
    (
     addr        ,
     rd_data     ,
     clk         ,
     
     rst
    );


localparam ADDR_WIDTH = 10 ; 

localparam DATA_WIDTH = 8 ; 

localparam OUTPUT_REG = 0 ; 

localparam RD_OCE_EN = 0 ; 

localparam CLK_OR_POL_INV = 0 ; 

localparam RESET_TYPE = "ASYNC" ; 

localparam POWER_OPT = 0 ; 

localparam INIT_FILE = "D:/admin/desktop/AD_DA_50H/AD9708_triangular_wave/triangular_1024.dat" ; 

localparam INIT_FORMAT = "HEX" ; 

localparam CLK_EN  = 0 ; 

localparam ADDR_STROBE_EN  = 0 ; 

localparam INIT_EN = 1 ; 

localparam  RESET_TYPE_SEL  = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                              (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE";
localparam  DEVICE_NAME     = "PGL50G";

localparam  DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? 10 : DATA_WIDTH;
localparam  SIM_DEVICE      = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";


input  [ADDR_WIDTH-1 : 0]     addr        ;
output [DATA_WIDTH-1 : 0]     rd_data     ;
input                         clk         ;

input                         rst         ;


wire [ADDR_WIDTH-1 : 0]       addr        ;
wire [DATA_WIDTH-1 : 0]       rd_data     ;
wire                          clk         ;
wire                          clk_en      ;
wire                          addr_strobe ;
wire                          rst         ;
wire                          rd_oce      ;

wire                          rd_oce_mux      ;
wire                          clk_en_mux      ;
wire                          addr_strobe_mux ;

wire [DATA_WIDTH_WRAP-1 : 0]  rd_data_wrap;

assign rd_oce_mux      = (RD_OCE_EN      == 1) ? rd_oce      :
                         (OUTPUT_REG     == 1) ? 1'b1 : 1'b0 ;
assign clk_en_mux      = (CLK_EN         == 1) ? clk_en      : 1'b1 ;
assign addr_strobe_mux = (ADDR_STROBE_EN == 1) ? addr_strobe : 1'b0 ;

assign rd_data         = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? rd_data_wrap[DATA_WIDTH-1 : 0] : rd_data_wrap;

ipml_rom_v1_5_rom_triangular_wave
    #(
    .c_SIM_DEVICE       ( SIM_DEVICE            ),
    .c_ADDR_WIDTH       ( ADDR_WIDTH            ), 
    .c_DATA_WIDTH       ( DATA_WIDTH_WRAP       ), 
    .c_OUTPUT_REG       ( OUTPUT_REG            ), 
    .c_RD_OCE_EN        ( RD_OCE_EN             ),
    .c_CLK_EN           ( CLK_EN                ),
    .c_ADDR_STROBE_EN   ( ADDR_STROBE_EN        ),
    .c_RESET_TYPE       ( RESET_TYPE_SEL        ), 
    .c_POWER_OPT        ( POWER_OPT             ), 
    .c_CLK_OR_POL_INV   ( CLK_OR_POL_INV        ), 
    .c_INIT_FILE        ( "NONE"                ), 
    .c_INIT_FORMAT      ( INIT_FORMAT           )  
    ) U_ipml_rom_rom_triangular_wave
    (
    .addr               ( addr                  ),
    .rd_data            ( rd_data_wrap          ),
    .clk                ( clk                   ),
    .clk_en             ( clk_en_mux            ),
    .addr_strobe        ( addr_strobe_mux       ),
    .rst                ( rst                   ),
    .rd_oce             ( rd_oce_mux            )
  );

endmodule
