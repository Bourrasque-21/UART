class uart_drv extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(uart_drv)

    virtual uart_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "virtual interface was not provided to uart_driver")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_seq_item tr;

        vif.rx = 1'b1;
        wait (vif.rst == 1'b0);  // Wait for reset release
        `uvm_info(get_type_name(), "Reset release", UVM_MEDIUM)

        forever begin
            seq_item_port.get_next_item(tr);
            vif.drive_byte(tr.rx);  // Drive UART frame
            seq_item_port.item_done();
        end
    endtask  //run_phase

endclass  //uart_drv extends uvm_driver
