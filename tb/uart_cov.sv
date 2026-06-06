class uart_cov extends uvm_subscriber #(uart_seq_item);
    `uvm_component_utils(uart_cov)

    uart_seq_item item;

    covergroup uart_cg;
        cp_rx_data: coverpoint item.rx {
            bins zero = {8'h00};
            bins ff = {8'hFF};
            bins aa = {8'hAA};
            bins hh55 = {8'h55};
            bins low = {[8'h01 : 8'h1F]};
            bins mid = {[8'h20 : 8'hDF]};
            bins high = {[8'hE0 : 8'hFE]};
        }
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        uart_cg = new();
    endfunction  //new()

    virtual function void write(uart_seq_item t);
        item = t;
        uart_cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "==== UART Coverage Summary ====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(
                  "cp_rx_data : %0.2f%%", uart_cg.cp_rx_data.get_coverage()),
                  UVM_LOW)
    endfunction
endclass  //uart_cov extends uvm_subscriber
