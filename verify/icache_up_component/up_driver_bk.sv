class icache_upstream_driver;
    import toy_pack::*;

    icache_cfg                          cfg             ;
    virtual   icache_up_if              up_vif          ;
    virtual   icache_down_if            down_vif        ;
    mailbox  #(toy_pack::pc_req_t)      up_drv_req_mbx  ;
    mailbox                             drv_mbx         ;
    mailbox                             id_mbx          ;
    event                               drv_send_done   ;
    icache_up_transaction               up_trans        ;

    pc_req_t                            up_req,txreq_q[$],txreq;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]  txreq_entry_id_q[$],txreq_entry_id;
    int  rxdat_delay,tx_req_cnt=0,rx_dat_cnt=0;
    int  id_q[$],id;


    function new();
        cfg = new();  
    endfunction
    

    task start_upstream_transmiter();
            static int txnid_counter = 1;
        forever begin
            //TODO：
            drv_mbx.get(up_trans);
            if(cfg.debug_en) $display("T=%0d,Start to Listen DRV",$time);
            repeat(up_trans.delay)@(posedge up_vif.clk);
            while(id_q.size()==0)begin
                @(posedge up_vif.clk);
            end
            id = id_q.pop_front();
            up_vif.upstream_rxreq_vld              <= 1;
            up_vif.upstream_rxreq_pld.addr.tag     <= up_trans.tag;
            up_vif.upstream_rxreq_pld.addr.index   <= up_trans.index;
            up_vif.upstream_rxreq_pld.addr.offset  <= up_trans.offset;
            up_vif.upstream_rxreq_pld.opcode       <= up_trans.opcode;
            //vif.upstream_rxreq_pld.txnid        <= up_trans.txnid;
            up_vif.upstream_rxreq_pld.txnid        <= id;
            $display("T=%0d,[UP DRV] send_upstream_req: tag=%d, index=%d, txnid=%d, opcode=%d",$time, up_trans.tag, up_trans.index, txnid_counter,up_trans.opcode);
            do begin
                @(posedge up_vif.clk);
            end while(!(up_vif.upstream_rxreq_rdy && up_vif.upstream_rxreq_vld));
            up_req = up_vif.upstream_rxreq_pld;
            up_drv_req_mbx.put(up_req);
            up_vif.upstream_rxreq_vld              <= 0;
            up_vif.upstream_rxreq_pld.addr.tag     <= 0;
            up_vif.upstream_rxreq_pld.addr.index   <= 0;
            up_vif.upstream_rxreq_pld.addr.offset  <= 0;
            up_vif.upstream_rxreq_pld.opcode       <= 0;
            up_vif.upstream_rxreq_pld.txnid        <= 0;
            ->drv_send_done;
        end
        //else begin
        //    $display("UPstream Driver send fail");
        //end
    endtask

    task init_id_q();
        for(int i=0;i<16;i++)begin
            id_q.push_back(i);
        end
        id_q.shuffle();
    endtask



    task token_recycle();
        int rec_id;
        forever begin
            id_mbx.get(rec_id);
            if(id_q.size()>0)begin
                foreach(id_q[i])begin
                    if(id_q[i]==rec_id)begin
                        $error("[UP_DRV] REC ID=%0d, but it already in queue",rec_id);
                    end
                end
            end
            id_q.push_back(rec_id);
            id_q.shuffle();
        end
    endtask


    virtual task run();
        init_id_q();
        #100ns;
        $display("[UP_DRV] start!!!!!!!!!");
        fork
            start_upstream_transmiter();
            token_recycle();
        join
    endtask


endclass