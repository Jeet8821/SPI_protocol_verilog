`timescale 1ns / 1ps
module spi_slave(
    input        clk, rst,
    input        sclk, ss, mosi,
    input        fd,             // from the master's control_block
    input  [7:0] s_data,
    output [7:0] rx_data,
    output       miso,
    output       done
);
    wire sclk_rise, sclk_fall;
    wire D;

    edge_detect sclk_edge (
        .clk(clk), .rst(rst), .sig(sclk),
        .rise(sclk_rise), .fall(sclk_fall)
    );

    shift_reg_s sr (
        .clk(clk), .rst(rst),
        .en_reg(~ss),
        .din(mosi),
        .s_data(s_data),
        .shift_en(sclk_fall),
        .rx_data(rx_data),
        .D(D),
        .c(done)
    );

    assign miso = fd ? D : 1'b0;   // silent in half duplex
endmodule