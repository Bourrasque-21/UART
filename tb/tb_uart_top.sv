`timescale 1ns / 1ps
import uvm_pkg::*;
import uart_uvm_pkg::*;

module tb_uart ();
    logic clk;
    logic rst;

    localparam int CLOCK_FREQ_HZ = 100_000_000;
    localparam int CLK_PERIOD_NS = 10;
    localparam int BAUDRATE = 115200;
    localparam int OVERSAMPLE = 16;
    localparam int F_COUNT = CLOCK_FREQ_HZ / (BAUDRATE * OVERSAMPLE);
    localparam int CLKS_PER_BIT = F_COUNT * OVERSAMPLE;

    always #5 clk = ~clk;

    uart_if vif (
        clk,
        rst
    );

    uart_top #(
        .BAUDRATE(BAUDRATE),
        .DEPTH   (4),
        .D_WIDTH (8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx (vif.rx),
        .tx (vif.tx)
    );

    initial begin
        clk = 0;
        rst = 1;
        vif.rx = 1;
        vif.rx_clocks_per_bit = CLKS_PER_BIT;
        vif.tx_clocks_per_bit = CLKS_PER_BIT;
        repeat (5) @(posedge clk);
        rst = 0;
    end

    // test 1 : uart_smoke_test         test 2 : uart_corner_test           test 3 : uart_alt_test
    // test 4 : uart_baud_plus2_test    test 5 : uart_baud_minus2_test      test 6 : uart_baud_plus4_test       test 7 : uart_baud_minus4_test
    initial begin
        uvm_config_db#(virtual uart_if)::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
    $fsdbDumpfile("novas.fsdb");
    $fsdbDumpvars(0, tb_uart, "+all");
    end

endmodule
