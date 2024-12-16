class icache_env;
     
    icache_cfg                      cfg                     ;
    icache_scoreboard               scb                     ;
    mem_model                       mem                     ;
    icache_up_agent                 up_agent                ;
    icache_down_agent               down_agent              ;
    mailbox #(toy_pack::pc_req_t)   up_drv_req_mbx          ;
    mailbox                         drv_mbx                 ;
    mailbox                         mon_to_scb_mbx          ;
    mailbox                         id_mbx                  ;
    
    int                             delay,txnid,index,tag   ;
    string                          testname                ;

    function new();
        //init
        scb                     = new                       ;
        mem                     = new                       ;
        up_agent                = new                       ;
        down_agent              = new                       ;

        //connection
        scb.up_drv              = up_agent.up_drv           ;
        scb.up_drv_req_mbx      = up_agent.up_drv_req_mbx   ;
        scb.mon_to_scb_mbx      = up_agent.mon_to_scb_mbx   ;
        scb.mem                 = mem                       ;
        down_agent.down_drv.mem = mem                       ;
        //down_agent.down_mon.mem = mem                       ;
    endfunction

  virtual task run();
        #100ns;
        fork
            up_agent.run();
            down_agent.run();
            scb.compare();
        join_none
  endtask

  virtual task final_check();
        scb.final_check();
  endtask
endclass