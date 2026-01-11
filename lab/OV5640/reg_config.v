`timescale 1ns / 1ps
`define UD #1

module reg_config(     
    input clk_25M,
    input camera_rstn,
    input initial_en,
    output reg_conf_done,
    output i2c_sclk,
    inout i2c_sdat,
    output reg clock_20k,
    output reg [8:0] reg_index
);

    reg [15:0] clock_20k_cnt;
    reg [1:0]  config_step;	  
    reg [31:0] i2c_data;
    reg [23:0] reg_data;
    reg        start;
    reg        reg_conf_done_reg;
	  
    i2c_com u1(
        .clock_i2c (clock_20k),
        .camera_rstn(camera_rstn),
        .ack        (ack),
        .i2c_data  (i2c_data),
        .start     (start),
        .tr_end    (tr_end),
        .i2c_sclk  (i2c_sclk),
        .i2c_sdat  (i2c_sdat)
    );

    assign reg_conf_done = reg_conf_done_reg;

    always @(posedge clk_25M)   
    begin
        if(!camera_rstn) begin
            clock_20k <= 0;
            clock_20k_cnt <= 0;
        end
        else if(clock_20k_cnt < 1249)
            clock_20k_cnt <= clock_20k_cnt + 1'b1;
        else begin
            clock_20k <= !clock_20k;
            clock_20k_cnt <= 0;
        end
    end

    always @(posedge clock_20k)    
    begin
        if(!camera_rstn) begin
            config_step <= 0;
            start <= 0;
            reg_index <= 0;
            reg_conf_done_reg <= 0;
        end
        else begin
            if(reg_conf_done_reg == 1'b0) begin
                if(reg_index < 357) begin
                    case(config_step)
                        0: begin
                            i2c_data <= {8'h78, reg_data};
                            start <= 1;
                            config_step <= 1;
                        end
                        1: begin
                            if(tr_end) begin
                                start <= 0;
                                config_step <= 2;
                            end
                        end
                        2: begin
                            reg_index <= reg_index + 1'b1;
                            config_step <= 0;
                        end
                    endcase
                end
                else
                    reg_conf_done_reg <= 1'b1;
            end
        end
    end
			
    always @(reg_index)   
    begin
        case(reg_index)
            0   : reg_data <= 24'h310311;
            1   : reg_data <= 24'h300882;
            102 : reg_data <= 24'h300842;
            103 : reg_data <= 24'h310303;
            104 : reg_data <= 24'h3017ff;
            105 : reg_data <= 24'h3018ff;
            106 : reg_data <= 24'h30341A;
            107 : reg_data <= 24'h303713;
            108 : reg_data <= 24'h310801;
            109 : reg_data <= 24'h363036;
            110 : reg_data <= 24'h36310e;
            111 : reg_data <= 24'h3632e2;
            112 : reg_data <= 24'h363312;
            113 : reg_data <= 24'h3621e0;
            114 : reg_data <= 24'h3704a0;
            115 : reg_data <= 24'h37035a;
            116 : reg_data <= 24'h371578;
            117 : reg_data <= 24'h371701;
            118 : reg_data <= 24'h370b60;
            119 : reg_data <= 24'h37051a;
            120 : reg_data <= 24'h390502;
            121 : reg_data <= 24'h390610;
            122 : reg_data <= 24'h39010a;
            123 : reg_data <= 24'h373112;
            124 : reg_data <= 24'h360008;
            125 : reg_data <= 24'h360133;
            126 : reg_data <= 24'h302d60;
            127 : reg_data <= 24'h362052;
            128 : reg_data <= 24'h371b20;
            129 : reg_data <= 24'h471c50;
            130 : reg_data <= 24'h3a1343;
            131 : reg_data <= 24'h3a1800;
            132 : reg_data <= 24'h3a19f8;
            133 : reg_data <= 24'h363513;
            134 : reg_data <= 24'h363603;
            135 : reg_data <= 24'h363440;
            136 : reg_data <= 24'h362201;
            137 : reg_data <= 24'h3c0134;
            138 : reg_data <= 24'h3c0428;
            139 : reg_data <= 24'h3c0598;
            140 : reg_data <= 24'h3c0600;
            141 : reg_data <= 24'h3c0708;
            142 : reg_data <= 24'h3c0800;
            143 : reg_data <= 24'h3c091c;
            144 : reg_data <= 24'h3c0a9c;
            145 : reg_data <= 24'h3c0b40;
            146 : reg_data <= 24'h381000;
            147 : reg_data <= 24'h381110;
            148 : reg_data <= 24'h381200;
            149 : reg_data <= 24'h370864;
            150 : reg_data <= 24'h400102;
            151 : reg_data <= 24'h40051a;
            152 : reg_data <= 24'h300000;
            153 : reg_data <= 24'h3004ff;
            154 : reg_data <= 24'h300e58;
            155 : reg_data <= 24'h302e00;
            156 : reg_data <= 24'h430060;
            157 : reg_data <= 24'h501f01;
            158 : reg_data <= 24'h440e00;
            159 : reg_data <= 24'h5000a7;
            default: reg_data <= 24'hffffff;
        endcase      
    end

endmodule
