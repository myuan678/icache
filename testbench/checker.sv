class scoreboard;
    import toy_pack::*;
    
    mailbox    up_req_mbx;
    request    drv;
    virtual    icache_if  vif;
    
    pc_req_t   req,up_req[$];
    int  txnid_flag,tx_dat_cnt=0,up_req_cnt=0,err_cnt=0;

    task compare();
        fork
            forever begin
                up_req_mbx.get(req);
                up_req_cnt++;
                up_req.push_back(req);
                $display("    sb get up req: tag=%d, index=%d, id=%d", req.addr.tag, req.addr.index, req.txnid);
            end
            forever begin
                @(posedge vif.clk);
                if(vif.upstream_txdat_vld===1)begin
                    tx_dat_cnt++;
                    foreach(up_req[i])begin
                        if(up_req[i].txnid == vif.upstream_txdat_txnid)begin
                            txnid_flag = 1;
                            if(up_req[i].addr !== vif.upstream_txdat_data)begin
                                $error("compare error when txnid=%0d",vif.upstream_txdat_txnid);
                                err_cnt++;
                            end else begin
                                $display("txnid %d compare pass",vif.upstream_txdat_txnid);
                            end
                            up_req.delete(i);
                        end
                    end
                    if(txnid_flag == 0)begin
                        $error("receive txnid=%0d error",vif.upstream_txdat_txnid);
                        err_cnt++;
                    end
                    else begin
                        txnid_flag = 0;
                    end
                end
            end
        join
    endtask

    task final_check();
        if(up_req.size()!=0)begin
            err_cnt++;
            $error("there %0d up req not processed!",up_req.size());
        end
        $display("PC send %0d up req, receive %0d tx dat",up_req_cnt,tx_dat_cnt);
        $display("PC send %0d tx req, receive %0d rx dat",drv.tx_req_cnt,drv.rx_dat_cnt);
        if(err_cnt==0)begin
            $display("------------------------------------TC PASSED------------------------------------");
        end else begin
            $display("------------------------------------TC FAILED------------------------------------");
        end
        $display("%0d req hit, %0d req miss",up_req_cnt-drv.tx_req_cnt,drv.tx_req_cnt);
        $display("Hit rate: %0.2f%%",(up_req_cnt-drv.tx_req_cnt) * 100.0 /up_req_cnt );
        $display("--------------------------------------------------------------------------------");
    endtask

endclass