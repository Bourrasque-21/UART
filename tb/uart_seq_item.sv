class uart_seq_item extends uvm_sequence_item;
    rand logic [7:0] rx;

    //constraint

    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_int(rx, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_seq_item");
        super.new(name);
    endfunction  //new()
endclass  //uart_seq_item extends superClass
