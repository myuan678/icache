class icache_scoreboard;
    import toy_pack::*;
    
    icache_cfg                      cfg             ;
    mailbox #(toy_pack::pc_req_t)   up_drv_req_mbx  ;
    mailbox #(toy_pack::pc_req_t)   down_req_mbx    ;
    mailbox                         mon_to_scb_mbx  ;
    icache_upstream_driver          up_drv          ;
    icache_down_driver              down_drv        ;
    mem_model                       mem             ;
    
    pc_req_t                        req,up_req[$]   ;
    up_mon_packet                   up_mon_pkt      ;
    int  txnid_flag,tx_dat_cnt=0,up_req_cnt=0,err_cnt=0;
    bit[255:0]      data;


    //function new(input icache_cfg cfg_input);
    //    cfg = cfg_input;
    //endfunction

    task compare();
        fork
            forever begin
                up_drv_req_mbx.get(req);
                up_req_cnt++;
                up_req.push_back(req);
                $display("[SCOREBOARD] Scoreboard get up req: tag=%d, index=%d, id=%d", req.addr.tag, req.addr.index, req.txnid);
            end
            forever begin
                mon_to_scb_mbx.get(up_mon_pkt);
                tx_dat_cnt++;
                foreach(up_req[i])begin
                    if(up_req[i].txnid == up_mon_pkt.txnid)begin
                        txnid_flag = 1;
                        if(mem.mem[up_req[i].addr] !== up_mon_pkt.data)begin
                        //data=mem.read_mem(up_req[i].addr);
                        //if( data!== up_vif.upstream_txdat_data)begin
                            $error("[SCOREBOARD] compare error when txnid=%0d, addr=%h",up_mon_pkt.txnid,up_req[i].addr);
                            $error("[SCOREBOARD] upstream_txdat_data=%h, txnid=%0d",up_mon_pkt.data, up_mon_pkt.txnid);
                            $error("[SCOREBOARD] ref_data from model=%h, addr=%h, txnid=%0d",mem.mem[up_req[i].addr], up_req[i].addr, up_mon_pkt.txnid);
                            //$error("read_mem=%h",mem.read_mem(up_req[i].addr));
                            err_cnt++;
                        end else begin
                            $display("[SCOREBOARD] txnid %d compare pass",up_mon_pkt.txnid);
                            $display("[SCOREBOARD] upstream_txdat_data=%h",up_mon_pkt.data);
                            $display("[SCOREBOARD] ref_data from model=%h, addr=%h, ",mem.mem[up_req[i].addr], up_req[i].addr);
                        end
                        up_req.delete(i);
                    end
                end
                if(txnid_flag == 0)begin
                    $error("[SCOREBOARD] receive txnid=%0d error",up_mon_pkt.txnid);
                    err_cnt++;
                end
                else begin
                    txnid_flag = 0;
                end
            end
        join
    endtask

    task final_check();
        if(up_req.size()!=0)begin
            err_cnt++;
            $error("[Final check] there %0d up req not processed!",up_req.size());
        end
        $display("PC send %0d up req, receive %0d tx dat",up_req_cnt,tx_dat_cnt);
        //$display("PC send %0d tx req, receive %0d rx dat",ref_m.tx_req_cnt,ref_m.rx_dat_cnt);
        if(err_cnt==0)begin
            $display("------------------------------------TC PASSED------------------------------------");
        end else begin
            $display("------------------------------------TC FAILED------------------------------------");
        end
        //$display("%0d req hit, %0d req miss",up_req_cnt-ref_m.tx_req_cnt,ref_m.tx_req_cnt);
        //$display("Hit rate: %0.2f%%",(up_req_cnt-ref_m.tx_req_cnt) * 100.0 /up_req_cnt );
        $display("--------------------------------------------------------------------------------");
    endtask

endclass