module icache_tb_top();
import toy_pack::*;

logic        clk;
logic        rst_n;

icache_if    vif(clk);
request      req;

test         t0;

initial begin
    vif.upstream_rxreq_vld     = 0;
    vif.downstream_rxsnp_vld   = 0;
    vif.prefetch_enable        = 1'b0;
    vif.downstream_txreq_rdy   = 1'b1;
    vif.upstream_txdat_rdy     = 1'b1;

	clk             = 0   ;
 	rst_n           = 1   ;
	#100 rst_n      = 0   ;
    #100 rst_n      = 1   ;
	forever #10 clk = ~clk;
end

initial begin
    t0         = new;
    t0.req.vif = vif;
    t0.sb.vif  = vif;
    t0.run();
end

initial begin
    #300000;
    t0.sb.final_check();
    $finish;
end

icache_top  dut (
    .clk                      (clk                        ),
    .rst_n                    (rst_n                      ),
    .prefetch_enable          (vif.prefetch_enable        ),
    .upstream_txdat_data      (vif.upstream_txdat_data    ),
    .upstream_txdat_vld       (vif.upstream_txdat_vld     ),
    .upstream_txdat_rdy       (vif.upstream_txdat_rdy     ),
    .upstream_txdat_txnid     (vif.upstream_txdat_txnid   ),
    .upstream_rxreq_vld       (vif.upstream_rxreq_vld     ),
    .upstream_rxreq_rdy       (vif.upstream_rxreq_rdy     ),
    .upstream_rxreq_pld       (vif.upstream_rxreq_pld     ),
    .downstream_rxsnp_vld     (vif.downstream_rxsnp_vld   ),
    .downstream_rxsnp_rdy     (vif.downstream_rxsnp_rdy   ),
    .downstream_rxsnp_pld     (vif.downstream_rxsnp_pld   ),
    .downstream_txreq_vld     (vif.downstream_txreq_vld   ),
    .downstream_txreq_rdy     (vif.downstream_txreq_rdy   ),
    .downstream_txreq_pld     (vif.downstream_txreq_pld   ),
    .downstream_txreq_entry_id(vif.downstream_txreq_entry_id),
    .downstream_txrsp_vld     (vif.downstream_txrsp_vld   ),
    .downstream_txrsp_rdy     (vif.downstream_txrsp_rdy   ),
    .downstream_txrsp_opcode  (vif.downstream_txrsp_opcode),
    .downstream_rxdat_vld     (vif.downstream_rxdat_vld   ),
    .downstream_rxdat_rdy     (vif.downstream_rxdat_rdy   ),
    .downstream_rxdat_pld     (vif.downstream_rxdat_pld   ),
    .prefetch_req_vld         (1'b0                   ),
    .prefetch_req_pld         ('b0                    ),
    .pref_to_mshr_req_rdy     (pref_to_mshr_req_rdy));

endmodule