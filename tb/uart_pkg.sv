package uart_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
`uvm_analysis_imp_decl(_rx)
    `uvm_analysis_imp_decl(_tx)

    `include "uart_seq_item.sv"
    `include "uart_seq.sv"
    `include "uart_cov.sv"
    `include "uart_drv.sv"
    `include "uart_mon.sv"
    `include "uart_agt.sv"
    `include "uart_scb.sv"
    `include "uart_env.sv"
    `include "uart_test.sv"

endpackage
