`timescale 1ns / 1ps
module shift_reg(
    input        clk, rst, en_reg,
    input        fd,
    input  [7:0] m_data,
    input        shift_en,         // sclk_fall
    input        miso,
    output       D,
    output reg   c,
    output reg [7:0] rx_data,
    output reg   rx_valid          // 1-clk pulse, only in full duplex
);
    reg [3:0] count;

    wire       load = ~en_reg;
    wire       en   = load | (en_reg & shift_en);
    wire [7:0] q;
    wire [7:0] d;

    wire sin = fd ? miso : 1'b0;   // serial input

    assign d[0] = load ? m_data[0] : sin;
    assign d[1] = load ? m_data[1] : q[0];
    assign d[2] = load ? m_data[2] : q[1];
    assign d[3] = load ? m_data[3] : q[2];
    assign d[4] = load ? m_data[4] : q[3];
    assign d[5] = load ? m_data[5] : q[4];
    assign d[6] = load ? m_data[6] : q[5];
    assign d[7] = load ? m_data[7] : q[6];

    d_ff ff0(.clk(clk), .rst(rst), .en(en), .d(d[0]), .q(q[0]));
    d_ff ff1(.clk(clk), .rst(rst), .en(en), .d(d[1]), .q(q[1]));
    d_ff ff2(.clk(clk), .rst(rst), .en(en), .d(d[2]), .q(q[2]));
    d_ff ff3(.clk(clk), .rst(rst), .en(en), .d(d[3]), .q(q[3]));
    d_ff ff4(.clk(clk), .rst(rst), .en(en), .d(d[4]), .q(q[4]));
    d_ff ff5(.clk(clk), .rst(rst), .en(en), .d(d[5]), .q(q[5]));
    d_ff ff6(.clk(clk), .rst(rst), .en(en), .d(d[6]), .q(q[6]));
    d_ff ff7(.clk(clk), .rst(rst), .en(en), .d(d[7]), .q(q[7]));

    assign D = q[7];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count    <= 4'd0;
            c        <= 1'b0;
            rx_data  <= 8'd0;
            rx_valid <= 1'b0;
        end
        else begin
            c        <= 1'b0;
            rx_valid <= 1'b0;
            if (load)
                count <= 4'd0;
            else if (shift_en) begin
                if (count == 4'd7) begin
                    count <= 4'd0;
                    c     <= 1'b1;
                    if (fd) begin
                        rx_data  <= {q[6:0], miso};   // last bit still at miso
                        rx_valid <= 1'b1;
                    end
                end
                else
                    count <= count + 1'b1;
            end
        end
    end
endmodule
