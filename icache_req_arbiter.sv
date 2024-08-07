module icache_req_arbiter
    import toy_pack::*;
    (
    input  logic                 clk                    ,
    input  logic                 rst_n                  ,

    input  logic                 upstream_rxreq_vld     ,
    output logic                 upstream_rxreq_rdy     ,
    input  pc_req_t              upstream_rxreq_pld     ,

    input  logic                 downstream_rxsnp_vld   ,
    output logic                 downstream_rxsnp_rdy   ,
    input  pc_req_t              downstream_rxsnp_pld   ,

    input  logic                 prefetch_req_vld       ,
    output logic                 prefetch_req_rdy       ,
    input  pc_req_t              prefetch_req_pld       ,

    output logic                 tag_req_vld            ,
    input  logic                 tagram_req_rdy         ,
    input  logic                 mshr_tag_req_rdy       ,
    output pc_req_t              tag_req_pld
    );
    localparam PLD_WIDTH = $bits(pc_req_t);
    logic                        tag_req_rdy            ;
    logic [2    :0]              v_vld_s                ;
    logic [2    :0]              v_rdy_s                ;
    pc_req_t                     v_pld_s[2:0]           ;
    logic [2    :0]              select_onehot          ;
    logic                        vld_m                  ;
    pc_req_t                     pld_m                  ;

    assign tag_req_rdy      = tagram_req_rdy & mshr_tag_req_rdy                                 ;
    assign v_vld_s          = {prefetch_req_vld, downstream_rxsnp_vld, upstream_rxreq_vld}      ;
    assign v_pld_s[0]       = upstream_rxreq_pld                                                ;
    assign v_pld_s[1]       = downstream_rxsnp_pld                                              ;
    assign v_pld_s[2]       = prefetch_req_pld                                                  ;
    assign tag_req_vld      = vld_m                                                             ;
    assign tag_req_pld      = pld_m                                                             ;
    assign {prefetch_req_rdy, downstream_rxsnp_rdy, upstream_rxreq_rdy} = v_rdy_s               ;

    fix_priority_arb #(
        .WIDTH      (3          ),
        .PLD_TYPE   (pc_req_t   )
    ) arbiter (
        .v_vld_s    (v_vld_s    ),
        .v_rdy_s    (v_rdy_s    ),
        .v_pld_s    (v_pld_s    ),
        .vld_m      (vld_m      ),
        .rdy_m      (tag_req_rdy),
        .pld_m      (pld_m      )
    );



endmodule