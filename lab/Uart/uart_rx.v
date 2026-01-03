`timescale 1ns / 1ps

`define UD #1

module uart_rx # (
    parameter            BPS_NUM     =    16'd434
)
(
      input             clk,
      input             uart_rx,
    
      output reg [7:0]  rx_data,
      output reg        rx_en,
      output            rx_finish
);

    localparam  IDLE         = 4'h0;    
    localparam  RECEIV_START = 4'h1;    
    localparam  RECEIV_DATA  = 4'h2;    
    localparam  RECEIV_STOP  = 4'h3;    
    localparam  RECEIV_END   = 4'h4;    

    reg    [2:0]        rx_state=0;       
    reg    [2:0]        rx_state_n=0;     
    reg    [7:0]        rx_data_reg;      
    reg                 uart_rx_1d;       
    reg                 uart_rx_2d;       
    wire                start;            
    reg    [15:0]       clk_div_cnt;      
    

    always @ (posedge clk) 
    begin
         uart_rx_1d <= `UD uart_rx;
         uart_rx_2d <= `UD  uart_rx_1d;
    end

    assign start     = (!uart_rx) && (uart_rx_1d || uart_rx_2d);
    assign rx_finish = (rx_state == RECEIV_END);

    always @ (posedge clk)
    begin
        if(rx_state == IDLE || clk_div_cnt == BPS_NUM)
            clk_div_cnt   <= `UD 16'h0;
        else
            clk_div_cnt   <= `UD clk_div_cnt + 16'h1;
    end
    
    reg    [2:0]      rx_bit_cnt=0;    
    always @ (posedge clk)
    begin
        if(rx_state == IDLE)
            rx_bit_cnt <= `UD 3'h0;
        else if((rx_bit_cnt == 3'h7) && (clk_div_cnt == BPS_NUM))
            rx_bit_cnt <= `UD 3'h0;
        else if((rx_state == RECEIV_DATA) && (clk_div_cnt == BPS_NUM))
            rx_bit_cnt <= `UD rx_bit_cnt + 3'h1;
        else 
            rx_bit_cnt <= `UD rx_bit_cnt;
    end

    always @(posedge clk)
    begin
        rx_state <= rx_state_n;
    end
    
    always @ (*)
    begin
      case(rx_state)
          IDLE       :  
          begin
              if(start)                                     
                  rx_state_n = RECEIV_START;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_START    :  
          begin
              if(clk_div_cnt == BPS_NUM)                    
                  rx_state_n = RECEIV_DATA;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_DATA    :  
          begin
              if(rx_bit_cnt == 3'h7 && clk_div_cnt == BPS_NUM) 
                  rx_state_n = RECEIV_STOP;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_STOP    :  
          begin
              if(clk_div_cnt == BPS_NUM)                       
                  rx_state_n = RECEIV_END;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_END    :  
          begin
              if(!uart_rx_1d)                                 
                  rx_state_n = RECEIV_START;
              else                                             
                  rx_state_n = IDLE;
          end
          default    :  rx_state_n = IDLE;
      endcase
    end

    always @ (posedge clk)
    begin
        case(rx_state)
            IDLE         ,
            RECEIV_START :                               
            begin
                rx_en <= `UD 1'b0;
                rx_data_reg <= `UD 8'h0;
            end
            RECEIV_DATA  :  
            begin
                if(clk_div_cnt == BPS_NUM[15:1])       
                    rx_data_reg  <= `UD {uart_rx , rx_data_reg[7:1]};  
            end
            RECEIV_STOP  : 
            begin
                rx_en   <= `UD 1'b1;                    
                rx_data <= `UD rx_data_reg;             
            end
            RECEIV_END    :  
            begin
                rx_data_reg <= `UD 8'h0;
            end
            default:    rx_en <= `UD 1'b0;
        endcase
    end

endmodule




