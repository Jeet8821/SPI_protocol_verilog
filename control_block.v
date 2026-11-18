`timescale 1ns / 1ps
module control_block #(parameter SETUP_CYCLES = 3)(
    input  start,
    input  rst,
    input  c,
    input  clk,
    input  duplex,          // 1 = full duplex, 0 = half duplex (set before start)
    output reg en,
    output reg en_reg,
    output reg ss,
    output reg fd           // 1 only in XFER_FD
);
    localparam IDLE    = 2'b00,
               LOAD    = 2'b01,
               XFER    = 2'b10,   // half duplex
               XFER_FD = 2'b11;   // full duplex

    reg [1:0] f;
    reg [3:0] wait_cnt;
    reg       duplex_cap;         // mode frozen at start

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            f          <= IDLE;
            en         <= 0;
            en_reg     <= 0;
            ss         <= 1;
            fd         <= 0;
            wait_cnt   <= 0;
            duplex_cap <= 0;
        end
        else begin
            case (f)
                IDLE: begin
                    en       <= 0;
                    en_reg   <= 0;
                    ss       <= 1;
                    fd       <= 0;
                    wait_cnt <= 0;
                    if (start) begin
                        f          <= LOAD;
                        duplex_cap <= duplex;
                    end
                end

                LOAD: begin
                    if (wait_cnt == SETUP_CYCLES-1) begin
                        en     <= 1;
                        en_reg <= 1;
                        ss     <= 0;
                        if (duplex_cap) begin
                            f  <= XFER_FD;
                            fd <= 1;
                        end
                        else begin
                            f  <= XFER;
                            fd <= 0;
                        end
                    end
                    else
                        wait_cnt <= wait_cnt + 1;
                end

                XFER, XFER_FD: begin
                    if (c) begin
                        f      <= IDLE;
                        en     <= 0;
                        en_reg <= 0;
                        ss     <= 1;
                        fd     <= 0;
                    end
                end

                default: f <= IDLE;
            endcase
        end
    end
endmodule
