module icache_req_arbiter 
    import toy_pack::*;
    (
    input  logic                                            clk                      ,
    input  logic                                            rst_n                    ,
    input  logic                                            upstream_rxreq_vld       ,
    output logic                                            upstream_rxreq_rdy       ,
    input  pc_req_t                                         upstream_rxreq_pld       ,
      
    input  logic                                            downstream_rxsnp_vld     ,
    output logic                                            downstream_rxsnp_rdy     ,
    input  pc_req_t                                         downstream_rxsnp_pld     ,
  
    input  logic                                            prefetch_req_vld         ,
    output logic                                            prefetch_req_rdy         ,
    input  pc_req_t                                         prefetch_req_pld         ,
  
    output logic                                            tag_req_vld              ,
    input  logic                                            tagram_req_rdy           , //tag_ram rdy
    input  logic                                            mshr_tag_req_rdy         , //mshr rdy
    output pc_req_t                                         tag_req_pld            
);
    logic                                                   tag_req_rdy              ;
    assign tag_req_rdy = tagram_req_rdy & mshr_tag_req_rdy                           ;
    assign tag_req_vld = upstream_rxreq_vld | downstream_rxsnp_vld | prefetch_req_vld;

    always_comb begin
        //default
        tag_req_pld             = '{32'b0,5'b0,5'b0}            ;
        upstream_rxreq_rdy      = 1'b0                          ;
        downstream_rxsnp_rdy    = 1'b0                          ;
        prefetch_req_rdy        = 1'b0                          ;
        if(tag_req_rdy)begin
            if (upstream_rxreq_vld ) begin
                tag_req_pld         = upstream_rxreq_pld        ;
                upstream_rxreq_rdy  = 1'b1                      ;
            end 
            else if (downstream_rxsnp_vld ) begin
                tag_req_pld         = downstream_rxsnp_pld      ;
                downstream_rxsnp_rdy= 1'b1                      ;
            end 
            else if (prefetch_req_vld ) begin
                tag_req_pld         = prefetch_req_pld          ;
                prefetch_req_rdy    = 1'b1                      ;
            end
        end
    end

endmodule

