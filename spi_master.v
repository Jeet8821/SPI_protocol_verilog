`timescale 1ns / 1ps
module spi_master(
    input         clk,
    input         rst,
    input         start,
    input         duplex,
    input  [7:0]  m_data,
    input  [31:0] half_period,
    input         miso,

    output        sclk,
    output        ss,
    output        D,
    output        c,
    output        fd,            // goes to the slave
    output [7:0]  rx_data,       // master's received byte
    output        rx_valid
);
    wire D_int, en, en_reg;
    wire sclk_rise, sclk_fall;

    clock_divider clk_div (
        .clk(clk), .en(en), .rst(rst), .half_period(half_period),
        .sclk(sclk), .sclk_rise(sclk_rise), .sclk_fall(sclk_fall)
    );

    control_block ctrl (
        .start(start), .rst(rst), .c(c), .clk(clk), .duplex(duplex),
        .en(en), .en_reg(en_reg), .ss(ss), .fd(fd)
    );

    shift_reg shift (
        .clk(clk), .rst(rst), .en_reg(en_reg), .fd(fd),
        .m_data(m_data), .shift_en(sclk_fall), .miso(miso),
        .D(D_int), .c(c), .rx_data(rx_data), .rx_valid(rx_valid)
    );

    assign D = D_int & ~ss;
endmodule
