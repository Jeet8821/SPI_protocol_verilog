`timescale 1ns / 1ps

module clock_divider(
    input clk,
    input en,
    input rst,
    input [31:0] half_period,
    output reg sclk,
    output reg sclk_rise,
    output reg sclk_fall
    );
    reg [31:0]counter;
    always @(posedge clk) begin
     sclk_rise <= 0;
     sclk_fall <= 0;
    if (!en || rst) begin
        counter <=0;
        sclk <=0;
    end
    else if( counter == half_period -1) begin
            counter <=0;
            sclk <= ~sclk;
            if (sclk) sclk_fall <= 1;
            else      sclk_rise <= 1;    
         end
         else begin
         counter <= counter +1;
         end
      end
endmodule
