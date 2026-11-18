`timescale 1ns / 1ps

module edge_detect(
    input  clk, rst,
    input  sig,
    output rise,
    output fall
);
    reg sig_d;
    always @(posedge clk or posedge rst)
        if (rst) sig_d <= 0;
        else     sig_d <= sig;

    assign rise =  sig & ~sig_d;   
    assign fall = ~sig &  sig_d;
endmodule