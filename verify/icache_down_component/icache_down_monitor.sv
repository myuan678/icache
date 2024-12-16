class icache_down_monitor;
    import toy_pack::*;
    virtual   icache_down_if            down_vif    ;
    icache_down_transaction             item        ;
    mailbox                             txreq_mbx   ;
    mem_model                           mem         ;


    task run();
            #100ns;
            forever begin  //receive tx req
                @(posedge down_vif.clk);
                if(down_vif.downstream_txreq_vld===1)begin
                    item = new;
                    item.txreq = down_vif.downstream_txreq_pld;
                    item.entry_id = down_vif.downstream_txreq_entry_id;
                    //mem.write_mem(item.txreq.addr);
                    mem.read_mem(item.txreq.addr);
                    txreq_mbx.put(item); 
                    $display("[DOWN_MONITOR] get a txreq!!!!!");                  
                end
            end
    endtask

endclass