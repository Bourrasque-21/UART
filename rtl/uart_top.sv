`timescale 1ns / 1ps

module uart_top #(
    parameter BAUDRATE = 115200,
    parameter DEPTH    = 4,
    parameter D_WIDTH  = 8
) (
    input  logic clk,
    input  logic rst,
    input  logic rx,
    output logic tx
);
    logic
        o_b_tick,
        o_rx_done,
        o_tx_busy,
        o_tx_done,
        w_rx_empty,
        w_rx_full,
        w_tx_empty,
        w_tx_full;
    logic [7:0] o_rx_data, o_rx_fifo_data, o_tx_fifo_data;

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .b_tick  (o_b_tick),
        .tx_start(!o_tx_busy && !w_tx_empty),
        .tx_data (o_tx_fifo_data),
        .tx_busy (o_tx_busy),
        .tx_done (o_tx_done),
        .uart_tx (tx)
    );

    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .b_tick (o_b_tick),
        .rx     (rx),
        .rx_data(o_rx_data),
        .rx_done(o_rx_done)
    );

    fifo #(
        .DEPTH  (DEPTH),
        .D_WIDTH(D_WIDTH)
    ) U_TX_FIFO (
        .clk      (clk),
        .rst      (rst),
        .push     (!w_rx_empty && !w_tx_full),
        .pop      (!o_tx_busy && !w_tx_empty),
        .push_data(o_rx_fifo_data),
        .pop_data (o_tx_fifo_data),
        .full     (w_tx_full),
        .empty    (w_tx_empty)
    );

    fifo #(
        .DEPTH  (DEPTH),
        .D_WIDTH(D_WIDTH)
    ) U_RX_FIFO (
        .clk      (clk),
        .rst      (rst),
        .push     (o_rx_done),
        .pop      (!w_rx_empty && !w_tx_full),
        .push_data(o_rx_data),
        .pop_data (o_rx_fifo_data),
        .full     (w_rx_full),
        .empty    (w_rx_empty)
    );

    baud_gen #(
        .BAUDRATE(BAUDRATE)
    ) U_BAUD_GEN (
        .clk   (clk),
        .rst   (rst),
        .b_tick(o_b_tick)
    );

endmodule
