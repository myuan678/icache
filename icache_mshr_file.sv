module icache_mshr_file 
    import toy_pack::*;
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,    
    input  logic                                        tag_req_vld                ,
    output logic                                        mshr_tag_req_rdy           ,
    input  req_addr_t                                   tag_req_addr               ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          tag_req_opcode             ,
    input  logic [ICACHE_REQ_TXNID_WIDTH-1:0]           tag_req_txnid              ,

    input  logic  [WAY_NUM-1:0]                         tag_hit                    , //2way
    input  logic                                        tag_miss                   ,
    input  logic                                        lru_pick                   ,

    output logic                                        miss_for_prefetch          ,
    output req_addr_t                                   miss_addr_for_prefetch     ,

    output logic                                        dataram_rd_vld             ,
    input  logic                                        dataram_rd_rdy             ,
    output logic                                        dataram_rd_way             ,
    output logic [ICACHE_INDEX_WIDTH-1:0]               dataram_rd_index           ,

    output mshr_entry_t                                 v_mshr_entry_array[MSHR_ENTRY_NUM-1:0],
    input  logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           linefill_ack_index         ,
    input  logic                                        linefill_done              ,
 
    output logic                                        downstream_txreq_vld       ,
    input  logic                                        downstream_txreq_rdy       ,
    output logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txreq_opcode    ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1:0]           downstream_txreq_txnid     ,
    output req_addr_t                                   downstream_txreq_addr      ,
    output logic [ICACHE_INDEX_WIDTH-1:0]               downstream_txreq_index     ,

    input  logic                                        downstream_txrsp_vld       ,//TODO
    output logic                                        downstream_txrsp_rdy       ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,//TODO

    //output req_addr_t                                   miss_addr_for_prefetch     ,
    //output logic                                        miss_for_prefetch          ,

    output logic                                        stall                          
              
);

assign downstream_txrsp_rdy = 1'b1;

logic [MSHR_ENTRY_NUM-1:0]          v_entry_valid               ;       
logic [MSHR_ENTRY_NUM-1:0]          out_credict_entry_idx_oh    ;
logic [MSHR_ENTRY_INDEX_WIDTH-1:0]  out_credit_entry_index      ;
logic                               out_credit_vld              ; 

logic [MSHR_ENTRY_NUM-1:0]          v_entry_idle                ;
logic [MSHR_ENTRY_NUM-1:0]          in_credit_entry_idx_oh      ;
logic [MSHR_ENTRY_INDEX_WIDTH-1:0]  in_credit_entry_index       ;
logic                               in_credit_vld               ; 
logic [MSHR_ENTRY_NUM-1:0]          mshr_hit;
logic [MSHR_ENTRY_NUM-1:0]          mshr_miss;
logic                               mshr_full;

logic v_dataram_rd_vld          [MSHR_ENTRY_NUM-1:0];
logic v_dataram_rd_way          [MSHR_ENTRY_NUM-1:0];
logic [ICACHE_INDEX_WIDTH-1:0]v_dataram_rd_index        [MSHR_ENTRY_NUM-1:0];
logic v_downstream_txreq_vld    [MSHR_ENTRY_NUM-1:0];

logic [ICACHE_REQ_OPCODE_WIDTH-1:0] v_downstream_txreq_opcode [MSHR_ENTRY_NUM-1:0];
logic [ICACHE_REQ_OPCODE_WIDTH-1:0] v_downstream_txreq_txnid  [MSHR_ENTRY_NUM-1:0];
req_addr_t v_downstream_txreq_addr   [MSHR_ENTRY_NUM-1:0];
logic v_downstream_txrsp_vld    [MSHR_ENTRY_NUM-1:0];
logic [ICACHE_REQ_OPCODE_WIDTH-1:0] v_downstream_txrsp_opcode [MSHR_ENTRY_NUM-1:0];

logic v_linefill_done           [MSHR_ENTRY_NUM-1:0];

assign v_entry_idle = ~v_entry_valid;

cmn_lead_one #(
        .ENTRY_NUM      (MSHR_ENTRY_NUM         )
)u_mshr_in_credit(
        .v_entry_vld    (v_entry_idle           ),
        .v_free_idx_oh  (in_credit_entry_idx_oh ),
        .v_free_idx_bin (in_credit_entry_index  ),
        .v_free_vld     (in_credit_vld          )
    );
//write req info to mshr entry

always_comb begin
    if(tag_req_vld && in_credit_vld)begin
        v_mshr_entry_array[in_credit_entry_index].valid               = 1'b1;
        v_mshr_entry_array[in_credit_entry_index].req_addr            = tag_req_addr;
        v_mshr_entry_array[in_credit_entry_index].req_txnid           = tag_req_txnid;
        v_mshr_entry_array[in_credit_entry_index].req_opcode          = tag_req_opcode;
        v_mshr_entry_array[in_credit_entry_index].downstream_rep_way  = lru_pick;
        for(integer k=0;k<MSHR_ENTRY_NUM;k=k+1)begin
            if (mshr_hit[k]) begin
                v_mshr_entry_array[in_credit_entry_index].hit_bitmap[k] = 1'b1;
            end else begin
                v_mshr_entry_array[in_credit_entry_index].hit_bitmap[k] = 1'b0;
            end
        end
    end
    else begin
        v_mshr_entry_array[in_credit_entry_index] = '{1'b0,33'b0,5'b0,5'b0,1'b0,8'b0};
    end

    if(linefill_done)begin
        v_linefill_done[linefill_ack_index] = 1'b1;
        v_mshr_entry_array[linefill_ack_index].valid = 1'b0;
        for (int i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
            if(v_mshr_entry_array[i].hit_bitmap[linefill_ack_index]== 1'b1)begin
                v_mshr_entry_array[i].valid = 1'b0;
            end
        end
    end
    else begin
        v_linefill_done[linefill_ack_index] = 1'b0;
        v_mshr_entry_array[linefill_ack_index].valid = 1'b1;
        for (int i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
            v_mshr_entry_array[i].valid = 1'b1;
        end
    end
end

//all entry to check hit/miss
generate 
    for(genvar k=0;k<MSHR_ENTRY_NUM;k=k+1)begin
        assign mshr_hit[k]  = (v_mshr_entry_array[k].valid == 1'b1) && (v_mshr_entry_array[k].req_addr == tag_req_addr) && tag_req_vld;
    end
endgenerate

assign mshr_miss = ~(|mshr_hit);
//assign mshr_miss         = ~mshr_hit     ;
assign mshr_full         = &v_entry_valid;
assign stall             = mshr_full     ;
assign mshr_tag_req_rdy  = ~stall        ;


//generate
//    for (genvar k = 0; k < MSHR_ENTRY_NUM; k = k + 1) begin
//        always_comb begin
//            if (mshr_hit[k]) begin
//                v_mshr_entry_array[in_credit_entry_index].hit_bitmap[k] = 1'b1;
//            end else begin
//                v_mshr_entry_array[in_credit_entry_index].hit_bitmap[k] = 1'b0;
//            end
//        end
//    end
//endgenerate

//for prefetch





//always_comb begin
//    if(linefill_done)begin
//        v_linefill_done[linefill_ack_index] = 1'b1;
//        v_mshr_entry_array[linefill_ack_index].valid = 1'b0;
//        for (int i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
//            if(v_mshr_entry_array[i].hit_bitmap[linefill_ack_index]== 1'b1)begin
//                v_mshr_entry_array[i].valid = 1'b0;
//            end
//        end
//    end
//    else begin
//        v_linefill_done[linefill_ack_index] = 1'b0;
//        v_mshr_entry_array[linefill_ack_index].valid = v_mshr_entry_array[linefill_ack_index].valid;
//        for (int i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
//            v_mshr_entry_array[i].valid = v_mshr_entry_array[i].valid;
//        end
//    end
//end

//logic v_linefill_en[MSHR_ENTRY_NUM-1:0];


generate
    for (genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin:MSHR_ENTRY_ARRAY
        icache_mshr_entry_buffer  u_icache_mshr_entry_buffer(
            .clk                     (clk                            ),
            .rst_n                   (rst_n                          ),
            .mshr_entry_array        (v_mshr_entry_array[i]            ),
            .tag_hit                 (tag_hit                        ),
            .tag_miss                (tag_miss                       ),
            .mshr_hit                (mshr_hit[i]                    ),
            .mshr_miss               (mshr_miss[i]                   ),
            .entry_valid             (v_entry_valid[i]               ),
            //.entry_idle              (v_entry_idle[i]                ),
            .dataram_rd_vld          (v_dataram_rd_vld[i]            ),
            .dataram_rd_rdy          (dataram_rd_rdy                 ),
            .dataram_rd_way          (v_dataram_rd_way[i]             ),
            .dataram_rd_index        (v_dataram_rd_index[i]          ),
            .linefill_done           (v_linefill_done[i]             ),
            .downstream_txreq_vld    (v_downstream_txreq_vld[i]      ),
            .downstream_txreq_rdy    (downstream_txreq_rdy           ),
            .downstream_txreq_opcode (v_downstream_txreq_opcode[i]   ),
            .downstream_txreq_txnid  (v_downstream_txreq_txnid[i]    ),
            .downstream_txreq_addr   (v_downstream_txreq_addr[i]     ),
            .miss_addr_for_prefetch  (miss_addr_for_prefetch         ),
            .miss_for_prefetch       (miss_for_prefetch              )
            //.downstream_txrsp_vld    (v_downstream_txrsp_vld[i]      ),
            //.downstream_txrsp_rdy    (downstream_txrsp_rdy           ),
            //.downstream_txrsp_opcode (v_downstream_txrsp_opcode[i]   )
        );
    end
endgenerate

//assign mshr_entry_array[linefill_ack_index].valid               = 1'b0;
logic [MSHR_ENTRY_NUM-1:0] out_valid  ;
generate
    for(genvar n=0;n<MSHR_ENTRY_NUM;n=n+1)begin
        assign out_valid[n] = v_entry_valid[n] && (&v_mshr_entry_array[n].hit_bitmap == 1'b0) ;
    end
endgenerate

cmn_lead_one #(
        .ENTRY_NUM      (MSHR_ENTRY_NUM             )
)u_mshr_out_credit(
        .v_entry_vld    (out_valid                  ),
        .v_free_idx_oh  (out_credict_entry_idx_oh   ),
        .v_free_idx_bin (out_credit_entry_index     ),
        .v_free_vld     (out_credit_vld             )
    );


always_comb begin
    if(out_credit_vld)begin
        dataram_rd_vld          = v_dataram_rd_vld         [out_credit_entry_index]; 
        dataram_rd_way          = v_dataram_rd_way         [out_credit_entry_index]; 
        dataram_rd_index        = v_dataram_rd_index       [out_credit_entry_index];
        downstream_txreq_vld    = v_downstream_txreq_vld   [out_credit_entry_index];
        downstream_txreq_opcode = v_downstream_txreq_opcode[out_credit_entry_index];
        downstream_txreq_txnid  = v_downstream_txreq_txnid [out_credit_entry_index];
        downstream_txreq_addr   = v_downstream_txreq_addr  [out_credit_entry_index];
        //downstream_txrsp_vld    = v_downstream_txrsp_vld   [out_credit_entry_index];
        //downstream_txrsp_opcode = v_downstream_txrsp_opcode[out_credit_entry_index];

        downstream_txreq_index  = out_credit_entry_index;

        //linefill_en = v_linefill_en[out_credit_entry_index];
    end
    else begin
        dataram_rd_vld          = 'b0;
        dataram_rd_way          = 'b0;
        dataram_rd_index        = 'b0;
        downstream_txreq_vld    = 'b0;
        downstream_txreq_opcode = 'b0;
        downstream_txreq_txnid  = 'b0;
        downstream_txreq_addr   = {20'b0,7'b0,6'b0};
        
        //downstream_txrsp_opcode = 5'b0;

        downstream_txreq_index  = 7'b0;

        //linefill_en = 'b0;
    end
end



endmodule


