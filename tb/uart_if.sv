interface uart_if (
    input logic clk,
    input logic rst
);

    logic rx;
    logic tx;
    int unsigned rx_clocks_per_bit;
    int unsigned tx_clocks_per_bit;

    task automatic wait_clocks(input int unsigned cycles);
        repeat (cycles) @(posedge clk);
    endtask

    task automatic drive_byte(input bit [7:0] data);
        rx = 1'b0;
        wait_clocks(rx_clocks_per_bit);

        for (int i = 0; i < 8; i++) begin
            rx = data[i];
            wait_clocks(rx_clocks_per_bit);
        end

        rx = 1'b1;
        wait_clocks(rx_clocks_per_bit);
    endtask  //drive_byte

endinterface  //uart_if
