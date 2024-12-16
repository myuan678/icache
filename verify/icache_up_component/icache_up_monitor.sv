class icache_up_monitor;
    virtual   icache_up_if              up_vif              ;
    //virtual   icache_down_if            down_vif            ;
    up_mon_packet                       up_mon_pkt          ;

    mailbox                             mon_to_scb_mbx      ; 		
    mailbox                             id_mbx              ;


    task run();
        #100ns;
        $display ("T=%0t [UP MONITOR] starting ...", $time);
        forever begin
            @(posedge up_vif.clk);
            if(up_vif.upstream_txdat_vld===1)begin
                up_mon_pkt=new;
                up_mon_pkt.vld   = up_vif.upstream_txdat_vld;
                up_mon_pkt.data  = up_vif.upstream_txdat_data;
                up_mon_pkt.txnid = up_vif.upstream_txdat_txnid;
                mon_to_scb_mbx.put(up_mon_pkt);
                id_mbx.put(up_mon_pkt.txnid);
                $display("[UP_MONITOR] get a txdata!!");
            end
        end
    endtask

    
endclass:icache_up_monitor
