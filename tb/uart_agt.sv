class uart_agt extends uvm_agent;
    `uvm_component_utils(uart_agt)

    uvm_sequencer #(uart_seq_item) sqr;
    uart_drv drv;
    uart_mon_tx mon_tx;
    uart_mon_rx mon_rx;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = uart_drv::type_id::create("drv", this);
        mon_tx = uart_mon_tx::type_id::create("mon_tx", this);
        mon_rx = uart_mon_rx::type_id::create("mon_rx", this);
        sqr = uvm_sequencer#(uart_seq_item)::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass  //uart_agent extends uvm_agent
