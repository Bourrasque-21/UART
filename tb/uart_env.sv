class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    uart_agt agt;
    uart_scb scb;
    uart_cov cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = uart_agt::type_id::create("agt", this);
        scb = uart_scb::type_id::create("scb", this);
        cov = uart_cov::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon_rx.ap.connect(scb.exp_rx);
        agt.mon_tx.ap.connect(scb.act_tx);
        agt.mon_tx.ap.connect(cov.analysis_export);
    endfunction
endclass  //uart_emv extends uvm_env
