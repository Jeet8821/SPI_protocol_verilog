`timescale 1ns / 1ps
module shift_reg_s(
    input        clk, rst, en_reg,
    input        shift_en,         // sclk_fall
    input        din,              // mosi
    input  [7:0] s_data,           // reply byte
    output reg [7:0] rx_data,
    output       D,                // reply bit (MSB first)
    output reg   c
);
    reg [3:0] count;

    wire       load = ~en_reg;
    wire       en   = load | (en_reg & shift_en);
    wire [7:0] q;
    wire [7:0] d;

    assign d[0] = load ? s_data[0] : din;
    assign d[1] = load ? s_data[1] : q[0];
    assign d[2] = load ? s_data[2] : q[1];
    assign d[3] = load ? s_data[3] : q[2];
    assign d[4] = load ? s_data[4] : q[3];
    assign d[5] = load ? s_data[5] : q[4];
    assign d[6] = load ? s_data[6] : q[5];
    assign d[7] = load ? s_data[7] : q[6];

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
            count   <= 4'd0;
            c       <= 1'b0;
            rx_data <= 8'd0;
        end
        else begin
            c <= 1'b0;
            if (load)
                count <= 4'd0;
            else if (shift_en) begin
                if (count == 4'd7) begin
                    count   <= 4'd0;
                    c       <= 1'b1;
                    rx_data <= {q[6:0], din};
                end
                else
                    count <= count + 1'b1;
            end
        end
    end
endmodule