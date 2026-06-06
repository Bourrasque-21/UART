// Test 1 : uart_smoke_test
class uart_smoke_test extends uvm_test;
    `uvm_component_utils(uart_smoke_test)

    uart_env env;
    uart_base_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = uart_base_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== SMOKE TEST PASS! =====", UVM_LOW)
        else `uvm_info(get_type_name(), "===== SMOKE TEST FAIL! =====", UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test


// Test 2 : uart_corner_test
class uart_corner_test extends uvm_test;
    `uvm_component_utils(uart_corner_test)

    uart_env env;
    uart_corner_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = uart_corner_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== CORNER TEST PASS! =====", UVM_LOW)
        else
            `uvm_info(get_type_name(), "===== CORNER TEST FAIL! =====", UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test


// Test 3 : uart_alt_test
class uart_alt_test extends uvm_test;
    `uvm_component_utils(uart_alt_test)

    uart_env env;
    uart_alt_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = uart_alt_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== ALT TEST PASS! =====", UVM_LOW)
        else `uvm_info(get_type_name(), "===== ALT TEST FAIL! =====", UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test


// Test 4 : uart_baud_plus2_test
class uart_baud_plus2_test extends uvm_test;
    `uvm_component_utils(uart_baud_plus2_test)

    virtual uart_if vif;
    uart_env env;
    uart_base_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface was not provided to uart_baud_plus2_test")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        // rx input timing only: +2% mismatch
        vif.rx_clocks_per_bit = (vif.tx_clocks_per_bit * 102) / 100;
        seq = uart_base_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== BAUD +2% TEST PASS! =====",
                      UVM_LOW)
        else
            `uvm_info(get_type_name(), "===== BAUD +2% TEST FAIL! =====",
                      UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test


// Test 5 : uart_baud_minus2_test
class uart_baud_minus2_test extends uvm_test;
    `uvm_component_utils(uart_baud_minus2_test)

    virtual uart_if vif;
    uart_env env;
    uart_base_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface was not provided to uart_baud_minus2_test")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        // rx input timing only: -2% mismatch
        vif.rx_clocks_per_bit = (vif.tx_clocks_per_bit * 98) / 100;
        seq = uart_base_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== BAUD -2% TEST PASS! =====",
                      UVM_LOW)
        else
            `uvm_info(get_type_name(), "===== BAUD -2% TEST FAIL! =====",
                      UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test



// Test 6 : uart_baud_plus4_test
class uart_baud_plus4_test extends uvm_test;
    `uvm_component_utils(uart_baud_plus4_test)

    virtual uart_if vif;
    uart_env env;
    uart_base_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface was not provided to uart_baud_plus4_test")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        // rx input timing only: +4% mismatch
        vif.rx_clocks_per_bit = (vif.tx_clocks_per_bit * 104) / 100;
        seq = uart_base_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== BAUD +4% TEST PASS! =====",
                      UVM_LOW)
        else
            `uvm_info(get_type_name(), "===== BAUD +4% TEST FAIL! =====",
                      UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test



// Test 7 : uart_baud_minus4_test
class uart_baud_minus4_test extends uvm_test;
    `uvm_component_utils(uart_baud_minus4_test)

    virtual uart_if vif;
    uart_env env;
    uart_base_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(
                get_type_name(),
                "virtual interface was not provided to uart_baud_minus4_test")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        // rx input timing only: -4% mismatch
        vif.rx_clocks_per_bit = (vif.tx_clocks_per_bit * 96) / 100;
        seq = uart_base_seq::type_id::create("seq");
        seq.repeat_rx = 256;
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info(get_type_name(), "===== BAUD -4% TEST PASS! =====",
                      UVM_LOW)
        else
            `uvm_info(get_type_name(), "===== BAUD -4% TEST FAIL! =====",
                      UVM_LOW)
    endfunction
endclass  //uart_test extends uvm_test
