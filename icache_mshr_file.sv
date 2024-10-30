module icache_mshr_file 
    import toy_pack::*;
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,    
    input  logic                                        prefetch_enable            ,
    input  logic [WAY_NUM-1:0]                          A_hit                      ,
    input  logic  [WAY_NUM-1:0]                         B_hit                      ,
    input  logic                                        A_miss                     ,
    input  logic                                        B_miss                     ,
    input  logic                                        mshr_update_en             ,
    //input  pc_req_t                                     mshr_update_pld            ,
    input  logic                                        pre_tag_req_vld            ,
    //input  pc_req_t                                     pre_tag_req_pld            ,
    output logic                                        alloc_vld                  ,
    output logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           alloc_index                ,
    input  logic                                        alloc_rdy                  ,
    output logic                                        miss_for_prefetch          ,
    input  logic                                        pref_to_mshr_req_rdy       ,
    output req_addr_t                                   miss_addr_for_prefetch     ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1 :0]          miss_txnid_for_prefetch    ,
    input  logic                                        dataram_rd_rdy             ,
    output logic                                        dataramA_rd_vld            , 
    output logic                                        dataramA_rd_way            ,
    output logic  [ICACHE_INDEX_WIDTH-1         :0]     dataramA_rd_index          ,
    output logic  [ICACHE_REQ_TXNID_WIDTH-1     :0]     dataramA_rd_txnid          ,
    output logic                                        dataramB_rd_vld            , 
    output logic                                        dataramB_rd_way            ,
    output logic  [ICACHE_INDEX_WIDTH-1         :0]     dataramB_rd_index          ,
    output logic  [ICACHE_REQ_TXNID_WIDTH-1     :0]     dataramB_rd_txnid          ,
    output mshr_entry_t                                 vv_mshr_entry_array[MSHR_ENTRY_NUM-1:0],
    input  logic                                        linefillA_done             ,
    input  logic                                        linefillB_done             ,
    input  logic [MSHR_ENTRY_INDEX_WIDTH    :0]         linefill_ack_entry_idx     ,
    output logic [MSHR_ENTRY_INDEX_WIDTH   :0]          entry_release_done_index   ,
    output logic                                        downstream_txreq_vld       ,
    input  logic                                        downstream_txreq_rdy       ,
    output downstream_txreq_t                           downstream_txreq_pld       ,
    output logic [MSHR_ENTRY_INDEX_WIDTH-1 :0]          downstream_txreq_entry_id  ,
    input  logic                                        downstream_txrsp_vld       ,//TODO
    output logic                                        downstream_txrsp_rdy       ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,//TODO        
    input  logic [MSHR_ENTRY_NUM-1         :0]          v_A_hazard_bitmap           ,
    input  logic [MSHR_ENTRY_NUM-1         :0]          v_B_hazard_bitmap           ,
    input  logic                                        bypass_rd_dataramA_vld      ,
    input  logic                                        bypass_rd_dataramB_vld      ,
    input  dataram_rd_pld_t                             bypass_rd_dataramA_pld      ,
    input  dataram_rd_pld_t                             bypass_rd_dataramB_pld      ,
    input  logic                                        A_index_way_checkpass       ,
    input  logic                                        B_index_way_checkpass       ,
    input  entry_data_t                                 entry_data                  ,
    output logic                                        mshr_stall                  
    //input  logic                                        index_way_checkpass                                     
);
    dataram_rd_pld_t                                    dataramA_rd_pld      ;
    dataram_rd_pld_t                                    dataramB_rd_pld      ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_entry_en                                      ;
    logic  [MSHR_ENTRY_INDEX_WIDTH-1 :0]                allocate_index                                  ;
    logic                                               allocate_index_vld                              ;

    logic  [MSHR_ENTRY_NUM-1         :0]                v_entry_active                                  ;  

    logic  [MSHR_ENTRY_NUM-1         :0]                v_alloc_vld                                     ; 
    logic  [MSHR_ENTRY_NUM-1         :0]                v_alloc_rdy                                     ;

    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataram_rd_vld                                ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataram_rd_rdy                                ;
    dataram_rd_pld_t                                    v_dataram_rd_pld           [MSHR_ENTRY_NUM-1:0] ;
    dataram_rd_pld_t                                    dataram_rd_pld                                  ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_txreq_vld                          ;
    downstream_txreq_t                                  v_downstream_txreq_pld     [MSHR_ENTRY_NUM-1:0] ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_txreq_rdy                          ;

    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_txrsp_vld                          ;
    logic  [ICACHE_REQ_OPCODE_WIDTH-1:0]                v_downstream_txrsp_opcode  [MSHR_ENTRY_NUM-1:0] ;

    logic  [MSHR_ENTRY_INDEX_WIDTH-1 :0]                dataram_release_index                           ;
    logic                                               dataram_release_index_vld                       ;
    logic  [MSHR_ENTRY_INDEX_WIDTH   :0]                downstream_release_index                        ; 
    //logic                                               downstream_release_index_vld                    ; 
    
    logic  [MSHR_ENTRY_NUM-1         :0]                v_entry_release_done                            ;
    
    logic                                               arb_dataram_rd_vld                              ;
    logic                                               arb_dataram_rd_rdy                              ;
    dataram_rd_pld_t_ab                                 arb_dataram_rd_pld                              ;

    logic [MSHR_ENTRY_INDEX_WIDTH-1 :0]                 taken_index                                     ;
    logic                                               index_vld                                       ;
     
    logic [MSHR_ENTRY_NUM-1         :0]                 v_release_en                                    ;
    dataram_rd_pld_t                                    v_dataramA_rd_pld[MSHR_ENTRY_NUM-1:0]           ;
    dataram_rd_pld_t                                    v_dataramB_rd_pld[MSHR_ENTRY_NUM-1:0]           ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataramA_rd_vld                               ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataramB_rd_vld                               ;
    logic  [MSHR_ENTRY_NUM-1         :0] v_linefillA_done;
    logic  [MSHR_ENTRY_NUM-1         :0] v_linefillB_done;
   
    assign downstream_txrsp_rdy = 1'b1                                                             ;
    assign dataramA_rd_vld      = bypass_rd_dataramA_vld | bypass_rd_dataramB_vld | arb_dataram_rd_vld;
    assign dataramA_rd_pld      = bypass_rd_dataramA_vld ? bypass_rd_dataramA_pld : arb_dataram_rd_pld.req_pldA;
    assign dataramB_rd_vld      = bypass_rd_dataramA_vld | bypass_rd_dataramB_vld | arb_dataram_rd_vld;
    assign dataramB_rd_pld      = bypass_rd_dataramB_vld ? bypass_rd_dataramB_pld : arb_dataram_rd_pld.req_pldB;
    assign dataramA_rd_way      = dataramA_rd_pld.rd_way                                  ;
    assign dataramA_rd_index    = dataramA_rd_pld.rd_index                                ;
    assign dataramA_rd_txnid    = dataramA_rd_pld.rd_txnid                                ;
    assign dataramB_rd_way      = dataramB_rd_pld.rd_way                                  ;
    assign dataramB_rd_index    = dataramB_rd_pld.rd_index                                ;
    assign dataramB_rd_txnid    = dataramB_rd_pld.rd_txnid                                ;
    assign mshr_stall           = ( (&v_entry_active)==1'b1)                              ;
    //assign alloc_index              = (mshr_update_en && index_vld) ? taken_index : {(MSHR_ENTRY_INDEX_WIDTH+1){1'b1}}                ;
    assign alloc_index              = (mshr_update_en && index_vld) ? taken_index : 'b0               ;
    //assign alloc_index              = (mshr_update_en && alloc_vld) ? taken_index : 'b0               ;
    assign arb_dataram_rd_rdy       = bypass_rd_dataramA_vld ? 1'b0 : dataram_rd_rdy                  ;
    assign downstream_txreq_entry_id= downstream_release_index[MSHR_ENTRY_INDEX_WIDTH-1 :0]           ;


    pre_allocate #(
        .ENTRY_NUM      (MSHR_ENTRY_NUM         ),
        .INDEX_WIDTH    (MSHR_ENTRY_INDEX_WIDTH )
    )  u_pre_allocate(
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .cre_tag_req_vld(pre_tag_req_vld        ),
        .rdy_in         (alloc_rdy              ),
        .v_vld_in       (v_alloc_vld            ),
        .taken_vld      (alloc_vld              ),
        .v_rdy_out      (v_alloc_rdy            ),
        .taken_index    (taken_index            ),
        .index_vld      (index_vld              )
    );
    //pre_allocate #(
    //    .MSHR_ENTRY_NUM   (MSHR_ENTRY_NUM),
    //    .INDEX_WIDTH (MSHR_ENTRY_INDEX_WIDTH)
    //) u_pre_allocate(
    //    .clk        (clk        ),
    //    .rst_n      (rst_n      ),
    //    .v_in_vld   (v_alloc_vld),
    //    .v_in_rdy   (v_alloc_rdy),
    //    .out_vld    (alloc_vld  ),
    //    .out_rdy    (alloc_rdy  ),
    //    .out_index  (taken_index)
    //);

    v_en_decode #(
        .WIDTH          (MSHR_ENTRY_NUM         )
    )   u_entry_en_dec (
        .enable         (mshr_update_en         ),
        //.enable_index   (alloc_index[MSHR_ENTRY_NUM-1:0]),
        .enable_index   (alloc_index            ),
        .v_out_en       (v_entry_en             ));

    v_en_decode #(
        .WIDTH          (MSHR_ENTRY_NUM          )
    )   u_linefillA_done_dec (
        .enable         (linefillA_done          ),
        .enable_index   (linefill_ack_entry_idx[MSHR_ENTRY_INDEX_WIDTH-1:0]  ),
        .v_out_en       (v_linefillA_done        ));
    v_en_decode #(
        .WIDTH          (MSHR_ENTRY_NUM          )
    )   u_linefillB_done_dec (
        .enable         (linefillB_done          ),
        .enable_index   (linefill_ack_entry_idx[MSHR_ENTRY_INDEX_WIDTH-1:0]  ),
        .v_out_en       (v_linefillB_done        ));


    ////entry_release_done  index
    cmn_onehot2bin2  #(
            .ONEHOT_WIDTH   (MSHR_ENTRY_NUM             )
    ) u_release_done_index(
            .onehot_in      (v_release_en               ),
            .bin_out        (entry_release_done_index   )
        );
    
    cmn_onehot2bin2   #(
            .ONEHOT_WIDTH   (MSHR_ENTRY_NUM             )
    ) u_downstream_req_entry_index(
            .onehot_in      (v_downstream_txreq_rdy     ),
            .bin_out        (downstream_release_index   )
        );

    generate
        for (genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin:MSHR_ENTRY_ARRAY
            icache_mshr_entry  u_icache_mshr_entry(
            .clk                    (clk                        ),
            .rst_n                  (rst_n                      ),
            .A_hit                  (A_hit                      ),
            .B_hit                  (B_hit                      ),
            .A_miss                 (A_miss                     ),
            .B_miss                 (B_miss                     ),
            .bypass_rd_dataramA_vld (bypass_rd_dataramA_vld     ),
            .bypass_rd_dataramB_vld (bypass_rd_dataramA_vld     ),
            .v_A_hazard_bitmap      (v_A_hazard_bitmap          ),
            .v_B_hazard_bitmap      (v_B_hazard_bitmap          ),
            .A_index_way_checkpass  (A_index_way_checkpass      ),
            .B_index_way_checkpass  (B_index_way_checkpass      ),
            .alloc_vld              (v_alloc_vld[i]             ),
            .alloc_rdy              (v_alloc_rdy[i]             ),
            .dataram_rd_rdy         (v_dataram_rd_rdy[i]        ),
            .dataramA_rd_vld        (v_dataramA_rd_vld[i]       ),
            .dataramA_rd_pld        (v_dataramA_rd_pld[i]       ),
            .dataramB_rd_vld        (v_dataramB_rd_vld[i]       ),
            .dataramB_rd_pld        (v_dataramB_rd_pld[i]       ),
            .entry_active           (v_entry_active[i]          ),
            .entry_data             (entry_data                 ),
            .entry_en               (v_entry_en[i]              ),
            .downstream_txreq_vld   (v_downstream_txreq_vld[i]  ),
            .downstream_txreq_rdy   (v_downstream_txreq_rdy[i]  ),
            .downstream_txreq_pld   (v_downstream_txreq_pld[i]  ),
            .mshr_entry_array       (vv_mshr_entry_array[i]     ),
            .linefillA_done         (v_linefillA_done[i]        ),
            .linefillB_done         (v_linefillB_done[i]        ),
            .v_release_en           (v_release_en               ),
            .release_en             (v_release_en[i]            ));
        end
    endgenerate

    dataram_rd_pld_t_ab v_dataram_rd_pld_AB [MSHR_ENTRY_NUM-1:0] ;
    //generate
    //    for (genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin:gen DATARAM_PLD
    //        assign v_dataram_rd_pld_AB[i].req_pldA = v_dataramA_rd_pld[i];
    //        assign v_dataram_rd_pld_AB[i].req_pldB = v_dataramB_rd_pld[i];
    //    end
    //endgenerate
    always_comb begin
        for (int i=0;i<MSHR_ENTRY_NUM;i=i+1)begin
            v_dataram_rd_pld_AB[i].req_pldA = v_dataramA_rd_pld[i];
            v_dataram_rd_pld_AB[i].req_pldB = v_dataramB_rd_pld[i];
        end
    end


    vrp_arb #(
        .WIDTH          (MSHR_ENTRY_NUM         ),
        //.PRIORITY       ({MSHR_ENTRY_NUM{1'b1}} ),
        .PLD_WIDTH      ($bits(dataram_rd_pld_t_ab))
    ) u_dataram_rd_arb (
        .v_vld_s(v_dataramA_rd_vld   ),
        .v_rdy_s(v_dataram_rd_rdy    ),
        .v_pld_s(v_dataram_rd_pld_AB ),
        .vld_m  (arb_dataram_rd_vld  ),
        .rdy_m  (arb_dataram_rd_rdy  ),
        .pld_m  (arb_dataram_rd_pld  )
    );

    vrp_arb #(
        .WIDTH          (MSHR_ENTRY_NUM ),
        //.PRIORITY       ({MSHR_ENTRY_NUM{1'b1}}),
        .PLD_WIDTH      ($bits(downstream_txreq_t))
    ) u_downstream_rd_arb (
        .v_vld_s(v_downstream_txreq_vld),
        .v_rdy_s(v_downstream_txreq_rdy),
        .v_pld_s(v_downstream_txreq_pld),
        .vld_m  (downstream_txreq_vld  ),
        .rdy_m  (downstream_txreq_rdy  ),
        .pld_m  (downstream_txreq_pld  )
    );

    always_comb begin
        if(prefetch_enable == 1'b1 )begin
            if( pref_to_mshr_req_rdy && downstream_txreq_pld.pld.opcode == UPSTREAM_OPCODE )begin
                miss_for_prefetch       = 1'b1;
                miss_addr_for_prefetch  = v_downstream_txreq_pld[downstream_release_index[MSHR_ENTRY_INDEX_WIDTH-1:0]].pld.addr;
                miss_txnid_for_prefetch = v_downstream_txreq_pld[downstream_release_index[MSHR_ENTRY_INDEX_WIDTH-1:0]].pld.txnid;
            end
            else begin
                miss_for_prefetch       = 1'b0;
                miss_addr_for_prefetch  = '{default: '0} ;
                miss_txnid_for_prefetch = 'b0;
            end
        end
        else begin
            miss_for_prefetch           = 'b0;
            miss_addr_for_prefetch      = 'b0;
            miss_txnid_for_prefetch     = 'b0;
        end
    end


endmodule

