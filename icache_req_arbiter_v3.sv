module icache_req_arbiter_v3 
    import toy_pack::*;
    (
    input  logic                                            clk                    ,
    input  logic                                            rst_n                  ,
    input  logic                                            upstream_rxreq_vld     ,
    output logic                                            upstream_rxreq_rdy     ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              upstream_rxreq_opcode  ,
    input  logic [ICACHE_REQ_TXNID_WIDTH-1:0]               upstream_rxreq_txnid   ,
    input  req_addr_t                                       upstream_rxreq_addr    ,
    
    input  logic                                            downstream_rxsnp_vld   ,
    output logic                                            downstream_rxsnp_rdy   ,
    input  logic [ICACHE_REQ_TXNID_WIDTH-1:0]               downstream_rxsnp_txnid ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              downstream_rxsnp_opcode,
    input  req_addr_t                                       downstream_rxsnp_addr  ,

    input  logic                                            prefetch_req_vld       ,
    output logic                                            prefetch_req_rdy       ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              prefetch_req_opcode    ,
    input  req_addr_t                                       prefetch_req_addr      ,

    output logic                                            tag_req_vld            ,
    input  logic                                            tagram_req_rdy         , //tag_ram rdy
    input  logic                                            mshr_tag_req_rdy       , //mshr rdy
    output req_addr_t                                       tag_req_addr           ,
    output logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              tag_req_opcode         ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1:0]               tag_req_txnid
);
logic  tag_req_rdy;
assign tag_req_rdy = tagram_req_rdy & mshr_tag_req_rdy  ;
always_comb begin
    //default
    tag_req_vld             = 1'b0                      ;
    tag_req_addr            = 33'b0                     ;
    tag_req_opcode          = 'b0                       ;
    tag_req_txnid           = 'b0                       ;
    upstream_rxreq_rdy      = 1'b0                      ;
    downstream_rxsnp_rdy    = 1'b0                      ;
    prefetch_req_rdy        = 1'b0                      ;
    if (upstream_rxreq_vld && tag_req_rdy) begin
        tag_req_vld         = 1'b1                      ;
        tag_req_addr        = upstream_rxreq_addr       ;
        tag_req_opcode      = upstream_rxreq_opcode     ;
        tag_req_txnid       = upstream_rxreq_txnid      ;
        upstream_rxreq_rdy  = 1'b1                      ;
    end 
    else if (downstream_rxsnp_vld && tag_req_rdy) begin
        tag_req_vld         = 1'b1                      ;
        tag_req_addr        = downstream_rxsnp_addr     ;
        tag_req_opcode      = downstream_rxsnp_opcode   ;
        tag_req_txnid       = downstream_rxsnp_txnid    ;
        downstream_rxsnp_rdy= 1'b1                      ;
    end 
    else if (prefetch_req_vld && tag_req_rdy) begin
        tag_req_vld         = 1'b1                      ;
        tag_req_addr        = prefetch_req_addr         ;
        tag_req_opcode      = prefetch_req_opcode       ;  
        tag_req_txnid       = 'b0                       ;  //prefetch no id
        prefetch_req_rdy    = 1'b1                      ;
    end
end

endmodule

