`timescale 1ns / 1ps

module tb_simple;

    // ---------- inputs (the only things we drive) ----------
    reg        clk = 0, rst = 1, start = 0, duplex = 0;
    reg [7:0]  m_data = 0, s_data = 0;
    wire [31:0] half_period = 32'd4;          // fixed, not a variable any more

    // ---------- outputs we look at ----------
    wire       sclk, ss, mosi, c, done, master_rx_valid;
    wire [7:0] rx_data, master_rx;
    wire       miso = dut.miso;

    spi_top dut (
        .clk(clk), .rst(rst), .start(start), .duplex(duplex),
        .m_data(m_data), .s_data(s_data), .half_period(half_period),
        .sclk(sclk), .ss(ss), .mosi(mosi), .c(c),
        .rx_data(rx_data), .done(done),
        .master_rx(master_rx), .master_rx_valid(master_rx_valid)
    );

    always #5 clk = ~clk;

    // internal registers, only for printing
    wire [7:0] mq = dut.master.shift.q;
    wire [7:0] sq = dut.slave.sr.q;
    wire [1:0] st = dut.master.ctrl.f;

    // ---------- print the registers after every bit shift ----------
    reg fall_d = 0;
    integer bitn = 0;
    always @(posedge clk) fall_d <= dut.master.sclk_fall;
    always @(negedge clk) begin
        if (ss) bitn = 0;
        else if (fall_d) begin
            bitn = bitn + 1;
            $display("      shift %0d: master_q=%b  slave_q=%b  (mosi=%b miso=%b)",
                     bitn, mq, sq, mosi, miso);
        end
    end

    // ---------- one transfer, narrated ----------
    task xfer(input dpx, input [7:0] md, input [7:0] sd);
        begin
            $display("\n=========== %s transfer ===========", dpx ? "FULL DUPLEX" : "HALF DUPLEX");

            @(negedge clk);
            duplex = dpx; m_data = md; s_data = sd;
            $display("[%0t] STEP 1: inputs applied  duplex=%b  m_data=%h  s_data=%h",
                     $time, duplex, m_data, s_data);

            @(negedge clk);
            start = 1;
            $display("[%0t] STEP 2: start pulse. FSM leaves IDLE", $time);
            @(negedge clk);
            start = 0;

            wait (st == 2'd1);
            $display("[%0t] STEP 3: LOAD state. master_q=%h (= m_data), slave_q=%h (= s_data), ss=%b",
                     $time, mq, sq, ss);

            wait (ss == 0);
            @(negedge clk);
            $display("[%0t] STEP 4: ss fell, FSM state=%0d (%s). First bits are already on the lines: mosi=%b miso=%b",
                     $time, st, st == 3 ? "XFER_FD" : "XFER", mosi, miso);
            $display("      8 shifts follow, one per sclk fall:");

            wait (c == 1);
            @(negedge clk);
            $display("[%0t] STEP 5: c and done pulsed. 8 bits are done", $time);
            $display("      slave  rx_data   = %h  (expected %h = m_data)", rx_data, md);
            if (dpx)
                $display("      master_rx     = %h  (expected %h = s_data)", master_rx, sd);
            else
                $display("      master_rx     = %h  (unchanged, because the slave is silent)", master_rx);

            wait (ss == 1);
            repeat (5) @(negedge clk);
            $display("[%0t] STEP 6: back to IDLE (state=%0d), ss=%b sclk=%b", $time, st, ss, sclk);
        end
    endtask

    // ---------- the scenario ----------
    reg [7:0] saved;
    initial begin
        $dumpfile("tb_simple.vcd");
        $dumpvars(0, tb_simple);

        repeat (4) @(negedge clk);
        rst = 0;
        repeat (3) @(negedge clk);

        // Transfer 1: half duplex. Slave must only listen.
        xfer(1'b0, 8'hA5, 8'hFF);          // FF is junk, it must NOT appear on miso
        saved = rx_data;                   // slave now holds A5

        // Transfer 2: full duplex. New master byte, slave replies with A5.
        xfer(1'b1, 8'h3C, saved);

        $display("\n----------------- RESULT -----------------");
        $display("slave rx_data = %h  %s", rx_data,   rx_data   === 8'h3C ? "OK" : "WRONG");
        $display("master_rx     = %h  %s", master_rx, master_rx === 8'hA5 ? "OK" : "WRONG");
        $finish;
    end

    initial begin #200000; $display("WATCHDOG"); $finish; end
endmodule