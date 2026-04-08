`timescale 1ns / 1ps

module mac_tx(
    input                  clk,
    input                  rstn,

    input                  mac_tx_req,      //upper layer 
    input                  mac_tx_ready,    //ready from ip or arp
    input      [7:0]       mac_frame_data,  //data from ip or arp
    input                  mac_tx_end,      //end from ip or arp
    
    output reg             mac_tx_ack,      //mac send data ack for upper layer req
    output reg             mac_data_req,    //request data from arp or ip
    
    output reg             mac_send_end,    //mac frame data send over flag
    
    output reg [7:0]       mac_tx_data,     //mac send data
    output reg             mac_data_valid   //mac send data valid flag
) ;
       
       
    reg  [3:0]          mac_tx_cnt    ;     
    
    reg  [7:0]          mac_frame_data_1d ; 
    reg                 mac_tx_end_dly_1d,mac_tx_end_dly_2d ; 
    reg  [7:0]          mac_tx_data_tmp ;   
    reg                 mac_data_valid_tmp ;
    reg  [15:0]         timeout ;           

    //MAC send FSM
    parameter SEND_IDLE         =  6'b000_001  ;
    parameter SEND_START        =  6'b000_010  ;
    parameter SEND_PREAMBLE     =  6'b000_100  ;
    parameter SEND_DATA         =  6'b001_000  ;
    parameter SEND_FCS          =  6'b010_000  ;
    parameter SEND_END          =  6'b100_000  ;
    
    reg [5:0]     send_state   ;
    reg [5:0]     send_state_n ;
    
    always @(posedge clk)
    begin
        if (~rstn)
            send_state <= SEND_IDLE ;
        else
            send_state <= send_state_n ;
    end
      
    always @(*)
    begin
        case(send_state)
          SEND_IDLE    :
          begin
              if (mac_tx_req)
                  send_state_n = SEND_START ;
              else
                  send_state_n = SEND_IDLE ;
          end
          SEND_START     :
          begin
              if (mac_tx_ready)
                  send_state_n = SEND_PREAMBLE ;
              else
                  send_state_n = SEND_START ;
          end
          SEND_PREAMBLE   :
          begin
              if (mac_tx_cnt == 7)
                  send_state_n = SEND_DATA ;
              else
                  send_state_n = SEND_PREAMBLE ;
          end
          SEND_DATA       :
          begin
              if (mac_tx_end_dly_2d)
                  send_state_n = SEND_FCS ;
              else if (timeout == 16'hffff)
                  send_state_n = SEND_END ;
              else
                  send_state_n = SEND_DATA ;
          end
          SEND_FCS        :
          begin
              if (mac_tx_cnt == 4)
                  send_state_n = SEND_END ;
              else
                  send_state_n = SEND_FCS ;
          end
          SEND_END        :
              send_state_n = SEND_IDLE  ;
          default         :
              send_state_n = SEND_IDLE  ;
        endcase
    end
      
    always @(posedge clk)
    begin
       if (~rstn)
           mac_tx_ack <= 1'b0 ;
       else if (send_state == SEND_START)
           mac_tx_ack <= 1'b1 ;
       else
           mac_tx_ack <= 1'b0 ;
    end 
     
    always @(posedge clk)
    begin
        if (~rstn)
            mac_send_end <= 1'b0 ;
        else if (send_state == SEND_END)
            mac_send_end <= 1'b1 ;
        else
            mac_send_end <= 1'b0 ;
    end
      
    reg             crcen;
    reg             crcre;
    reg [7:0]       crc_din;
    always @(posedge clk)
    begin
        if (~rstn)
        begin
            crcre   <= 1'b1 ;
            crcen   <= 1'b0 ;
            crc_din <= 8'd0 ;
        end
        else if (send_state == SEND_DATA)
        begin
            crcre   <= 1'b0 ;
            crcen   <= 1'b1 ;
            crc_din <= mac_frame_data_1d;
        end
        else if(mac_send_end)
        begin
            crcre   <= 1'b1 ;
            crcen   <= 1'b0 ;
            crc_din <= 8'd0 ;
        end
        else
        begin
            crcre   <= 1'b0 ;
            crcen   <= 1'b0 ;
            crc_din <= 8'd0 ;
        end
    end
         
    wire [7:0] crc_data;
    wire       crc_out_en;
    assign crc_out_en = (send_state == SEND_FCS);
    crc32_gen crc32_gen(
        .clk           (  clk        ),//input         clk       ,
        .rstn          (  rstn       ),//input         rstn      ,
        .crc32_init    (  crcre      ),//input         crc32_init, 
        .crc32_en      (  crcen      ),//input         crc32_en  ,  
        .crc_read      (  crc_out_en ),//input         crc_read  , 
        .data          (  crc_din    ),//input  [7:0]  data      ,     
        .crc_out       (  crc_data   ) //output [7:0]  crc_out 
    );

    // mac_tx_data valid flag signal
    always @(posedge clk)
    begin
        if (~rstn)
            mac_data_valid_tmp <= 1'b0 ;
        //send_state == SEND_PREAMBLE || send_state == SEND_DATA || (send_state == SEND_FCS && mac_tx_cnt < 4)
        else if (send_state == SEND_PREAMBLE || send_state == SEND_DATA || (send_state == SEND_FCS && mac_tx_cnt < 4))
            mac_data_valid_tmp <= 1'b1 ;
        else
            mac_data_valid_tmp <= 1'b0 ;
    end
    
    //assignment mac_tx_data  
    always @(posedge clk)
    begin
        if (~rstn)
            mac_data_valid <= 1'b0 ;
        else
            mac_data_valid <= mac_data_valid_tmp ;
    end
    
    //request data from arp or ip 
    always @(posedge clk)
    begin
        if (~rstn)
            mac_data_req <= 1'b0 ;
        else if (send_state == SEND_PREAMBLE && mac_tx_cnt == 4'd3)
            mac_data_req <= 1'b1 ;
        else
            mac_data_req <= 1'b0 ;
    end
    
    //timeout counter
    always @(posedge clk)
    begin
        if (~rstn)
            timeout <= 16'd0 ;
        else if (send_state == SEND_DATA)
            timeout <= timeout + 1'b1 ;
        else
            timeout <= 16'd0 ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
        begin
            mac_frame_data_1d <= 8'd0 ;
            mac_tx_end_dly_1d <= 1'b0 ;
            mac_tx_end_dly_2d <= 1'b0;
        end
        else
        begin
            mac_frame_data_1d <= mac_frame_data ;
            mac_tx_end_dly_1d     <= mac_tx_end ;
            mac_tx_end_dly_2d     <= mac_tx_end_dly_1d ;
        end
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            mac_tx_cnt <= 4'd0 ;
        else if (send_state == SEND_PREAMBLE || send_state == SEND_FCS)
            mac_tx_cnt <= mac_tx_cnt + 1'b1 ;
        else
            mac_tx_cnt <= 4'd0 ;
    end
    //mac send data frame
    always @(posedge clk)
    begin
        if (~rstn)
            mac_tx_data_tmp <= 8'h00 ;
        else if (send_state == SEND_PREAMBLE)
        begin
            if (mac_tx_cnt < 7)
                mac_tx_data_tmp <= 8'h55 ;
            else
                mac_tx_data_tmp <= 8'hd5 ;
        end
        else if (send_state == SEND_DATA)
            mac_tx_data_tmp <= mac_frame_data_1d ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            mac_tx_data <= 8'h00 ;
        else if (send_state == SEND_FCS)
        begin
            case(mac_tx_cnt)
                4'd0    : mac_tx_data <= mac_tx_data_tmp ;
                4'd1    , 
                4'd2    , 
                4'd3    , 
                4'd4    : mac_tx_data <= crc_data;
                default : mac_tx_data <= 8'h00 ;
            endcase
        end
        else
            mac_tx_data <= mac_tx_data_tmp ;
    end
    
endmodule
