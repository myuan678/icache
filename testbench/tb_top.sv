`ifndef INTERFACE_SV
    `define INTERFACE_SV
    `include "interface.sv"
`endif

module tb_top();

    icache_if_upstream          intf_up(clk);
    icache_if_downstream        intf_down(clk);

    upstream_driver             up_drv  ;
    downstream_driver           dn_drv  ;
    scoreboard                  scb     ;

    initial begin
        // init
        up_drv = new;
        dn_drv = new;

        // connect
        up_drv.scb = scb;
        dn_drv.scb = scb;
        up_drv.vif = intf_up;
        dn_drv.vif = intf_down;

        // run
        up_drv.run();
        dn_drv.run();

        // report
    end


    icache_top  dut (
        .clk                      (clk                                  ),
        .rst_n                    (rst_n                                ),
        .prefetch_enable          (1'b0                                 ),
        .upstream_txdat_data      (intf_up.upstream_txdat_data          ),
        .upstream_txdat_vld       (intf_up.upstream_txdat_vld           ),
        .upstream_txdat_rdy       (intf_up.upstream_txdat_rdy           ),
        .upstream_txdat_txnid     (intf_up.upstream_txdat_txnid         ),
        .upstream_rxreq_vld       (intf_up.upstream_rxreq_vld           ),
        .upstream_rxreq_rdy       (intf_up.upstream_rxreq_rdy           ),
        .upstream_rxreq_pld       (intf_up.upstream_rxreq_pld           ),
        .downstream_rxsnp_vld     (intf_down.downstream_rxsnp_vld       ),
        .downstream_rxsnp_rdy     (intf_down.downstream_rxsnp_rdy       ),
        .downstream_rxsnp_pld     (intf_down.downstream_rxsnp_pld       ),
        .downstream_txreq_vld     (intf_down.downstream_txreq_vld       ),
        .downstream_txreq_rdy     (intf_down.downstream_txreq_rdy       ),
        .downstream_txreq_pld     (intf_down.downstream_txreq_pld       ),
        .downstream_txreq_entry_id(intf_down.downstream_txreq_entry_id  ),
        .downstream_txrsp_vld     (intf_down.downstream_txrsp_vld       ),
        .downstream_txrsp_rdy     (intf_down.downstream_txrsp_rdy       ),
        .downstream_txrsp_opcode  (intf_down.downstream_txrsp_opcode    ),
        .downstream_rxdat_vld     (intf_down.downstream_rxdat_vld       ),
        .downstream_rxdat_rdy     (intf_down.downstream_rxdat_rdy       ),
        .downstream_rxdat_pld     (intf_down.downstream_rxdat_pld       ),
        .prefetch_req_vld         (1'b0                                 ),
        .prefetch_req_pld         ('b0                                  ),
        .pref_to_mshr_req_rdy     (1'b1                                 ));


endmodule