`timescale 1ns / 1ps
`define UD #1

module uart_top(
    input         clk,
    input         uart_rx,
    
    output  [7:0] led,
    output        uart_tx
);

   parameter      BPS_NUM = 16'd434;
   
    wire           tx_busy;         
    wire           rx_finish;       
    wire    [7:0]  rx_data;         
                                    
    wire    [7:0]  tx_data;         
                                    
    wire           tx_en;           

    wire rx_en;

    reg  [7:0] receive_data;
    always @(posedge clk)  receive_data <= led;
    uart_data_gen uart_data_gen(
        .clk                  (  clk      ),
        .read_data            (  receive_data ),
        .tx_busy              (  tx_busy      ),
        .write_max_num        (  8'h14        ),
        .write_data           (  tx_data      ),
        .write_en             (  tx_en        ) 
    );
    
    uart_tx #(
         .BPS_NUM            (  BPS_NUM       ) 
     )
     u_uart_tx(
        .clk                 (  clk         ),         
        .tx_data             (  tx_data       ),        
        .tx_pluse            (  tx_en         ),       
        .uart_tx             (  uart_tx       ),                               
        .tx_busy             (  tx_busy       )            
    );                                             
                                                      
    uart_rx #(
         .BPS_NUM            (  BPS_NUM       ) 
     )
     u_uart_rx (                        
        .clk                 (  clk           ),                    
        .uart_rx             (  uart_rx       ),         
        .rx_data             (  rx_data       ),                          
        .rx_en               (  rx_en         ),                        
        .rx_finish           (  rx_finish     )  
    );                                            
                                                  
    assign led = rx_data;
    
endmodule
