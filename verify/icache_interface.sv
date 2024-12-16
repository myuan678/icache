//interface icache_if();
interface icache_up_if(input logic clk, input logic rst_n);

    import toy_pack::*;
    //logic                                        clk                        ;
    //logic                                        rst_n                      ;
    logic                                        prefetch_enable            ;
    logic                                        prefetch_req_vld           ;   
    pc_req_t                                     prefetch_req_pld           ;   
    logic                                        pref_to_mshr_req_rdy       ;
    logic [ICACHE_UPSTREAM_DATA_WIDTH-1 :0]      upstream_txdat_data        ;
    logic                                        upstream_txdat_vld         ;
    logic [ICACHE_REQ_TXNID_WIDTH-1     :0]      upstream_txdat_txnid       ;
    logic                                        upstream_rxreq_vld         ;
    logic                                        upstream_rxreq_rdy         ;
    pc_req_t                                     upstream_rxreq_pld         ;

    initial begin
        upstream_rxreq_vld     = 0;
        upstream_rxreq_vld     = 'b0;
        upstream_rxreq_pld     = 'b0;
        prefetch_enable        = 1'b0;
    end
endinterface

interface icache_down_if(input logic clk, input logic rst_n);
    import toy_pack::*;
    logic                                        downstream_rxsnp_vld       ;
    logic                                        downstream_rxsnp_rdy       ;
    pc_req_t                                     downstream_rxsnp_pld       ;
    logic                                        downstream_txreq_vld       ;
    logic                                        downstream_txreq_rdy       ;
    pc_req_t                                     downstream_txreq_pld       ;
    logic [MSHR_ENTRY_INDEX_WIDTH-1      :0]     downstream_txreq_entry_id  ;
    logic                                        downstream_txrsp_rdy       ;
    logic                                        downstream_rxdat_vld       ;
    logic                                        downstream_rxdat_rdy       ;
    downstream_rxdat_t                           downstream_rxdat_pld       ;

    initial begin
        downstream_rxsnp_vld   = 0;
        downstream_txreq_rdy   = 1'b1;
        downstream_rxsnp_vld   = 'b0;
        downstream_rxsnp_pld   = 'b0;
        downstream_rxdat_vld   = 'b0;
        downstream_rxdat_pld   = 'b0;
    end

endinterface