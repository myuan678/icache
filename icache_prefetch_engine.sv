module icache_prefetch_engine 
    import toy_pack::*;
    (
    input  logic                                        clk                 ,
    input  logic                                        rst_n               ,
    input  logic                                        miss_for_prefetch   ,
    input  req_addr_t                                   miss_addr_for_prefetch,
    output logic                                        prefetch_req_vld    ,
    input  logic                                        prefetch_req_rdy    ,
    output logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          prefetch_req_opcode ,
    output req_addr_t                                   prefetch_req_addr    
);


assign prefetch_req_vld  = prefetch_req_rdy && miss_for_prefetch;
assign prefetch_req_addr = miss_addr_for_prefetch + 1;
assign prefetch_req_opcode = PREFETCH_OPCODE;



endmodule