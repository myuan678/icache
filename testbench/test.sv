class test;
    request     req         ;
    scoreboard  sb          ;
    mailbox     up_req_mbx  ;
    int         delay,txnid,index,tag;
    string      testname    ;

    function new();
        req             = new;
        sb              = new;
        sb.drv          = req;
        up_req_mbx      = new;
        req.up_req_mbx  = up_req_mbx;
        sb.up_req_mbx   = up_req_mbx;
    endfunction

    task run();
        #500ns;
        fork
            testcase();
            sb.compare();
            req.gen_rxdat();
        join_any
    endtask

    task testcase();
        $value$plusargs("testname=%s", testname);
        case(testname)
            "sanity":begin
                for(int i=1; i<20; i++)begin
                   delay = $urandom_range(3,5);
                   req.send_upstream_req(i, i, i);
                   //$display("send a UP req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                   repeat(delay)@(posedge icache_tb_top.clk);
                end
            end
            "conflict":begin
                for(int i=1;i<30;i++)begin
                    tag   = $urandom_range(1,3);
                    index = $urandom_range(1,2);
                    txnid = i%32;
                    @(posedge icache_tb_top.clk);
                    req.send_upstream_req(tag,index,txnid);
                    $display("send a upreq, tag= %h, index= %h, id=%h, %t", tag, index, txnid, $realtime);
                end
            end
        endcase
    endtask

endclass