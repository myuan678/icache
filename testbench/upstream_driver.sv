`ifndef INTERFACE_SV
    `define INTERFACE_SV
    `include "interface.sv"
`endif

class upstream_driver;


    mailbox                     input_mbx       ;
    virtual icache_if_upstream  vif             ;

    function new();
        this.input_mbx = new(2);
    endfunction

    task send_flit(input LwmeshLocFlit flit);
    endtask



    task run();
        fork
            start_transmitter();
        join_none
    endtask



    task start_transmitter();
    endtask



endclass