module icache_top_tb();
    import toy_pack::*;
	
    logic                                        clk                         ;
    logic                                        rst_n                       ;

    logic                                        prefetch_enable             ;

    //upstream txdat  out
    logic [ICACHE_UPSTREAM_DATA_WIDTH-1:0]       upstream_txdat_data         ; 
    logic                                        upstream_txdat_vld           ;
    logic [ICACHE_REQ_TXNID_WIDTH-1:0]           upstream_txdat_txnid         ;

    //upstream rxreq
    logic                                        upstream_rxreq_vld          ;
    logic                                        upstream_rxreq_rdy          ;
    pc_req_t                                     upstream_rxreq_pld          ;

    //downstream rxsnp
    logic                                        downstream_rxsnp_vld        ;
    logic                                        downstream_rxsnp_rdy        ;
    pc_req_t                                     downstream_rxsnp_pld        ;


    //downtream txreq
    logic                                        downstream_txreq_vld        ;
    logic                                        downstream_txreq_rdy        ;
    pc_req_t                                     downstream_txreq_pld        ;

    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           downstream_txreq_entry_id   ;


    //downstream txrsp
    logic                                        downstream_txrsp_vld        ;
    logic                                        downstream_txrsp_rdy        ;
    logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode     ;
    
    //downstream rxdat  in
    logic                                        downstream_rxdat_vld        ;
    logic                                        downstream_rxdat_rdy        ;
    downstream_rxdat_t                           downstream_rxdat_pld        ;   

    //tb queue
    pc_req_t                                     up_req[$]          ;
	
    initial begin
    	clk = 0;
        upstream_rxreq_vld                <= 0;
        downstream_rxsnp_vld              <= 0;
        //prefetch_enable                   <= 1'b1;
        //downstream_txreq_rdy              <= 1'b1;
    	forever #10 clk = ~clk;
    end

    task send_upstream_req(input int tag, int index, int id);
        @(posedge clk);
        upstream_rxreq_vld              <= 1;
        upstream_rxreq_pld.addr.tag     <= tag;
        upstream_rxreq_pld.addr.index   <= index;
        upstream_rxreq_pld.addr.offset  <= {ICACHE_OFFSET_WIDTH{1'b1}};
        upstream_rxreq_pld.opcode       <= UPSTREAM_OPCODE;
        upstream_rxreq_pld.txnid        <= id;
        $display("send_upstream_req: tag=%d, index=%d, id=%d", tag, index, id);
        do begin
            @(posedge clk);
        end while(upstream_rxreq_rdy!==1'b1);
        up_req.push_back(upstream_rxreq_pld);
        upstream_rxreq_vld              <= 0;
        upstream_rxreq_pld.addr.tag     <= 0;
        upstream_rxreq_pld.addr.index   <= 0;
        upstream_rxreq_pld.addr.offset  <= 0;
        upstream_rxreq_pld.opcode       <= 0;
        upstream_rxreq_pld.txnid        <= 0;
        //end
    endtask

    task send_downstream_req(input int tag, int index, int id);
        @(posedge clk);
        downstream_rxsnp_vld              <= 1;
        downstream_rxsnp_pld.addr.tag     <= tag;
        downstream_rxsnp_pld.addr.index   <= index;
        downstream_rxsnp_pld.addr.offset  <= {ICACHE_OFFSET_WIDTH{1'b1}};
        downstream_rxsnp_pld.opcode       <= DOWNSTREAM_OPCODE;
        downstream_rxsnp_pld.txnid        <= id;
        $display("send_downstream_req: tag=%d, index=%d, id=%d", tag, index, id);
        //while(downstream_rxdat_rdy!==1'b1)begin
        //    @(posedge clk);
        //end
        do begin
            @(posedge clk);
        end while(downstream_rxsnp_rdy!==1'b1);
        downstream_rxsnp_vld              <= 0;
        downstream_rxsnp_pld.addr.tag     <= 0;
        downstream_rxsnp_pld.addr.index   <= 0;
        downstream_rxsnp_pld.addr.offset  <= 0;
        downstream_rxsnp_pld.opcode       <= 0;
        downstream_rxsnp_pld.txnid        <= 0;
    endtask 

assign prefetch_enable = 1'b0;
assign downstream_txreq_rdy = 1'b1;


initial begin
    int testcase = 3;
    int delay       ;
    int tag         ;
    int index       ;
    int txnid       ;

 	rst_n = 1       ;   
	#100 rst_n = 0  ;
    #100 rst_n = 1  ;
    @(posedge clk)  ;
    @(posedge clk)  ;
    @(posedge clk)  ;
    case(testcase)
        1:begin //read(miss)
            for(int i=1; i<20; i++)begin
                delay = $urandom_range(5, 30);
                #100;
                send_upstream_req(i, i, i);
                $display("i=%d, %t", i, $realtime);
                @(posedge clk);     
            end
        end
        2:begin//read(miss)---read(hit)
            fork
                begin
                    for(int i=1; i<30; i++)begin
                        delay = $urandom_range(5,6);
                        send_upstream_req(i, i, i);
                        $display("send a UP req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                        repeat(delay)@(posedge clk);
                    end
                end
                begin 
                    for(int i=1; i<30; i++)begin
                        delay = $urandom_range(5,6);
                        send_downstream_req(i, i, i);
                        $display("send a DOWN req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                        repeat(delay)@(posedge clk);
                    end
                end
            join 
            #500;
            for(int i=1; i<30; i++)begin
                delay = $urandom_range(10,15);
                send_upstream_req(i, i, i);
                $display("send a up req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                repeat(delay)@(posedge clk);
            end   
        end
        3:begin //random read(miss)---random read(hit)
            for(int i=1; i<50000; i++)begin
                tag   = $urandom_range(0,'h2_0000);
                index = $urandom_range(0,255);
                txnid = i%32;
                delay = $urandom_range(2,10);
                send_upstream_req(tag, index, txnid);
                $display("send a up req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                repeat(delay)@(posedge clk);
            end
        end
        4:begin //read(miss)---read(hit)---snp---read(miss)
            for(int i=1; i<100; i++)begin
                delay = $urandom_range(10,15);
                send_upstream_req(i, i, i);
                $display("send a up req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                repeat(delay)@(posedge clk);
            end
            #500;
            for(int i=1; i<100; i++)begin
                delay = $urandom_range(10,15);
                send_upstream_req(i, i, i);
                $display("send a up req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                repeat(delay)@(posedge clk);
            end
            #100;
            for(int i=1; i<100; i++)begin
                delay = $urandom_range(5, 30);
                #100;
                send_downstream_req(i, i, i);
                $display("i=%d, %t", i, $realtime);
                @(posedge clk);     
            end
            #500;
            for(int i=1; i<100; i++)begin
                delay = $urandom_range(10,15);
                send_upstream_req(i, i, i);
                $display("send a up req, tag=%h, index=%h, id=%h, %t", i,i,i, $realtime);
                repeat(delay)@(posedge clk);
            end
        end
    endcase
    #25000;
    if(up_req.size()!=0)$error("there %0d up req not processed!",up_req.size());
    #20000;
    $finish;
end


//-------------------------gen response rx data----------------------------//
initial begin
    int                                          rxdat_delay;
    pc_req_t                                     txreq;
    pc_req_t                                     txreq_q[$];
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           txreq_entry_id;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           txreq_entry_id_q[$];
    forever begin
        @(posedge downstream_txreq_vld);
        fork
            begin
                txreq_q.push_back(downstream_txreq_pld);
                txreq_entry_id_q.push_back(downstream_txreq_entry_id);
                rxdat_delay     = $urandom_range(20, 21);
                repeat(rxdat_delay)@(posedge clk);
                txreq = txreq_q.pop_front();
                txreq_entry_id = txreq_entry_id_q.pop_front();
                downstream_rxdat_vld                            <= 1;
                downstream_rxdat_pld.downstream_rxdat_opcode    <= txreq.opcode;
                downstream_rxdat_pld.downstream_rxdat_txnid     <= txreq.txnid;
                downstream_rxdat_pld.downstream_rxdat_data      <= txreq.addr;
                downstream_rxdat_pld.downstream_rxdat_entry_idx <= txreq_entry_id;
                $display("downstream_rxdat = %h   %t, remain pkt=%0d",txreq.addr,$realtime,txreq_q.size() );
        
                do begin
                    @(posedge clk);
                end while(downstream_rxdat_rdy!==1'b1);
                downstream_rxdat_vld                            <=  0;
                downstream_rxdat_pld.downstream_rxdat_opcode    <= 'b0;
                downstream_rxdat_pld.downstream_rxdat_txnid     <= 'b0;
                downstream_rxdat_pld.downstream_rxdat_data      <= 'b0;
                downstream_rxdat_pld.downstream_rxdat_entry_idx <= 'b0;
                    
            end
        join_none
        #0;
    end
end

//------------------------------checker-----------------------------//
initial begin
    int  txnid_flag=0;
    forever begin
        @(posedge upstream_txdat_vld);
        foreach(up_req[i])begin
            if(up_req[i].txnid == upstream_txdat_txnid)begin
                txnid_flag = 1;
                if(up_req[i].addr !== upstream_txdat_data)begin
                    $error("compare error when txnid=%0d",upstream_txdat_txnid);
                end else begin
                    $display("txnid %d compare pass",upstream_txdat_txnid);
                end
                up_req.delete(i);
            end
        end
        if(txnid_flag == 0)begin
            $error("receive txnid=%0d error",upstream_txdat_txnid);
        end 
        else begin
            txnid_flag = 0;
        end
        
    end

end

icache_top  dut (
    .clk                      (clk                    ),
    .rst_n                    (rst_n                  ),
    .prefetch_enable          (prefetch_enable        ),
    .upstream_txdat_data      (upstream_txdat_data    ),
    .upstream_txdat_vld       (upstream_txdat_vld     ),
    .upstream_txdat_txnid     (upstream_txdat_txnid   ),
    .upstream_rxreq_vld       (upstream_rxreq_vld     ),
    .upstream_rxreq_rdy       (upstream_rxreq_rdy     ),
    .upstream_rxreq_pld       (upstream_rxreq_pld     ),
    .downstream_rxsnp_vld     (downstream_rxsnp_vld   ),
    .downstream_rxsnp_rdy     (downstream_rxsnp_rdy   ),
    .downstream_rxsnp_pld     (downstream_rxsnp_pld   ),
    .downstream_txreq_vld     (downstream_txreq_vld   ),
    .downstream_txreq_rdy     (downstream_txreq_rdy   ),
    .downstream_txreq_pld     (downstream_txreq_pld   ),
    .downstream_txreq_entry_id(downstream_txreq_entry_id),
    .downstream_txrsp_vld     (downstream_txrsp_vld   ),
    .downstream_txrsp_rdy     (downstream_txrsp_rdy   ),
    .downstream_txrsp_opcode  (downstream_txrsp_opcode),
    .downstream_rxdat_vld     (downstream_rxdat_vld   ),
    .downstream_rxdat_rdy     (downstream_rxdat_rdy   ),
    .downstream_rxdat_pld     (downstream_rxdat_pld   ));
		

initial begin
    if($test$plusargs("WAVE")) begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars("+all");
        //$fsdbDumpMDA;
        $fsdbDumpon;
	end
end
endmodule