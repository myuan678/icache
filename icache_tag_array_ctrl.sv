module icache_tag_array_ctrl 
    import toy_pack::*;
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,
    input  logic                                        tag_req_vld                ,
    output logic                                        tagram_req_rdy             ,
    input  req_addr_t                                   tag_req_addr               ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          tag_req_opcode             ,
    input  logic [ICACHE_REQ_TXNID_WIDTH-1:0]           tag_req_txnid              ,
    output logic                                        tag_miss                   ,
    output logic [WAY_NUM-1:0]                          tag_hit                    ,
    output logic                                        lru_pick                   ,
    input  logic                                        stall                      
);

req_addr_t                              req_addr                                   ;
logic [ICACHE_REQ_TXNID_WIDTH-1:0]      req_txnid                                  ;
logic [ICACHE_REQ_OPCODE_WIDTH-1:0]     req_opcode                                 ;

always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        req_addr    <= 'b0;
        req_txnid   <= 'b0;
        req_opcode  <= 'b0;
    end
    else if(tag_req_vld)begin
        req_addr    <= tag_req_addr;
        req_txnid   <= tag_req_txnid;
        req_opcode  <= tag_req_opcode;
    end
    else begin
        req_addr    <= 'b0;
        req_txnid   <= 'b0;
        req_opcode  <= 'b0;
    end
end



logic                           tag_array0_wr_en                            ;
//logic                           tag_array1_wr_en        ;    
logic [ICACHE_INDEX_WIDTH-1:0]  tag_array0_addr                             ;
//logic [ICACHE_INDEX_WIDTH-1:0]  tag_array1_addr         ;
logic [ICACHE_TAG_WIDTH:0]      tag_array0_dout                             ;
logic [ICACHE_TAG_WIDTH:0]      tag_array_din                               ;
logic                           tag_array0_dout_way0_vld                    ;
logic                           tag_array0_dout_way1_vld                    ;
//logic                           tag_array1_dout_vld     ;
logic                           tag_way0_hit                                ;
logic                           tag_way1_hit                                ;
logic                           lru  [ICACHE_INDEX_WIDTH-1:0]               ;


assign tag_array0_addr = tag_req_addr.index                                 ;
assign tagram_req_rdy = (tag_array0_wr_en == 1'b1) && !stall                ;
assign tag_array0_dout_way0_vld = tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1]   ;
assign tag_array0_dout_way1_vld = tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1] ;
assign tag_way0_hit = ({1'b1,req_addr.tag} == tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]) && tag_array0_dout_way0_vld;
assign tag_way1_hit = ({1'b1,req_addr.tag} == tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]) && tag_array0_dout_way1_vld;

assign tag_hit  = {tag_way1_hit,tag_way0_hit};
assign tag_miss = ~(tag_way0_hit | tag_way1_hit) && tag_req_vld;


//wr_en  1:write; 0:read
always_comb begin
    if(req_opcode == DOWNSTREAM_OPCODE)begin
        //if miss, nothing to do; if hit,update tag.valid and lru
        if(tag_way0_hit || tag_way1_hit)begin
            tag_array0_wr_en = 1'b1;
        end
        else begin
            tag_array0_wr_en = 1'b0;
        end
    end
    else if(req_opcode == UPSTREAM_OPCODE || req_opcode == PREFETCH_OPCODE)begin
        //if miss,update tag array; if hit,update lru
        if(tag_miss)begin
            tag_array0_wr_en = 1'b1;
        end
        else begin
            tag_array0_wr_en = 1'b0;
        end
    end
    else begin
        tag_array0_wr_en = 1'b0;
    end
end
//logic [ICACHE_TAG_RAM_WIDTH/8-1:0]tag_array0_wr_byte_en;
logic [ICACHE_INDEX_WIDTH-1:0] index;
assign index = req_addr.index;
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lru  <= '{ICACHE_INDEX_WIDTH{1'b0}};
    end
    else if ((tag_way0_hit == 1'b1) && tag_req_vld) begin
        lru[index] <= 1'b1;
    end
    else if ((tag_way1_hit == 1'b1) && tag_req_vld) begin
        lru[index] <= 1'b0;
    end
    else begin
        lru[index] <= ~lru[index];
    end
end
assign lru_pick = lru[index];

assign tag_array0_din = lru_pick ? {tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b1,req_addr.tag} 
                                 : {1'b1,req_addr.tag,tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]};
toy_mem_model_bit #(
    .ADDR_WIDTH(ICACHE_INDEX_WIDTH),
    .DATA_WIDTH(ICACHE_TAG_RAM_WIDTH)
) u_icache_tag_array0(
    .clk        (clk                 ),
    .en         (1'b1                ),
    .wr_en      (tag_array0_wr_en    ),
    .addr       (tag_array0_addr     ),
    .rd_data    (tag_array0_dout     ),
    .wr_data    (tag_array0_din      )
    
);
//toy_mem_model_bit #(
//    .ADDR_WIDTH(ICACHE_INDEX_WIDTH),
//    .DATA_WIDTH(ICACHE_TAG_WIDTH+1)
//) u_icache_tag_array1(
//
//    .clk        (clk                 ),
//    .en         (1'b1                ),
//    .wr_en      (tag_array1_wr_en    ),
//    .addr       (req_addr.index      ),
//    .rd_data    (tag_array0_dout     ),
//    .wr_data    (tag_array0_din      ));


//tag_wr_en update tag info when linefill done
//tag array rd: 1.req;  
//tag_array wr: 1.miss， write in 20bit tag data 

//weight update:LRU 1.hit(update to another)
                //2.miss keep 

//update weight 
//1:replace way1,0:replace way0




endmodule