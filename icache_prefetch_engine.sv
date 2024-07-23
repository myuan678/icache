module icache_prefetch_engine 
    import toy_pack::*;
    (
    input       logic                                        clk                     ,
    input       logic                                        rst_n                   ,
    input       logic                                        miss_for_prefetch       ,
    input       req_addr_t                                   miss_addr_for_prefetch  ,
    output      logic                                        prefetch_req_vld        ,
    input       logic                                        prefetch_req_rdy        ,
    output      pc_req_t                                     prefetch_req_pld    
);

assign prefetch_req_vld         = prefetch_req_rdy && miss_for_prefetch;
assign prefetch_req_pld.addr    = miss_addr_for_prefetch + 'h40;
assign prefetch_req_pld.opcode  = PREFETCH_OPCODE;
assign prefetch_req_pld.txnid   = 'b0;



endmodule