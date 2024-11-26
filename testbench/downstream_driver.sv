`ifndef INTERFACE_SV
    `define INTERFACE_SV
    `include "interface.sv"
`endif

class downstream_driver;


    mailbox                         input_mbx       ;
    virtual icache_if_downstream    vif             ;

    function new();
        this.input_mbx = new(2);
    endfunction

    task send_flit(input LwmeshLocFlit flit);
    endtask



    task run();
        fork
            start_transmitter();
            start_receiver();
        join_none
    endtask



    task start_transmitter();
    endtask

    task start_receiver();
    endtask



endclass