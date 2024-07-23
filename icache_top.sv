module icache_top
    import toy_pack::*;
    (
    input  logic                                        clk                         ,
    input  logic                                        rst_n                       ,

    //upstream txdat  out
    output logic [ICACHE_UPSTREAM_DATA_WIDTH-1:0]       upstream_txdat_data         , 
    output logic                                        upstream_txdat_en           ,

    //upstream rxreq
    input  logic                                        upstream_rxreq_vld          ,
    output logic                                        upstream_rxreq_rdy          ,
    input  pc_req_t                                     upstream_rxreq_pld          ,

    //downstream rxsnp
    input  logic                                        downstream_rxsnp_vld        ,
    output logic                                        downstream_rxsnp_rdy        ,
    input  pc_req_t                                     downstream_rxsnp_pld        ,


    //downtream txreq
    output logic                                        downstream_txreq_vld        ,
    input  logic                                        downstream_txreq_rdy        ,
    output pc_req_t                                     downstream_txreq_pld        ,

    output logic [ICACHE_INDEX_WIDTH-1:0]               downstream_txreq_index      ,


    //downstream txrsp
    input  logic                                        downstream_txrsp_vld        ,
    output logic                                        downstream_txrsp_rdy        ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode     ,
    
    //downstream rxdat  in
    input  logic                                        downstream_rxdat_vld        ,
    output logic                                        downstream_rxdat_rdy        ,
    input  downstream_rxdat_t                           downstream_rxdat_pld           
);

    logic                                               prefetch_req_vld            ;
    logic                                               prefetch_req_rdy            ;
    pc_req_t                                            prefetch_req_pld            ;   

    logic                                               tag_req_vld                 ;
    logic                                               tag_req_rdy                 ;
    logic                                               tagram_req_rdy              ;
    logic                                               mshr_tag_req_rdy            ;
    pc_req_t                                            tag_req_pld                 ;
    

    logic                                               tag_miss                    ;
    logic [WAY_NUM-1:0]                                 tag_hit                     ;
    logic                                               lru_pick                    ;
    logic                                               stall                       ;

    logic                                               prefetch_en                 ;  
    req_addr_t                                          miss_addr_for_prefetch      ;

    logic                                               dataram_rd_vld              ;
    logic                                               dataram_rd_rdy              ;
    logic                                               dataram_rd_way              ;
    logic [ICACHE_INDEX_WIDTH-1:0]                      dataram_rd_index            ;

    mshr_entry_t                                        v_mshr_entry_array[MSHR_ENTRY_NUM-1:0];
    mshr_entry_t                                        mshr_entry_linefill_msg     ;
    logic [MSHR_ENTRY_INDEX_WIDTH-1:0]                  mshr_linefill_done_idx      ;
    logic                                               linefill_done               ;

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
        .tag_req_vld                (tag_req_vld                ),    
        .tagram_req_rdy             (tagram_req_rdy             ), 
        .mshr_tag_req_rdy           (mshr_tag_req_rdy           ),   
        .tag_req_pld                (tag_req_pld                )    
    );

    icache_tag_array_ctrl u_icache_tag_array_ctrl (
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .tag_req_vld                (tag_req_vld                ),
        .tagram_req_rdy             (tagram_req_rdy             ),
        .tag_req_pld                (tag_req_pld                ),
        .tag_miss                   (tag_miss                   ),
        .tag_hit                    (tag_hit                    ),
        .lru_pick                   (lru_pick                   ),
        .stall                      (stall                      )
    );

    icache_mshr_file u_icache_mshr_file (
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .tag_req_vld                (tag_req_vld                ),
        .mshr_tag_req_rdy           (mshr_tag_req_rdy           ),
        .tag_req_pld                (tag_req_pld                ),
        .tag_hit                    (tag_hit                    ),
        .tag_miss                   (tag_miss                   ),
        .lru_pick                   (lru_pick                   ),
        .stall                      (stall                      ),  
        .miss_for_prefetch          (prefetch_en                ),
        .miss_addr_for_prefetch     (miss_addr_for_prefetch     ),
        .dataram_rd_vld             (dataram_rd_vld             ),
        .dataram_rd_rdy             (dataram_rd_rdy             ),
        .dataram_rd_way             (dataram_rd_way             ),
        .dataram_rd_index           (dataram_rd_index           ),
        .downstream_txreq_vld       (downstream_txreq_vld       ),
        .downstream_txreq_rdy       (downstream_txreq_rdy       ),
        .downstream_txreq_pld       (downstream_txreq_pld       ),
        .downstream_txreq_index     (downstream_txreq_index     ),
        .downstream_txrsp_vld       (downstream_txrsp_vld       ),
        .downstream_txrsp_rdy       (downstream_txrsp_rdy       ),
        .downstream_txrsp_opcode    (downstream_txrsp_opcode    ),
        .v_mshr_entry_array         (v_mshr_entry_array         ),
        .linefill_ack_index         (mshr_linefill_done_idx     ),
        .linefill_done              (linefill_done              )
    );
//dataarray ctrl with linefill in
    icache_data_array_ctrl u_data_array_ctrl(
        .clk                        (clk                        ), 
        .rst_n                      (rst_n                      ),
        .dataram_rd_vld             (dataram_rd_vld             ),
        .dataram_rd_rdy             (dataram_rd_rdy             ),
        .dataram_rd_way             (dataram_rd_way             ),      
        .dataram_rd_index           (dataram_rd_index           ),

        //TODO:linefill_msg
        .mshr_entry_array_msg       (v_mshr_entry_array         ),
        .linefill_done              (linefill_done              ),
        .linefill_ack_mshr_index    (mshr_linefill_done_idx     ),
     
        .downstream_rxdat_vld       (downstream_rxdat_vld       ),
        .downstream_rxdat_rdy       (downstream_rxdat_rdy       ),
        .downstream_rxdat_pld       (downstream_rxdat_pld       ),
        .downstream_rxdat_entry_idx (downstream_rxdat_entry_idx ),
        .upstream_txdat_data        (upstream_txdat_data        ),
        .upstream_txdat_en          (upstream_txdat_en          ) 
    );

    icache_prefetch_engine u_prefetch_engine (
        .clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        .miss_for_prefetch          (prefetch_en                ),
        .miss_addr_for_prefetch     (miss_addr_for_prefetch     ),
        .prefetch_req_vld           (prefetch_req_vld           ),
        .prefetch_req_rdy           (prefetch_req_rdy           ),
        .prefetch_req_pld           (prefetch_req_pld           )
    );


endmodule