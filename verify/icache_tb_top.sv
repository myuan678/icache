module icache_tb_top(
);
import toy_pack::*;
logic           clk             ;
logic           rst_n           ;
icache_up_if    up_vif(clk)     ;
icache_down_if  down_vif(clk)   ;
icache_cfg      cfg             ;
test            t0              ;


initial begin
	clk             = 0   ;
 	rst_n           = 1   ;
	#100 rst_n      = 0   ;
    #100 rst_n      = 1   ;
	forever #10 clk = ~clk;
end

initial begin
    $display("Creating test object...");
    t0              = new;
    $display("Test object created.");
    t0.env0.up_agent.up_drv.up_vif         = up_vif     ;
    //t0.env0.up_agent.up_mon.up_vif         = up_vif     ;
    //t0.env0.up_agent.up_mon.down_vif       = down_vif   ;
    //t0.env0.down_agent.down_mon.up_vif     = up_vif     ;
    //t0.env0.down_agent.down_mon.down_vif   = down_vif   ;
    t0.env0.down_agent.down_drv.down_vif   = down_vif   ;
    //t0.env0.scb.up_vif                     = up_vif     ;
    //t0.env0.scb.down_vif                   = down_vif   ;
    t0.run();
end


icache_top  dut (
    .clk                      (clk                                  ),
    .rst_n                    (rst_n                                ),
    .prefetch_enable          (up_vif.prefetch_enable               ),
    .upstream_txdat_data      (up_vif.upstream_txdat_data           ),
    .upstream_txdat_vld       (up_vif.upstream_txdat_vld            ),
    //.upstream_txdat_rdy       (up_vif.upstream_txdat_rdy          ),
    .upstream_txdat_txnid     (up_vif.upstream_txdat_txnid          ),
    .upstream_rxreq_vld       (up_vif.upstream_rxreq_vld            ),
    .upstream_rxreq_rdy       (up_vif.upstream_rxreq_rdy            ),
    .upstream_rxreq_pld       (up_vif.upstream_rxreq_pld            ),
    .downstream_rxsnp_vld     (down_vif.downstream_rxsnp_vld        ),
    .downstream_rxsnp_rdy     (down_vif.downstream_rxsnp_rdy        ),
    .downstream_rxsnp_pld     (down_vif.downstream_rxsnp_pld        ),
    .downstream_txreq_vld     (down_vif.downstream_txreq_vld        ),
    .downstream_txreq_rdy     (down_vif.downstream_txreq_rdy        ),
    .downstream_txreq_pld     (down_vif.downstream_txreq_pld        ),
    .downstream_txreq_entry_id(down_vif.downstream_txreq_entry_id   ),
    .downstream_txrsp_rdy     (down_vif.downstream_txrsp_rdy        ),
    .downstream_rxdat_vld     (down_vif.downstream_rxdat_vld        ),
    .downstream_rxdat_rdy     (down_vif.downstream_rxdat_rdy        ),
    .downstream_rxdat_pld     (down_vif.downstream_rxdat_pld        ),
    .prefetch_req_vld         (1'b0                                 ),
    .prefetch_req_pld         ('b0                                  ));

    initial begin
        if($test$plusargs("WAVE")) begin
            $fsdbDumpfile("wave.fsdb");
            $fsdbDumpvars("+all");
            //$fsdbDumpMDA;
            $fsdbDumpon;
    	end
    end


endmodule