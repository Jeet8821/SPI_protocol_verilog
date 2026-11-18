`timescale 1ns / 1ps
module spi_top(
    input         clk,
    input         rst,
    input         start,
    input         duplex,
    input  [7:0]  m_data,
    input  [7:0]  s_data,
    input  [31:0] half_period,

    output        sclk,
    output        ss,
    output        mosi,
    output        c,
    output [7:0]  rx_data,        // slave received
    output        done,
    output [7:0]  master_rx,      // master received
    output        master_rx_valid
);
    wire miso, fd;

    spi_master master (
        .clk(clk), .rst(rst), .start(start), .duplex(duplex),
        .m_data(m_data), .half_period(half_period), .miso(miso),
        .sclk(sclk), .ss(ss), .D(mosi), .c(c), .fd(fd),
        .rx_data(master_rx), .rx_valid(master_rx_valid)
    );

    spi_slave slave (
        .clk(clk), .rst(rst), .sclk(sclk), .ss(ss), .mosi(mosi),
        .fd(fd), .s_data(s_data),
        .rx_data(rx_data), .miso(miso), .done(done)
    );
endmodule