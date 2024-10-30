module icache_top
    import toy_pack::*;
    (
    input  logic                                        clk                         ,
    input  logic                                        rst_n                       ,
    input  logic                                        prefetch_enable             ,
    //upstream txdat  out
    output logic [ICACHE_UPSTREAM_DATA_WIDTH-1 :0]      upstream_txdat_data         ,
    output logic                                        upstream_txdat_vld          ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1     :0]      upstream_txdat_txnid        ,
    input  logic                                        upstream_txdat_rdy          ,

    //upstream rxreq
    input  logic                                        upstream_rxreq_vld          ,
    output logic                                        upstream_rxreq_rdy          ,
    /////////try to match intereface with bpu
    input  pc_req_t                                     upstream_rxreq_pld          ,
    //input req_addr_t                                    upstream_rxreq_addr,
    //input logic [ICACHE_REQ_TXNID_WIDTH-1     :0]       upstream_rxreq_txnid,
    /////////end

    //downstream rxsnp
    input  logic                                        downstream_rxsnp_vld        ,
    output logic                                        downstream_rxsnp_rdy        ,
    input  pc_req_t                                     downstream_rxsnp_pld        ,

    //downtream txreq
    output logic                                        downstream_txreq_vld        ,
    input  logic                                        downstream_txreq_rdy        ,
    output downstream_txreq_t                           downstream_txreq_pld        ,

    output logic [MSHR_ENTRY_INDEX_WIDTH-1      :0]     downstream_txreq_entry_id   ,

    //downstream txrsp
    input  logic                                        downstream_txrsp_vld        ,
    output logic                                        downstream_txrsp_rdy        ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1     :0]     downstream_txrsp_opcode     ,

    //downstream rxdat  in
    input  logic                                        downstream_rxdat_vld        ,
    output logic                                        downstream_rxdat_rdy        ,
    input  downstream_rxdat_t                           downstream_rxdat_pld        ,

    input logic                                         prefetch_req_vld            ,
    input pc_req_t                                      prefetch_req_pld            ,

    input  logic                                        pref_to_mshr_req_rdy


    );

    //pc_req_t                                            upstream_rxreq_pld          ;
    //assign upstream_rxreq_pld.addr  = upstream_rxreq_addr;
    //assign upstream_rxreq_pld.txnid = upstream_rxreq_txnid;
    //assign upstream_rxreq_pld.opcode= UPSTREAM_OPCODE;

    //logic                                               prefetch_req_vld            ;
    logic                                        prefetch_req_rdy                       ;
    logic                                        tag_req_vld                            ;
    logic                                        tag_req_rdy                            ;
    pc_req_t                                     tag_req_pld                            ;
    mshr_entry_t                                 vv_mshr_entry_array[MSHR_ENTRY_NUM-1:0];
    logic[WAY_NUM-1:0]                           A_hit                                  ;
    logic[WAY_NUM-1:0]                           B_hit                                  ;
    logic                                        A_miss                                 ;
    logic                                        B_miss                                 ;
    logic                                        pre_tag_req_vld                        ;         
    pc_req_t                                     pre_tag_req_pld                        ;         
    logic                                        mshr_update_en                         ;
    entry_data_t                                 entry_data                             ;
    logic                                        bypass_rd_dataramA_vld                 ;
    dataram_rd_pld_t                             bypass_rd_dataramA_pld                 ;
    logic                                        bypass_rd_dataramB_vld                 ;
    dataram_rd_pld_t                             bypass_rd_dataramB_pld                 ;
    logic                                        A_index_way_checkpass                  ;
    logic                                        B_index_way_checkpass                  ;
    logic [MSHR_ENTRY_NUM-1:0]                   v_A_hazard_bitmap                      ;
    logic [MSHR_ENTRY_NUM-1:0]                   v_B_hazard_bitmap                      ;
    logic [MSHR_ENTRY_INDEX_WIDTH:0]             entry_release_done_index               ;
    logic                                        stall                                  ;
    pc_req_t                                     mshr_update_pld                        ;
    logic                                        alloc_vld                              ;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           alloc_index                            ;
    logic                                        alloc_rdy                              ;
    logic                                        miss_for_prefetch                      ;
    
    req_addr_t                                   miss_addr_for_prefetch                 ;
    logic [ICACHE_REQ_TXNID_WIDTH-1 :0]          miss_txnid_for_prefetch                ;
    logic                                        dataram_rd_rdy                         ;
    logic                                        dataramA_rd_vld                        ;
    logic                                        dataramA_rd_way                        ;
    logic  [ICACHE_INDEX_WIDTH-1         :0]     dataramA_rd_index                      ;
    logic  [ICACHE_REQ_TXNID_WIDTH-1     :0]     dataramA_rd_txnid                      ;
    logic                                        dataramB_rd_vld                        ;
    logic                                        dataramB_rd_way                        ;
    logic  [ICACHE_INDEX_WIDTH-1         :0]     dataramB_rd_index                      ;
    logic  [ICACHE_REQ_TXNID_WIDTH-1     :0]     dataramB_rd_txnid                      ;
    logic                                        linefillA_done                         ;
    logic                                        linefillB_done                         ;
    logic [MSHR_ENTRY_INDEX_WIDTH    :0]         linefill_ack_entry_idx                 ; 
    logic                                        mshr_stall                             ;
    logic                                        dataram_rd_vld                         ;
    logic                                        dataram_rd_way                         ;
    logic [ICACHE_INDEX_WIDTH-1     :0]          dataram_rd_index                       ;
    logic [ICACHE_REQ_TXNID_WIDTH-1 :0]          dataram_rd_txnid                       ;
    mshr_entry_t                                 mshr_entry_linefill_msg                ;
    logic [MSHR_ENTRY_INDEX_WIDTH-1 :0]          mshr_linefill_done_idx                 ;
    logic                                        linefill_done                          ;
    logic[MSHR_ENTRY_NUM-1          :0]          v_linefill_done                        ;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           tag_req_idnex                          ;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           req_index                              ;
    logic [MSHR_ENTRY_NUM-1:0]                   bitmap                                 ;
    logic [MSHR_ENTRY_NUM-1:0]                   v_index_way_bitmap[MSHR_ENTRY_NUM-1:0] ;
    dataram_rd_pld_t                             rd_pld                                 ;
    logic [MSHR_ENTRY_NUM-1        :0]           v_index_way_release                    ;
    logic [MSHR_ENTRY_NUM-1        :0]           v_hit_entry_done                       ;
    pc_req_t                                     req_pld                                ;
    logic                                        index_way_checkpass                    ;
    



    icache_req_arbiter u_icache_req_arbiter (
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .upstream_rxreq_vld         (upstream_rxreq_vld         ),
        .upstream_rxreq_rdy         (upstream_rxreq_rdy         ),
        .upstream_rxreq_pld         (upstream_rxreq_pld         ),
        .downstream_rxsnp_vld       (downstream_rxsnp_vld       ),
        .downstream_rxsnp_rdy       (downstream_rxsnp_rdy       ),
        .downstream_rxsnp_pld       (downstream_rxsnp_pld       ),
        .prefetch_req_vld           (prefetch_req_vld           ),
        .prefetch_req_rdy           (prefetch_req_rdy           ),
        .prefetch_req_pld           (prefetch_req_pld           ),
        .alloc_vld                  (alloc_vld                  ),
        .alloc_rdy                  (alloc_rdy                  ),
        .alloc_index                (alloc_index                ),
        .tag_req_vld                (tag_req_vld                ),
        .tag_req_rdy                (tag_req_rdy                ),
        .tag_req_index              (tag_req_idnex              ),
        .tag_req_pld                (tag_req_pld                )
    );

    icache_tag_array_ctrl u_icache_tag_array_ctrl (
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .dataram_rd_rdy             (dataram_rd_rdy             ),
        .tag_req_vld                (tag_req_vld                ),
        .tag_req_rdy                (tag_req_rdy                ),
        .tag_req_pld                (tag_req_pld                ),
        .tag_req_index              (tag_req_idnex              ),

        .pre_tag_req_vld            (pre_tag_req_vld            ),

        .A_hit                      (A_hit                      ),
        .B_hit                      (B_hit                      ),
        .A_miss                     (A_miss                     ),
        .B_miss                     (B_miss                     ),
       
        .mshr_update_en             (mshr_update_en             ),
        //.mshr_update_pld            (mshr_update_pld            ),
        .entry_data                 (entry_data                 ),
        .bypass_rd_dataramA_vld     (bypass_rd_dataramA_vld     ),
        .bypass_rd_dataramB_vld     (bypass_rd_dataramB_vld     ),
        .bypass_rd_dataramA_pld     (bypass_rd_dataramA_pld     ),
        .bypass_rd_dataramB_pld     (bypass_rd_dataramB_pld     ),
        .A_index_way_checkpass      (A_index_way_checkpass      ),
        .B_index_way_checkpass      (B_index_way_checkpass      ),
        .v_A_hazard_bitmap          (v_A_hazard_bitmap          ),
        .v_B_hazard_bitmap          (v_B_hazard_bitmap          ),
        
        .entry_release_done_index   (entry_release_done_index   ),
        .vv_mshr_entry_array        (vv_mshr_entry_array        ),
        .stall                      (mshr_stall                 )
    );

    icache_mshr_file u_icache_mshr_file (
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .prefetch_enable            (prefetch_enable            ),
        .A_hit                      (A_hit                      ),
        .B_hit                      (B_hit                      ),
        .A_miss                     (A_miss                     ),
        .B_miss                     (B_miss                     ),
        .mshr_update_en             (mshr_update_en             ),
        //.mshr_update_pld            (mshr_update_pld            ),
        .pre_tag_req_vld            (pre_tag_req_vld            ),
        //.pre_tag_req_pld            (pre_tag_req_pld            ),
        .alloc_vld                  (alloc_vld                  ),
        .alloc_rdy                  (alloc_rdy                  ),
        .alloc_index                (alloc_index                ),

        .pref_to_mshr_req_rdy       (pref_to_mshr_req_rdy       ),
        //.miss_addr_for_prefetch     (miss_addr_for_prefetch     ),
        //.miss_txnid_for_prefetch    (miss_txnid_for_prefetch    ),
        //.miss_for_prefetch          (prefetch_en                ),
        .miss_addr_for_prefetch     (                           ),
        .miss_txnid_for_prefetch    (                           ),
        .miss_for_prefetch          (                           ),
        .dataram_rd_rdy             (dataram_rd_rdy             ),
        .dataramA_rd_vld            (dataramA_rd_vld            ),
        .dataramA_rd_way            (dataramA_rd_way            ),
        .dataramA_rd_index          (dataramA_rd_index          ),
        .dataramA_rd_txnid          (dataramA_rd_txnid          ),
        .dataramB_rd_vld            (dataramB_rd_vld            ),
        .dataramB_rd_way            (dataramB_rd_way            ),
        .dataramB_rd_index          (dataramB_rd_index          ),
        .dataramB_rd_txnid          (dataramB_rd_txnid          ),

        .downstream_txreq_vld       (downstream_txreq_vld       ),
        .downstream_txreq_rdy       (downstream_txreq_rdy       ),
        .downstream_txreq_pld       (downstream_txreq_pld       ),
        .downstream_txreq_entry_id  (downstream_txreq_entry_id  ),
        .downstream_txrsp_vld       (downstream_txrsp_vld       ),
        .downstream_txrsp_rdy       (downstream_txrsp_rdy       ),
        .downstream_txrsp_opcode    (downstream_txrsp_opcode    ),

        .vv_mshr_entry_array        (vv_mshr_entry_array        ),
        .linefill_ack_entry_idx     (linefill_ack_entry_idx     ),
        .linefillA_done             (linefillA_done             ),
        .linefillB_done             (linefillB_done             ),
        .entry_release_done_index   (entry_release_done_index   ),
        .v_A_hazard_bitmap          (v_A_hazard_bitmap          ),
        .v_B_hazard_bitmap          (v_B_hazard_bitmap          ),
        .bypass_rd_dataramA_vld     (bypass_rd_dataramA_vld     ),
        .bypass_rd_dataramB_vld     (bypass_rd_dataramB_vld     ),
        .bypass_rd_dataramA_pld     (bypass_rd_dataramA_pld     ),
        .bypass_rd_dataramB_pld     (bypass_rd_dataramB_pld     ),
        .entry_data                 (entry_data                 ),
        .mshr_stall                 (mshr_stall                 ),
        .A_index_way_checkpass      (A_index_way_checkpass      ),
        .B_index_way_checkpass      (B_index_way_checkpass      )
        
    );


//dataarray ctrl with linefill in
    icache_data_array_ctrl u_data_array_ctrl(
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .vv_mshr_entry_array_msg    (vv_mshr_entry_array        ),
        .dataram_rd_rdy             (dataram_rd_rdy             ),

        .dataramA_rd_vld            (dataramA_rd_vld            ),
        .dataramA_rd_way            (dataramA_rd_way            ),
        .dataramA_rd_index          (dataramA_rd_index          ),
        .dataramA_rd_txnid          (dataramA_rd_txnid          ),

        .dataramB_rd_vld            (dataramB_rd_vld            ),
        .dataramB_rd_way            (dataramB_rd_way            ),
        .dataramB_rd_index          (dataramB_rd_index          ),
        .dataramB_rd_txnid          (dataramB_rd_txnid          ),

        .downstream_rxdat_vld       (downstream_rxdat_vld       ),
        .downstream_rxdat_rdy       (downstream_rxdat_rdy       ),
        .downstream_rxdat_pld       (downstream_rxdat_pld       ),

        .linefill_ack_entry_idx     (linefill_ack_entry_idx     ),
        .linefillA_done             (linefillA_done             ),
        .linefillB_done             (linefillB_done             ),

        .upstream_txdat_data        (upstream_txdat_data        ),
        .upstream_txdat_vld         (upstream_txdat_vld         ),
        .upstream_txdat_txnid       (upstream_txdat_txnid       )
    );

    //icache_prefetch_engine u_prefetch_engine (
    //    .clk                        (clk                        ),
    //    .rst_n                      (rst_n                      ),
    //    .miss_for_prefetch          (prefetch_en                ),
    //    .miss_addr_for_prefetch     (miss_addr_for_prefetch     ),
    //    .miss_txnid_for_prefetch    (miss_txnid_for_prefetch    ),
    //    .pref_to_mshr_req_rdy       (pref_to_mshr_req_rdy       ),
    //    .prefetch_req_vld           (prefetch_req_vld           ),
    //    .prefetch_req_rdy           (prefetch_req_rdy           ),
    //    .prefetch_req_pld           (prefetch_req_pld           )
    //);


endmodule
