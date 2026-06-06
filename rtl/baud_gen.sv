`timescale 1ns / 1ps

module baud_gen (
    input  logic clk,
    input  logic rst,
    output logic b_tick
);

    parameter BAUDRATE = 9600;

    localparam F_COUNT = 100_000_000 / (BAUDRATE * 16);

    //reg for counter 
    logic [$clog2(F_COUNT)-1:0] counter_reg;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            b_tick      <= 1'b0;
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (F_COUNT - 1)) begin
                counter_reg <= 0;
                b_tick      <= 1'b1;
            end else begin
                b_tick <= 1'b0;
            end
        end
    end

endmodule
