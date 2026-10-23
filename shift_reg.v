`timescale 1ns / 1ps



module shift_reg(
    input sclk,rst,en_reg,
    input m_data,
    output reg D,
    output reg c
    );
    reg [3:0] count;
    wire d0,d1,d2,d3,d4,d5,d6;
    d_ff ff0(.clk(sclk), .rst(rst), .en(en_reg), .d(m_data), .q(d0));
    d_ff ff1(.clk(sclk), .rst(rst), .en(en_reg), .d(d0), .q(d1));
    d_ff ff2(.clk(sclk), .rst(rst), .en(en_reg), .d(d1), .q(d2));
    d_ff ff3(.clk(sclk), .rst(rst), .en(en_reg), .d(d2), .q(d3));
    d_ff ff4(.clk(sclk), .rst(rst), .en(en_reg), .d(d3), .q(d4));
    d_ff ff5(.clk(sclk), .rst(rst), .en(en_reg), .d(d4), .q(d5));
    d_ff ff6(.clk(sclk), .rst(rst), .en(en_reg), .d(d5), .q(d6));
    d_ff ff7(.clk(sclk), .rst(rst), .en(en_reg), .d(d6), .q(D));
    always @(posedge sclk or posedge rst)begin
        if (rst) begin
            count <= 4'd0;
            c     <= 1'b0;
        end
        else if(c)begin
        c <= 0;
        count <= 4'b0;
        end
        else if (en_reg && !c) begin
            if (count == 4'd7) begin
                count <= 4'd0;
                c     <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
