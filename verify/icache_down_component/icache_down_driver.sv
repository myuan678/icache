class icache_down_driver;
    import toy_pack::*;
    virtual   icache_down_if            down_vif        ;
    mailbox                             txreq_mbx       ;
    mem_model                           mem             ;
    icache_down_transaction             item            ;

    icache_down_transaction             down_trans,down_trans_q[$], got_down_trans;
    int                                 rxdat_delay,tx_req_cnt=0;


    task recv_tx_req();
            //#100ns;
            forever begin  //receive tx req
                //@(posedge down_vif.clk);
                do begin
                    @(posedge down_vif.clk);
                end while(!(down_vif.downstream_txreq_rdy && down_vif.downstream_txreq_vld));
                    item = new;
                    item.txreq = down_vif.downstream_txreq_pld;
                    item.entry_id = down_vif.downstream_txreq_entry_id;
                    mem.read_mem(item.txreq.addr);
                    txreq_mbx.put(item); 
                    tx_req_cnt++;
                    $display("[DOWN_MONITOR] get a txreq! total %0d txreq",tx_req_cnt);                  
            end
    endtask

    task gen_rx_data();
        forever begin
            txreq_mbx.get(got_down_trans);
            $display("[DOWN_DRV] get txreq, id=%0d!!",got_down_trans.txreq.txnid);
            //@(posedge down_vif.clk);
            down_trans_q.push_back(got_down_trans);
            if(down_trans_q.size()>1)begin
                down_trans_q.shuffle();
                $display("[DOWN_DRV OUT OF ORDER] %0d pkt in ooo queue!!",down_trans_q.size());
            end
        end
    endtask

    task send_rx_data();
        forever begin
            while(down_trans_q.size()==0)begin
                @(posedge down_vif.clk);
            end
            rxdat_delay     = $urandom_range(1, 50);
            repeat(rxdat_delay)@(posedge down_vif.clk);
            down_trans = down_trans_q.pop_front();
            down_vif.downstream_rxdat_vld                            <= 1;
            down_vif.downstream_rxdat_pld.downstream_rxdat_opcode    <= down_trans.txreq.opcode;
            down_vif.downstream_rxdat_pld.downstream_rxdat_txnid     <= down_trans.txreq.txnid;
            //down_vif.downstream_rxdat_pld.downstream_rxdat_data      <= down_trans.txreq.addr;
            down_vif.downstream_rxdat_pld.downstream_rxdat_data      <= mem.mem[down_trans.txreq.addr];
            down_vif.downstream_rxdat_pld.downstream_rxdat_entry_idx <= down_trans.entry_id;
            $display("[[DOWN_DRV] send RXDATA] mem[%0h]=%h, txnid=%0h",down_trans.txreq.addr,mem.mem[down_trans.txreq.addr], down_trans.txreq.txnid);
            do begin
                @(posedge down_vif.clk);
            end while(down_vif.downstream_rxdat_rdy!==1'b1);
            down_vif.downstream_rxdat_vld                            <=   0;
            down_vif.downstream_rxdat_pld.downstream_rxdat_opcode    <= 'b0;
            down_vif.downstream_rxdat_pld.downstream_rxdat_txnid     <= 'b0;
            down_vif.downstream_rxdat_pld.downstream_rxdat_data      <= 'b0;
            down_vif.downstream_rxdat_pld.downstream_rxdat_entry_idx <= 'b0;
        end
    endtask


    task gen_rdy_backpress();
        int  bp_time,work_time;
        forever begin
            bp_time = $urandom_range(0,1);
            work_time = $urandom_range(2,50);
            down_vif.downstream_txreq_rdy <= 0;
            repeat(bp_time)@(posedge down_vif.clk);
            down_vif.downstream_txreq_rdy <= 1;
            repeat(work_time)@(posedge down_vif.clk);
        end
    endtask

    virtual task run();
        #100ns;
        $display("[DOWN_DRV] start!!!!!!!!!");
        fork
            gen_rx_data();
            send_rx_data();
            recv_tx_req();
            gen_rdy_backpress();
        join
    endtask

endclass
