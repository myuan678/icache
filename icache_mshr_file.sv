module icache_mshr_file 
    import toy_pack::*;
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,    
    input  logic                                        tag_req_vld                ,
    output logic                                        mshr_tag_req_rdy           ,
    input  pc_req_t                                     tag_req_pld                ,
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
    output pc_req_t                                     downstream_txreq_pld       ,
    output logic [ICACHE_INDEX_WIDTH-1:0]               downstream_txreq_index     ,

    input  logic                                        downstream_txrsp_vld       ,//TODO
    output logic                                        downstream_txrsp_rdy       ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,//TODO

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
//logic [MSHR_ENTRY_NUM-1:0]          mshr_hit;
//logic [MSHR_ENTRY_NUM-1:0]          mshr_miss;

logic                               v_dataram_rd_vld          [MSHR_ENTRY_NUM-1:0];
logic                               v_dataram_rd_way          [MSHR_ENTRY_NUM-1:0];
logic [ICACHE_INDEX_WIDTH-1:0]      v_dataram_rd_index        [MSHR_ENTRY_NUM-1:0];
logic                               v_downstream_txreq_vld    [MSHR_ENTRY_NUM-1:0];

//logic [ICACHE_REQ_OPCODE_WIDTH-1:0] v_downstream_txreq_opcode [MSHR_ENTRY_NUM-1:0];
//logic [ICACHE_REQ_OPCODE_WIDTH-1:0] v_downstream_txreq_txnid  [MSHR_ENTRY_NUM-1:0];
//req_addr_t                          v_downstream_txreq_addr   [MSHR_ENTRY_NUM-1:0];
pc_req_t                            v_downstream_txreq_pld     [MSHR_ENTRY_NUM-1:0];

logic                               v_downstream_txrsp_vld     [MSHR_ENTRY_NUM-1:0];
logic [ICACHE_REQ_OPCODE_WIDTH-1:0] v_downstream_txrsp_opcode  [MSHR_ENTRY_NUM-1:0];

logic                               v_linefill_done            [MSHR_ENTRY_NUM-1:0];
logic                               v_miss_for_prefetch        [MSHR_ENTRY_NUM-1:0];
req_addr_t                          v_miss_addr_for_prefetch   [MSHR_ENTRY_NUM-1:0];



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
    // Default assignments for v_mshr_entry_array
    for (integer i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
        v_mshr_entry_array[i].valid               = 1'b0;
        v_mshr_entry_array[i].req_pld             = '{33'b0,5'b0,5'b0};
        v_mshr_entry_array[i].downstream_rep_way  = 1'b0;
        v_mshr_entry_array[i].hit_bitmap          = 8'b0;
    end
    // Update v_mshr_entry_array based on tag_req_vld and in_credit_vld
    if (tag_req_vld && in_credit_vld && (linefill_done == 1'b0)) begin
        v_mshr_entry_array[in_credit_entry_index].valid               = 1'b1;
        v_mshr_entry_array[in_credit_entry_index].req_pld             = tag_req_pld;
        v_mshr_entry_array[in_credit_entry_index].downstream_rep_way  = lru_pick;
        for (integer k = 0; k < MSHR_ENTRY_NUM; k = k + 1) begin
            if ((v_mshr_entry_array[k].valid == 1'b1) && (v_mshr_entry_array[k].req_pld.addr == tag_req_pld.addr) ) begin
                v_mshr_entry_array[in_credit_entry_index].hit_bitmap[k] = 1'b1;
            end 
            else begin
                v_mshr_entry_array[in_credit_entry_index].hit_bitmap[k] = 1'b0;
            end
        end
    end
end



always_comb begin
    for(integer i=0;i<MSHR_ENTRY_NUM;i=i+1)begin
        if(linefill_done == 1'b1)begin
            if (v_mshr_entry_array[i].hit_bitmap[linefill_ack_index] == 1'b1 || linefill_ack_index == i ) begin
                v_linefill_done[i] = 1'b1;
            end
        end
        else begin
            v_linefill_done[i] = 1'b0;
        end
    end

    // Update v_mshr_entry_array and v_linefill_done based on linefill_ack_index
    if (linefill_done == 1'b1) begin
        //v_linefill_done[linefill_ack_index] = 1'b1;
        //v_mshr_entry_array[linefill_ack_index].valid = 1'b0;
        for (integer i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
            if (v_mshr_entry_array[i].hit_bitmap[linefill_ack_index] == 1'b1 || linefill_ack_index == i) begin
                //v_mshr_entry_array[i].valid = 1'b0;
                v_linefill_done[i] = 1'b1;            
            end
        end
    end 
    else begin
        v_linefill_done[linefill_ack_index] = 1'b0;
        //for (integer i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
        //    v_mshr_entry_array[i].valid = 1'b1;
        //end
    end
end

assign stall             = &v_entry_valid;
assign v_entry_idle      = ~v_entry_valid;
assign mshr_tag_req_rdy  = ~stall && (linefill_done == 1'b0)         ;
//logic v_linefill_en[MSHR_ENTRY_NUM-1:0];


generate
    for (genvar i=0;i<MSHR_ENTRY_NUM;i=i+1)begin:MSHR_ENTRY_ARRAY
        icache_mshr_entry_buffer  u_icache_mshr_entry_buffer(
            .clk                     (clk                            ),
            .rst_n                   (rst_n                          ),
            .mshr_entry_array        (v_mshr_entry_array[i]          ),
            .tag_hit                 (tag_hit                        ),
            .tag_miss                (tag_miss                       ),
            .entry_valid             (v_entry_valid[i]               ),
            .dataram_rd_vld          (v_dataram_rd_vld[i]            ),
            .dataram_rd_rdy          (dataram_rd_rdy                 ),
            .dataram_rd_way          (v_dataram_rd_way[i]            ),
            .dataram_rd_index        (v_dataram_rd_index[i]          ),
            .linefill_done           (v_linefill_done[i]             ),
            .downstream_txreq_vld    (v_downstream_txreq_vld[i]      ),
            .downstream_txreq_rdy    (downstream_txreq_rdy           ),
            .downstream_txreq_pld    (v_downstream_txreq_pld[i]      ),
            //.downstream_txreq_opcode (v_downstream_txreq_opcode[i]   ),
            //.downstream_txreq_txnid  (v_downstream_txreq_txnid[i]    ),
            //.downstream_txreq_addr   (v_downstream_txreq_addr[i]     ),
            .miss_addr_for_prefetch  (v_miss_addr_for_prefetch[i]    ),
            .miss_for_prefetch       (v_miss_for_prefetch[i]         )
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
        downstream_txreq_pld    = v_downstream_txreq_pld   [out_credit_entry_index];
        //downstream_txreq_opcode = v_downstream_txreq_opcode[out_credit_entry_index];
        //downstream_txreq_txnid  = v_downstream_txreq_txnid [out_credit_entry_index];
        //downstream_txreq_addr   = v_downstream_txreq_addr  [out_credit_entry_index];

        downstream_txreq_index  = out_credit_entry_index;
        miss_for_prefetch       = v_miss_for_prefetch      [out_credit_entry_index];
        miss_addr_for_prefetch  = v_miss_addr_for_prefetch [out_credit_entry_index];
    end
    else begin
        dataram_rd_vld          = 'b0;
        dataram_rd_way          = 'b0;
        dataram_rd_index        = 'b0;

        downstream_txreq_vld    = 'b0;
        downstream_txreq_pld    =  '{32'b0,5'b0,5'b0};
        
        downstream_txreq_index  = 7'b0;
        miss_for_prefetch       = 1'b0;
        miss_addr_for_prefetch  = 'b0;
    end
end



endmodule


