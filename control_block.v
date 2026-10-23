`timescale 1ns / 1ps

module control_block(
    input start,
    input rst,
    input c,
    input clk,
    output reg en,
    output reg en_reg,
    output reg ss
);

   reg [1:0] f;

always @(posedge clk or posedge rst) begin
    if (rst)begin
        f <= 2'b00;
        en <= 0;
        en_reg <= 0;
        ss <= 1;
        end       
    else begin
        case (f)
            2'b00: begin //master idle 
                en <= 0;
                en_reg <= 0;
                ss <= 1;
                if (start)
                    f <= 2'b01;  
            end

            2'b01: begin //master loading  
                en <= 1;
                en_reg <= 1;
                ss <= 1;
                if (c)
                    f <= 2'b10;     
            end

            2'b10: begin //master transfering
                en <= 1;
                en_reg <= 1;
                ss <= 0;  
                if (c)
                    f <= 2'b00;  
            end

            2'b11: begin //master receiving 
                en <= 1;
                en_reg <= 1;
                ss <= 1;
                if (c) 
                f <= 2'b00;      
            end
        endcase
    end
end
endmodule
