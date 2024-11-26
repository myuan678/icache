class request;
    import toy_pack::*;

    virtual   icache_if  vif;
    mailbox   up_req_mbx;

    pc_req_t                            up_req,txreq_q[$],txreq;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]  txreq_entry_id_q[$],txreq_entry_id;
    int  rxdat_delay,tx_req_cnt=0,rx_dat_cnt=0;

    task send_upstream_req(input int tag, int index, int id);
        @(posedge vif.clk);
        @(posedge vif.clk);
        vif.upstream_rxreq_vld              <= 1;
        vif.upstream_rxreq_pld.addr.tag     <= tag;
        vif.upstream_rxreq_pld.addr.index   <= index;
        vif.upstream_rxreq_pld.addr.offset  <= {ICACHE_OFFSET_WIDTH{1'b1}};
        vif.upstream_rxreq_pld.opcode       <= UPSTREAM_OPCODE;
        vif.upstream_rxreq_pld.txnid        <= id;
        $display("send_upstream_req: tag=%d, index=%d, id=%d", tag, index, id);
        do begin
            @(posedge vif.clk);
        end while(vif.upstream_rxreq_rdy!==1'b1);
        //up_req.push_back(vif.upstream_rxreq_pld);
        up_req = vif.upstream_rxreq_pld;
        up_req_mbx.put(up_req);
        //up_req_cnt++;
        vif.upstream_rxreq_vld              <= 0;
        vif.upstream_rxreq_pld.addr.tag     <= 0;
        vif.upstream_rxreq_pld.addr.index   <= 0;
        vif.upstream_rxreq_pld.addr.offset  <= 0;
        vif.upstream_rxreq_pld.opcode       <= 0;
        vif.upstream_rxreq_pld.txnid        <= 0;
        //end
    endtask

    task send_downstream_req(input int tag, int index, int id);
        @(posedge vif.clk);
        vif.downstream_rxsnp_vld              <= 1;
        vif.downstream_rxsnp_pld.addr.tag     <= tag;
        vif.downstream_rxsnp_pld.addr.index   <= index;
        vif.downstream_rxsnp_pld.addr.offset  <= {ICACHE_OFFSET_WIDTH{1'b1}};
        vif.downstream_rxsnp_pld.opcode       <= DOWNSTREAM_OPCODE;
        vif.downstream_rxsnp_pld.txnid        <= id;
        //$display("send_downstream_req: tag=%d, index=%d, id=%d", tag, index, id);
        do begin
            @(posedge vif.clk);
        end while(vif.downstream_rxsnp_rdy!==1'b1);
        vif.downstream_rxsnp_vld              <= 0;
        vif.downstream_rxsnp_pld.addr.tag     <= 0;
        vif.downstream_rxsnp_pld.addr.index   <= 0;
        vif.downstream_rxsnp_pld.addr.offset  <= 0;
        vif.downstream_rxsnp_pld.opcode       <= 0;
        vif.downstream_rxsnp_pld.txnid        <= 0;
    endtask

    task gen_rxdat();
        fork
            forever begin  //receive tx req
                @(posedge vif.clk);
                if(vif.downstream_txreq_vld===1)begin
                    tx_req_cnt++;
                    txreq_q.push_back(vif.downstream_txreq_pld);
                    txreq_entry_id_q.push_back(vif.downstream_txreq_entry_id);
                end
            end
            forever begin  //gen rx data
                @(posedge vif.clk);
                if(txreq_q.size()>0)begin
                    rxdat_delay     = $urandom_range(5, 10);
                    repeat(rxdat_delay)@(posedge vif.clk);
                    txreq          = txreq_q.pop_front();
                    txreq_entry_id = txreq_entry_id_q.pop_front();
                    vif.downstream_rxdat_vld                            <= 1;
                    vif.downstream_rxdat_pld.downstream_rxdat_opcode    <= txreq.opcode;
                    vif.downstream_rxdat_pld.downstream_rxdat_txnid     <= txreq.txnid;
                    vif.downstream_rxdat_pld.downstream_rxdat_data      <= txreq.addr;
                    vif.downstream_rxdat_pld.downstream_rxdat_entry_idx <= txreq_entry_id;
                    $display("downstream_rxdat = %h   %t, nid=%0h,remain pkt=%0d",txreq.addr,$realtime,txreq.txnid,txreq_q.size() );
                    do begin
                        @(posedge vif.clk);
                    end while(vif.downstream_rxdat_rdy!==1'b1);
                    rx_dat_cnt++;
                    vif.downstream_rxdat_vld                            <=   0;
                    vif.downstream_rxdat_pld.downstream_rxdat_opcode    <= 'b0;
                    vif.downstream_rxdat_pld.downstream_rxdat_txnid     <= 'b0;
                    vif.downstream_rxdat_pld.downstream_rxdat_data      <= 'b0;
                    vif.downstream_rxdat_pld.downstream_rxdat_entry_idx <= 'b0;
                end
            end
        join
    endtask

endclass