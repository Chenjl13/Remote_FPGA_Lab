`timescale 1ns / 1ps
`define UD #1
module iic_dri #(
    parameter            CLK_FRE = 27'd50_000_000,
    parameter            IIC_FREQ = 20'd400_000,
    parameter            T_WR = 10'd5,
    parameter            ADDR_BYTE = 2'd1,
    parameter            LEN_WIDTH = 8'd3,
    parameter            DATA_BYTE = 2'd1
)(                       
    input                clk,
    input                rstn,
    input                pluse,
    input  [7:0]         device_id,
    input                w_r,
    input  [LEN_WIDTH:0] byte_len,
    input  [ADDR_BYTE*8 - 1:0] addr,
    input  [7:0]         data_in,
    output reg           busy=0,
    output reg           byte_over=0,
    output reg[7:0]      data_out,
    output               scl,
    input                sda_in,
    output   reg         sda_out=1'b1,
    output               sda_out_en
);

    localparam CLK_DIV = CLK_FRE/IIC_FREQ;
    localparam ID_ADDR_BYTE = ADDR_BYTE + 1'b1;
    localparam DATA_SET = CLK_DIV>>2;
    localparam T_WR_DELAY = T_WR*CLK_FRE/1000_000;

    reg [20:0] fre_cnt;
    always @(posedge clk)
    begin
        if(!rstn)
            fre_cnt <= `UD 21'd0;
        else if(fre_cnt == CLK_DIV - 1'b1)
            fre_cnt <= `UD 21'd0;
        else
            fre_cnt <= `UD fre_cnt + 1'b1;
    end
    
    wire  full_cycle;
    wire  half_cycle;
    assign full_cycle = (fre_cnt == CLK_DIV - 1'b1) ? 1'b1 : 1'b0;
    assign half_cycle = (fre_cnt == (CLK_DIV>>1'b1) - 1'b1) ? 1'b1 : 1'b0;
    
    wire start_h;
    wire dsu;
    assign start_h = (fre_cnt == DATA_SET - 1'b1) ? 1'b1 : 1'b0;
    assign dsu = (fre_cnt == (CLK_DIV>>1'b1) + DATA_SET - 1'b1) ? 1'b1 : 1'b0;
    
    wire   start;
    reg    start_en;
    reg    pluse_1d,pluse_2d,pluse_3d;
    always @(posedge clk)
    begin
        if(!rstn)
        begin
            pluse_1d <= `UD 1'b0;
            pluse_2d <= `UD 1'b0;
            pluse_3d <= `UD 1'b0;
        end
        else
        begin
            pluse_1d <= `UD pluse;
            pluse_2d <= `UD pluse_1d;
            pluse_3d <= `UD pluse_2d;
        end
    end
    
    always @ (posedge clk)
    begin
        if(start || (!rstn))
            start_en <= `UD 1'b0;
        else if(~pluse_3d & pluse_2d)
            start_en <= `UD 1'b1;
        else
            start_en <= `UD start_en;
    end
    
    assign start = (start_en & full_cycle) ? 1'b1 : 1'b0;
    
    reg w_r_1d=1'b0,w_r_2d=1'b0;
    always @(posedge clk)
    begin
        if(!rstn)
        begin
            w_r_1d <= `UD 1'b0;
            w_r_2d <= `UD 1'b0;
        end
        else
        begin
            w_r_1d <= `UD w_r;
            w_r_2d <= `UD w_r_1d;
        end
    end

    localparam IDLE   = 3'd0;
    localparam S_START= 3'd1;
    localparam SEND   = 3'd2;
    localparam S_ACK  = 3'd3;
    localparam RECEIV = 3'd4;
    localparam R_ACK  = 3'd5;
    localparam STOP   = 3'd6;
    reg [2:0] state;
    reg [2:0] state_n;
    reg [2:0] trans_bit = 3'd0;
    
    reg [LEN_WIDTH :0] trans_byte = 5'd0;
    reg [LEN_WIDTH :0] trans_byte_max = 5'd0;
    reg [7:0] send_data=8'd0;
    reg [7:0] receiv_data=8'd0;
    reg       trans_en=0;
    reg       scl_out= 1'b1;
    
    assign scl = scl_out;
    
    always @ (posedge clk)
    begin
        if(start)
            trans_en <= `UD 1'b1;
        else if(state == STOP && start_h)
            trans_en <= `UD 1'b0;
        else
            trans_en <= `UD trans_en;
    end
    
    reg           twr_en=0;
    reg  [26:0]   twr_cnt=0;
    always @(posedge clk)
    begin
        if(state == STOP && dsu)
            twr_en <= `UD 1'b1;
        else if(twr_cnt == T_WR_DELAY)
            twr_en <= `UD 1'b0;
        else
            twr_en <= `UD twr_en;    
    end
    
    always @(posedge clk)
    begin
        if(twr_en)
        begin
            if(twr_cnt == T_WR_DELAY)
                twr_cnt <= `UD 1'b0;
            else
                twr_cnt <= `UD twr_cnt + 1'b1; 
        end
        else
            twr_cnt <= `UD twr_cnt;
    end
    
    always @(posedge clk)
    begin
        if(start_en)
            busy <= `UD 1'b1;
        else if(twr_cnt == T_WR_DELAY)
            busy <= `UD 1'b0;
        else
            busy <= `UD busy;
    end
    
    always @(posedge clk)
    begin
        if(trans_en)
        begin
            if(half_cycle || full_cycle)
                scl_out <= ~scl_out;
            else
                scl_out <= scl_out;
        end
        else
            scl_out <= 1'b1;
    end
    
    assign sda_out_en = ((state == S_ACK) || (state == RECEIV)) ? 1'b0 : 1'b1;
    
    always @(posedge clk)
    begin
        if(start)
            send_data <= `UD {device_id[7:1],1'b0};
        else if(state == S_ACK && full_cycle)
        begin
            if(ADDR_BYTE == 2'd1)
            begin
                case(trans_byte)
                    5'd0 : send_data <= `UD {device_id[7:1],1'b0};
                    5'd1 : send_data <= `UD addr[7:0];
                    5'd2 : send_data <= `UD (w_r_2d) ? data_in : {device_id[7:1],1'b1};
                    default: send_data <= `UD data_in;
                endcase
            end
            else
            begin
                case(trans_byte)
                    5'd0 : send_data <= `UD {device_id[7:1],1'b0};
                    5'd1 : send_data <= `UD addr[7:0];
                    5'd2 : send_data <= `UD addr[15:8];
                    5'd3 : send_data <= `UD (w_r_2d) ? data_in : {device_id[7:1],1'b1};
                    default: send_data <= `UD data_in;
                endcase
            end
        end
        else
            send_data <= `UD send_data;
    end
    
    always @(posedge clk)
    begin
        if(start)
        begin
            if(w_r_2d)
                trans_byte_max <= `UD ADDR_BYTE + byte_len + 2'd1;
            else
                trans_byte_max <= `UD ADDR_BYTE + byte_len + 2'd2;
        end
        else
            trans_byte_max <= `UD trans_byte_max;
    end
    
    always @(posedge clk)
    begin
        case(state)
            IDLE  : sda_out <= `UD 1'b1;
            S_START :
            begin
                if(start_h)
                    sda_out <= `UD 1'b0;
                else if(dsu)
                    sda_out <= `UD send_data[7-trans_bit];
                else
                    sda_out <= `UD sda_out;
            end
            SEND  : sda_out <= `UD send_data[7-trans_bit];
            S_ACK :
            begin
                if(trans_byte == ID_ADDR_BYTE && dsu && !w_r_2d)
                    sda_out <= `UD 1'b1;
                else
                    sda_out <= `UD 1'h0;
            end
            R_ACK :
            begin
                if(trans_byte < trans_byte_max)
                    sda_out <= `UD 1'b0;
                else
                begin
                    if(dsu)
                        sda_out <= `UD 1'b0;
                    else
                        sda_out <= `UD 1'b1;
                end
            end
            STOP  :
            begin
                if(start_h)
                    sda_out <= `UD 1'b1;
                else
                    sda_out <= `UD sda_out;
            end
            default: sda_out <= `UD 1'b1;
        endcase
    end
    
    always @(posedge clk)
    begin
        if(state == RECEIV)
        begin
            if(full_cycle)
                receiv_data <= `UD {receiv_data[6:0],sda_in};
            else
                receiv_data <= `UD receiv_data;
        end
        else
            receiv_data <= `UD 8'd0;
    end
    
    always @(posedge clk)
    begin
        if(state == RECEIV && trans_bit == 3'd7 && half_cycle)
            data_out <= `UD receiv_data;
        else
            data_out <= `UD data_out;
    end
    
    always @(posedge clk)
    begin
        if(w_r_2d)
        begin
            if(trans_byte > ID_ADDR_BYTE - 1'b1 && dsu && trans_bit == 3'd7)
                byte_over <= `UD 1'b1;
            else
                byte_over <= `UD 1'b0;
        end
        else
        begin
            if(trans_byte > ID_ADDR_BYTE && dsu && trans_bit == 3'd7)
                byte_over <= `UD 1'b1;
            else
                byte_over <= `UD 1'b0;
        end
    end
    
    always @(posedge clk)
    begin
        if(state == SEND || state == RECEIV)
        begin
            if(dsu)
                trans_bit <= `UD trans_bit + 1'b1;
            else
                trans_bit <= `UD trans_bit;
        end
        else
            trans_bit <= `UD 3'd0;
    end
    
    always @(posedge clk)
    begin
        if(start)
            trans_byte <= `UD 5'd0;
        else if(state == SEND || state == RECEIV)
        begin
            if(dsu && trans_bit == 3'd7)
                trans_byte <= `UD trans_byte + 1'b1;
            else
                trans_byte <= `UD trans_byte;
        end
        else
            trans_byte <= `UD trans_byte;
    end
    
    always @(posedge clk)
    begin
        if(!rstn)
            state <= `UD IDLE;
        else
            state <= `UD state_n;
    end
    
    always @(*)
    begin
        state_n = state;
        case(state)
            IDLE  : if(start) state_n = S_START;
            S_START : if(dsu) state_n = SEND;
            SEND  : if(trans_bit == 3'd7 & dsu) state_n = S_ACK;
            S_ACK :
            begin
                if(dsu)
                begin
                    if(w_r_2d)
                    begin
                        if(trans_byte < ID_ADDR_BYTE)
                            state_n = SEND;
                        else if(trans_byte < trans_byte_max)
                            state_n = SEND;
                        else
                            state_n = STOP;
                    end
                    else
                    begin
                        if(trans_byte < ID_ADDR_BYTE)
                            state_n = SEND;
                        else if(trans_byte == ID_ADDR_BYTE)
                            state_n = S_START;
                        else
                            state_n = RECEIV;
                    end
                end
            end
            RECEIV: if(trans_bit == 3'd7 & dsu) state_n = R_ACK;
            R_ACK :
            begin
                if(dsu)
                begin
                    if(trans_byte < trans_byte_max)
                        state_n = RECEIV;
                    else
                        state_n = STOP;
                end
            end
            STOP  : if(dsu) state_n = IDLE;
            default: state_n = IDLE;
        endcase
    end

endmodule
