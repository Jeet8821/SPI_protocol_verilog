`timescale 1ns / 1ps



module clock_divider(
    input clk,
    input en,
    input rst,
    input [31:0] half_period,
    output reg sclk
    );
    reg [31:0]counter;
    always @(posedge clk) begin
    if (!en || rst) begin
        counter <=0;
        sclk <=0;
    end
    else begin 
        if( counter == half_period -1) begin
            counter <=0;
            sclk <= ~sclk;
         end
         else begin
         counter <= counter +1;
         end
      end
        
end
endmodule
