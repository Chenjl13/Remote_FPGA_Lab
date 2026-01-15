module top(
   input    wire  clk_50M        ,
   output   wire  da_clk         ,
   output   wire  [7:0]da_data   
   );

wire rst_n ;
wire clk_125M ;

reg   [10:0]rom_addr ;
wire  [7:0]rom_data_out ;

assign da_clk = clk_125M  ;
assign da_data = rom_data_out  ;

always @(negedge clk_125M or negedge rst_n) begin
   if (!rst_n)
      rom_addr <= 11'd0 ;
   else if (rom_addr >= 11'd1023)
      rom_addr <= 11'd0 ;
   else
      rom_addr <= rom_addr + 10'd1     ;       
end

ad_clock_125m u_pll (
  .clkin1(clk_50M),       
  .pll_lock(rst_n),         
  .clkout0(clk_125M)      
);

rom_triangular_wave u_rom (
  .addr(rom_addr[9:0]),           
  .clk(clk_125M),            
  .rst(1'b0),                
  .rd_data(rom_data_out)     
);

endmodule