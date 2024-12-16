class icache_up_agent;
     
    icache_cfg                      cfg                     ;
    virtual   icache_up_if          up_vif                  ;
    icache_upstream_driver          up_drv                  ;
    icache_up_sequence              up_seq                  ;
    icache_up_monitor               up_mon                  ;

    mailbox #(toy_pack::pc_req_t)   up_drv_req_mbx          ;
    mailbox                         drv_mbx                 ;
    mailbox                         mon_to_scb_mbx          ;
    mailbox                         id_mbx                  ;
    
    int                             delay,txnid,index,tag   ;
    string                          testname                ;

    function new();
        //init
        up_drv                  = new                   ;
        up_seq                  = new                   ;
        up_mon                  = new                   ;
        up_drv_req_mbx          = new                   ;
        drv_mbx                 = new                   ;
        mon_to_scb_mbx          = new                   ;
        id_mbx                  = new                   ;

        //connection
        up_drv.up_vif           = up_vif                ;
        up_drv.up_drv_req_mbx   = up_drv_req_mbx        ;
        up_drv.drv_mbx          = drv_mbx               ;
        up_drv.mon_to_scb_mbx   = mon_to_scb_mbx        ;
        up_drv.id_mbx           = id_mbx                ;
        up_seq.drv_mbx          = drv_mbx               ;
        up_seq.drv_send_done    = up_drv.drv_send_done  ;
        up_drv.id_mbx           = id_mbx                ;
    endfunction

  virtual task run();
        //#500ns;
        fork
            up_drv.run();
        join_none
  endtask

endclass