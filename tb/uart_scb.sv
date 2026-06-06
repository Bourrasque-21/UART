class uart_scb extends uvm_scoreboard;
    `uvm_component_utils(uart_scb)

    uvm_analysis_imp_rx #(uart_seq_item, uart_scb) exp_rx;
    uvm_analysis_imp_tx #(uart_seq_item, uart_scb) act_tx;
    int pass_count;
    int fail_count;

    uart_seq_item exp_queue[$];
    int end_wait_started;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        exp_rx = new("exp_rx", this);
        act_tx = new("act_tx", this);
    endfunction  //new()

    virtual function void write_rx(uart_seq_item tr);
        exp_queue.push_back(tr);
    endfunction

    virtual function void write_tx(uart_seq_item tr);
        uart_seq_item exp_tr;

        if (exp_queue.size() > 0) begin
            exp_tr = exp_queue.pop_front();

            if (exp_tr.rx == tr.rx) begin
                pass_count++;
                `uvm_info(get_type_name(),
                          $sformatf("[PASS] RX data = TX data : 0x%02h", tr.rx),
                          UVM_LOW)
            end else begin
                fail_count++;
                `uvm_error(get_type_name(), $sformatf(
                           "[FAIL] RX = 0x%02h TX = 0x%02h", exp_tr.rx, tr.rx))
            end
        end
    endfunction

    virtual function void phase_ready_to_end(uvm_phase phase);
        if (exp_queue.size() == 0 || end_wait_started) return;
        end_wait_started = 1;
        begin
            `uvm_info(get_type_name(), $sformatf(
                      "Waiting for %0d items to be drained from exp_queue",
                      exp_queue.size()
                      ), UVM_LOW)
            phase.raise_objection(this);
            fork
                begin
                    fork
                        begin
                            wait (exp_queue.size() == 0);
                        end
                        begin
                            #2ms;
                            `uvm_error(get_type_name(), $sformatf(
                                       "TIMEOUT ERROR"))
                        end
                    join_any
                    disable fork;
                    phase.drop_objection(this);
                    end_wait_started = 0;
                end
            join_none
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf(
                  "pass_count=%0d fail_count=%0d pending=%0d",
                  pass_count,
                  fail_count,
                  exp_queue.size()
                  ), UVM_LOW)
    endfunction

endclass  //uart_scb extends uvm_scoreboard
