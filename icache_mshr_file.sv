module icache_mshr_file 
    import toy_pack::*;
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,    
    input  logic                                        prefetch_enable            ,
    input  logic                                        tag_req_vld                ,
    output logic                                        mshr_tag_req_rdy           ,
    input  pc_req_t                                     tag_req_pld                ,
    input  logic  [WAY_NUM-1:0]                         tag_hit                    , //2way
    input  logic                                        tag_miss                   ,
    input  logic                                        lru_pick                   ,

    output logic                                        miss_for_prefetch          ,
    input  logic                                        pref_to_mshr_req_rdy       ,
    output req_addr_t                                   miss_addr_for_prefetch     ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1 :0]          miss_txnid_for_prefetch    ,

    output logic                                        dataram_rd_vld             ,
    input  logic                                        dataram_rd_rdy             ,
    output logic                                        dataram_rd_way             ,
    output logic [ICACHE_INDEX_WIDTH-1     :0]          dataram_rd_index           ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1 :0]          dataram_rd_txnid           ,

    output mshr_entry_t                                 v_mshr_entry_array[MSHR_ENTRY_NUM-1:0],
    input  logic                                        linefill_done            ,
    input logic [MSHR_ENTRY_INDEX_WIDTH    :0]          linefill_ack_entry_idx  ,
 
    output logic                                        downstream_txreq_vld       ,
    input  logic                                        downstream_txreq_rdy       ,
    output pc_req_t                                     downstream_txreq_pld       ,
    output logic [MSHR_ENTRY_INDEX_WIDTH-1 :0]          downstream_txreq_entry_id     ,

    input  logic                                        downstream_txrsp_vld       ,//TODO
    output logic                                        downstream_txrsp_rdy       ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,//TODO

    output logic                                        mshr_stall                          
              
);
    
    logic  [MSHR_ENTRY_NUM-1         :0]                v_allocate_en                                   ;
    logic  [MSHR_ENTRY_INDEX_WIDTH-1 :0]                allocate_index                                  ;
    logic                                               allocate_index_vld                              ;
    logic                                               allocate_index_vld_d1                           ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_entry_valid                                   ;       
    logic  [MSHR_ENTRY_NUM-1         :0]                v_entry_idle                                    ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataram_rd_vld                                ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataram_rd_way                                ;
    logic  [ICACHE_INDEX_WIDTH-1     :0]                v_dataram_rd_index        [MSHR_ENTRY_NUM-1:0]  ;
    logic  [ICACHE_REQ_TXNID_WIDTH-1 :0]                v_dataram_rd_txnid        [MSHR_ENTRY_NUM-1:0]  ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_txreq_vld                          ;
    pc_req_t                                            v_downstream_txreq_pld     [MSHR_ENTRY_NUM-1:0] ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_txrsp_vld                          ;
    logic  [ICACHE_REQ_OPCODE_WIDTH-1:0]                v_downstream_txrsp_opcode  [MSHR_ENTRY_NUM-1:0] ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataram_rd_rdy                                ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_txreq_rdy                          ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_allocate                                      ;
    entry_data_t                                        entry_data                                      ; 
    logic  [MSHR_ENTRY_NUM-1         :0]                v_dataram_release_en                            ;
    logic  [MSHR_ENTRY_INDEX_WIDTH-1 :0]                dataram_release_index                           ;
    logic                                               dataram_release_index_vld                       ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_downstream_release_en                         ; 
    logic  [MSHR_ENTRY_INDEX_WIDTH-1 :0]                downstream_release_index                        ; 
    logic                                               downstream_release_index_vld                    ; 
    logic  [MSHR_ENTRY_INDEX_WIDTH   :0]                entry_release_done_index                        ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_entry_release_done                            ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_hit_entry_done                                ;
    logic  [WAY_NUM-1                :0]                tag_hit_d1                                      ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_hit_bitmap[MSHR_ENTRY_NUM-1:0]                ;
    logic  [MSHR_ENTRY_NUM-1         :0]                v_index_way_bitmap[MSHR_ENTRY_NUM-1:0]          ;
    logic                                               tag_miss_d1                                     ;
    entry_data_t                                        entry_data_d1                                   ; 
    pc_req_t                                            req_pld                                         ;
    logic                                               req_vld                                         ;
    logic                                               cre_tag_req_vld                                 ;
    pc_req_t                                            cre_tag_req_pld                                 ;

    logic [MSHR_ENTRY_NUM-1         :0]                 v_linefill_done;
    generate
        for(genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin
            always_comb begin
                v_linefill_done[i] = 'b0;
                if(i == linefill_ack_entry_idx)begin
                    v_linefill_done[i] = 1'b1;
                end
            end
        end
    endgenerate


    always_comb begin
        cre_tag_req_vld = 1'b0;
        cre_tag_req_pld = '{default:'0};
        if(tag_req_vld && mshr_tag_req_rdy )begin
            cre_tag_req_vld = tag_req_vld;
            cre_tag_req_pld = tag_req_pld;
        end
    end 
    //assign mshr_tag_req_rdy  = ~mshr_stall && allocate_index_vld   ;
    assign mshr_tag_req_rdy         = ~mshr_stall             ; //TODO
    //assign mshr_stall               = &v_entry_valid          ;
    always_comb begin
        if(&v_entry_valid == 1'b1)begin
            mshr_stall = 1'b1;
        end
        else begin
             mshr_stall = 1'b0;
        end
    end
    assign downstream_txrsp_rdy     = 1'b1                        ;
    assign allocate_req_en          = cre_tag_req_vld & (~req_vld);

    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            req_vld                 <= 1'b0                     ;
            req_pld                 <= '{default:'0}            ;       
        end else if(cre_tag_req_vld)begin
            req_vld                 <= 1'b1                     ;
            req_pld                 <= cre_tag_req_pld          ;
        end else begin
            req_vld                 <= 1'b0                     ; 
            req_pld                 <= '{default:'0}            ; 
        end
    end
    logic  [MSHR_ENTRY_INDEX_WIDTH-1 :0]                allocate_index_d1;
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            allocate_index_vld_d1  <= 'b0                   ;
            allocate_index_d1 <= 'b0;
        end
        else begin
            allocate_index_vld_d1  <= allocate_index_vld    ;
            allocate_index_d1 <= allocate_index;
        end
    end

    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            tag_hit_d1              <= 'b0                  ;
            tag_miss_d1             <= 1'b0                 ;
        end
        else if(allocate_index_vld | allocate_index_vld_d1)begin
            tag_hit_d1              <= tag_hit              ;
            tag_miss_d1             <= tag_miss             ;
        end
    end


    always_comb begin
        entry_data.pld          = '{default:'0}             ;
        entry_data.dest_way     = 0                         ;
        if(allocate_index_vld)begin
            entry_data.pld      = req_pld                   ;
            entry_data.dest_way = lru_pick                  ;
        end
    end


    pre_allocate #(
        .ENTRY_NUM              (MSHR_ENTRY_NUM         ),
        .INDEX_WIDTH            (MSHR_ENTRY_INDEX_WIDTH )
    ) u_pre_allocate (
        .clk                    (clk                    ),
        .rst_n                  (rst_n                  ),
        .allocate_entry_en      (allocate_req_en        ),
        .vld                    (v_entry_idle           ),
        .taken_vld              (allocate_index_vld     ),
        .taken_index            (allocate_index         )
    );

    generate 
        for(genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin
            always_comb begin
                v_allocate_en[i]        = 1'b0            ;
                if((i== allocate_index) && allocate_index_vld)begin
                    v_allocate_en [i]   = 1'b1            ;
                end
            end
        end
    endgenerate

    
    generate
        for (genvar k = 0; k < MSHR_ENTRY_NUM; k = k + 1) begin
            always_comb begin
                    v_index_way_bitmap[0][k]         = 1'b0;
                    v_index_way_bitmap[1][k]         = 1'b0;
                    v_index_way_bitmap[2][k]         = 1'b0;
                    v_index_way_bitmap[3][k]         = 1'b0;
                    v_index_way_bitmap[4][k]         = 1'b0;
                    v_index_way_bitmap[5][k]         = 1'b0;
                    v_index_way_bitmap[6][k]         = 1'b0;
                    v_index_way_bitmap[7][k]         = 1'b0;
            
                if(allocate_index_vld)begin
                    if(k==allocate_index)begin
                        v_index_way_bitmap[allocate_index][k]     = 1'b0;
                    end
                    else if(k==entry_release_done_index) begin
                        v_index_way_bitmap[allocate_index][k]     = 1'b0;
                    end
                    else if(v_linefill_done[k]== 1'b1 | v_hit_entry_done[k] == 1'b1)begin
                        v_index_way_bitmap[allocate_index][k]     = 1'b0;
                    end
                    else if ((v_mshr_entry_array[k].valid == 1'b1) && (v_mshr_entry_array[k].req_pld.addr.index == entry_data.pld.addr.index) && (v_mshr_entry_array[k].dest_way == entry_data.dest_way)) begin
                        v_index_way_bitmap[allocate_index][k]     = 1'b1;
                    end
                    
                    else begin
                        v_index_way_bitmap[allocate_index][k]     = 1'b0;
                    end
                end
                else begin
                    v_index_way_bitmap[allocate_index][k]         = 1'b0;
                end
            end
        end
    endgenerate

    logic  [MSHR_ENTRY_NUM-1         :0]                v_index_way_bit_keep[MSHR_ENTRY_NUM-1         :0];
    generate 
        for(genvar i = 0;i<MSHR_ENTRY_NUM;i=i+1)begin
            for(genvar j=0;j<MSHR_ENTRY_NUM;j=j+1)begin
                always_ff@(posedge clk or negedge rst_n) begin
                    if(!rst_n)begin
                        v_index_way_bit_keep[i][j] <= 1'b0;
                    end
                    else if(allocate_index_vld && i== allocate_index)begin
                        v_index_way_bit_keep[i][j] <= v_index_way_bitmap[i][j];
                    end
                    else if(v_linefill_done[j]==1'b1 | v_hit_entry_done[j]==1'b1)begin
                        v_index_way_bit_keep[i][j] <= 1'b0;
                    end
                end
            end
        end
    endgenerate 
    ////////////////////////

    ///data ram  request select
    cmn_lead_one #(
            .ENTRY_NUM      (MSHR_ENTRY_NUM             )
    ) u_mshr_dataram_credit(
            .v_entry_vld    (v_dataram_rd_vld           ),
            .v_free_idx_oh  (v_dataram_release_en       ),
            .v_free_idx_bin (dataram_release_index      ),
            .v_free_vld     (dataram_release_index_vld  )
        );

    ///downstream request select
    cmn_lead_one #(
            .ENTRY_NUM      (MSHR_ENTRY_NUM             )
    ) u_mshr_downstream_credit(
            .v_entry_vld    (v_downstream_txreq_vld     ),
            .v_free_idx_oh  (v_downstream_release_en    ),
            .v_free_idx_bin (downstream_release_index   ),
            .v_free_vld     (downstream_release_index_vld)
        );  

    ////entry_release_done  index
    cmn_onehot2bin2  #(
            .ONEHOT_WIDTH    (MSHR_ENTRY_NUM            )
    ) u_release_done_index(
            .onehot_in      (v_entry_release_done       ),
            .bin_out        (entry_release_done_index   )
        );

    always_comb begin 
        v_downstream_txreq_rdy = 'b0;
        for (int i = 0; i < MSHR_ENTRY_NUM; i=i+1)begin
            if(downstream_release_index == i)begin
                v_downstream_txreq_rdy  [i] = downstream_txreq_rdy;
            end
            else begin
                v_downstream_txreq_rdy  [i] = 1'b0;
            end
        end
    end

    always_comb begin
        v_dataram_rd_rdy = 'b0;
        for (int i = 0; i < MSHR_ENTRY_NUM; i=i+1)begin
            if(dataram_release_index == i)begin
                v_dataram_rd_rdy        [i] = dataram_rd_rdy ;
            end
            else begin
                v_dataram_rd_rdy        [i] = 1'b0;
            end
        end
    end

    generate
        for (genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin:MSHR_ENTRY_ARRAY
            icache_mshr_entry_buffer  u_icache_mshr_entry_buffer(
                .clk                     (clk                            ),
                .rst_n                   (rst_n                          ),
                .cre_tag_req_vld         (cre_tag_req_vld                ),
                .mshr_entry_array        (v_mshr_entry_array[i]          ),
                .tag_hit                 (tag_hit                        ),
                .tag_miss                (tag_miss                       ),
                .allocate_en             (v_allocate_en[i]               ),
                .entry_data              (entry_data                     ),
                .entry_index_way_bitmap  (v_index_way_bitmap[i]          ),
                .entry_index_way_bit_keep(v_index_way_bit_keep[i]        ),
                .entry_valid             (v_entry_valid[i]               ),
                .entry_idle              (v_entry_idle[i]                ),
                .entry_release_done      (v_entry_release_done[i]        ),
                .dataram_rd_vld          (v_dataram_rd_vld[i]            ),
                .dataram_rd_rdy          (v_dataram_rd_rdy[i]            ),
                .dataram_rd_way          (v_dataram_rd_way[i]            ),
                .dataram_rd_index        (v_dataram_rd_index[i]          ),
                .dataram_rd_txnid        (v_dataram_rd_txnid[i]          ),
                .dataram_release_en      (v_dataram_release_en[i]        ),
                .linefill_done           (v_linefill_done[i]             ),
                .hit_entry_done          (v_hit_entry_done[i]            ),
                .downstream_txreq_vld    (v_downstream_txreq_vld[i]      ),
                .downstream_txreq_rdy    (v_downstream_txreq_rdy[i]      ),
                .downstream_txreq_pld    (v_downstream_txreq_pld[i]      ),
                .downstream_release_en   (v_downstream_release_en[i]     )          
            );
        end
    endgenerate

    always_comb begin
        dataram_rd_way              = v_dataram_rd_way         [dataram_release_index]; 
        dataram_rd_index            = v_dataram_rd_index       [dataram_release_index];
        dataram_rd_txnid            = v_dataram_rd_txnid       [dataram_release_index];
        if(dataram_release_index_vld )begin
            dataram_rd_vld              = 1'b1; 
        end else begin
            dataram_rd_vld              = 'b0;
        end
    end

    always_comb begin
        downstream_txreq_pld            = v_downstream_txreq_pld   [downstream_release_index];
        downstream_txreq_entry_id       = downstream_release_index;
        if(downstream_release_index_vld )begin
            downstream_txreq_vld        = 1'b1;
            if(prefetch_enable == 1'b1 && pref_to_mshr_req_rdy && downstream_txreq_pld.opcode == UPSTREAM_OPCODE )begin
                miss_for_prefetch       = 1'b1;
                miss_addr_for_prefetch  = v_downstream_txreq_pld[downstream_release_index].addr;
                miss_txnid_for_prefetch = v_downstream_txreq_pld[downstream_release_index].txnid;
            end
            else begin
                miss_for_prefetch       = 1'b0;
                miss_addr_for_prefetch  = '{default: '0} ;
                miss_txnid_for_prefetch = 'b0;
            end
        end
        else begin
            downstream_txreq_vld        = 'b0;
            miss_for_prefetch           = 'b0;
            miss_addr_for_prefetch      = 'b0;
            miss_txnid_for_prefetch     = 'b0;
        end
    end


endmodule