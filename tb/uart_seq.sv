// Sequence 1 : random_data_sequence
class uart_base_seq extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_base_seq)

    uart_seq_item item;
    int repeat_rx = 0;

    function new(string name = "uart_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        repeat (repeat_rx) begin
            item = uart_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(),
                           "Failed to randomize uart_seq_item");
            finish_item(item);
        end
    endtask  //body
endclass  //uart_base_seq extends uvm_sequence


// Sequence 2 : corner_data_sequence
class uart_corner_seq extends uart_base_seq;
    `uvm_object_utils(uart_corner_seq)

    function new(string name = "uart_corner_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        repeat (repeat_rx) begin
            item = uart_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                    rx inside {8'h00, 8'hFF, 8'h55, 8'hAA, 8'h01, 8'h80, 8'h7F};
                })
                `uvm_fatal(get_type_name(),
                           "Failed to randomize uart_seq_item");
            finish_item(item);
        end
    endtask  //body
endclass  //uart_corner_seq extends uvm_sequence


// Sequence 3 : alternating_sequence
class uart_alt_seq extends uart_base_seq;
    `uvm_object_utils(uart_alt_seq)

    function new(string name = "uart_alt_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();
        for (int i = 0; i < repeat_rx; i++) begin
            item = uart_seq_item::type_id::create("item");
            start_item(item);
            item.rx = (i % 2 == 0) ? 8'h55 : 8'hAA;
            finish_item(item);
        end
    endtask  //body
endclass  //uart_alt_seq extends uvm_sequence

