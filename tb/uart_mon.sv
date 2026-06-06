// TX Monitor
class uart_mon_tx extends uvm_monitor;
    `uvm_component_utils(uart_mon_tx)

    uvm_analysis_port #(uart_seq_item) ap;
    virtual uart_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "virtual interface was not provided to uart_monitor")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_seq_item tr;
        logic [7:0] sampled_tx_data;
        wait (vif.rst == 1'b0);
        forever begin
            @(negedge vif.tx);  // Wait for start bit

            vif.wait_clocks(vif.tx_clocks_per_bit / 2);  // Check start bit center

            if (vif.tx == 1'b0) begin
                sampled_tx_data = 8'd0;

                // Sample 8 data bits
                for (int i = 0; i < 8; i++) begin
                    vif.wait_clocks(vif.tx_clocks_per_bit);
                    sampled_tx_data[i] = vif.tx;
                end
                vif.wait_clocks(vif.tx_clocks_per_bit);

                // Check stop bit
                if (vif.tx == 1'b0) begin
                    `uvm_error(get_type_name(),
                               "Stop bit sampled low on DUT tx")
                end else begin
                    tr = uart_seq_item::type_id::create("mon_tx");
                    tr.rx = sampled_tx_data;
                    `uvm_info(get_type_name(), $sformatf(
                              "Observed TX byte 0x%02h", sampled_tx_data),
                              UVM_MEDIUM)
                    ap.write(tr);
                end
            end
        end
    endtask
endclass  //uart_mon_tx extends uvm_monitor


// RX Monitor
class uart_mon_rx extends uvm_monitor;
    `uvm_component_utils(uart_mon_rx)

    uvm_analysis_port #(uart_seq_item) ap;
    virtual uart_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(),
                       "virtual interface was not provided to uart_monitor")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_seq_item tr;
        logic [7:0] sampled_rx_data;
        wait (vif.rst == 1'b0);

        forever begin
            @(negedge vif.rx);  // Wait for start bit

            vif.wait_clocks(vif.rx_clocks_per_bit / 2);  // Check start bit center

            if (vif.rx == 1'b0) begin
                sampled_rx_data = 8'd0;

                // Sample 8 data bits
                for (int i = 0; i < 8; i++) begin
                    vif.wait_clocks(vif.rx_clocks_per_bit);
                    sampled_rx_data[i] = vif.rx;
                end
                vif.wait_clocks(vif.rx_clocks_per_bit);

                // Check stop bit
                if (vif.rx == 1'b0) begin
                    `uvm_error(get_type_name(),
                               "Stop bit sampled low on DUT rx")
                end else begin
                    tr = uart_seq_item::type_id::create("mon_rx");
                    tr.rx = sampled_rx_data;
                    `uvm_info(get_type_name(), $sformatf(
                              "Observed RX byte 0x%02h", sampled_rx_data),
                              UVM_MEDIUM)
                    ap.write(tr);
                end
            end
        end
    endtask
endclass  //uart_mon extends uvm_monitor
