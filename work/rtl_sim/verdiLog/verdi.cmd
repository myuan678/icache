verdiSetActWin -dock widgetDock_<Message>
simSetSimulator "-vcssv" -exec "simv" -args "+v2k -a com.log +WAVE"
debImport "-sv" "-dbdir" "simv.daidir"
debLoadSimResult /data/usr/xuemy/try/icache_2r_v1/icache/work/rtl_sim/wave.fsdb
wvCreateWindow
verdiWindowResize -win $_Verdi_1 "76" "55" "1800" "958"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "icache_top_tb.dut" -win $_nTrace1
srcSetScope "icache_top_tb.dut" -delim "." -win $_nTrace1
srcHBSelect "icache_top_tb.dut" -win $_nTrace1
srcHBSelect "icache_top_tb.dut.u_icache_req_arbiter" -win $_nTrace1
srcSetScope "icache_top_tb.dut.u_icache_req_arbiter" -delim "." -win $_nTrace1
srcHBSelect "icache_top_tb.dut.u_icache_req_arbiter" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_rxreq_vld" -line 7 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_rxreq_vld" -line 7 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetCursor -win $_nWave2 124.892080 -snap {("G2" 0)}
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 1119.853001 -snap {("G2" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_rxreq_rdy" -line 8 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_rxreq_rdy" -line 8 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_rxsnp_vld" -line 11 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "prefetch_req_vld" -line 15 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcHBSelect "icache_top_tb.dut.u_icache_tag_array_ctrl" -win $_nTrace1
srcSetScope "icache_top_tb.dut.u_icache_tag_array_ctrl" -delim "." -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "icache_top_tb.dut.u_icache_tag_array_ctrl" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_vld" -line 7 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_rdy" -line 8 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 375.815075 -snap {("G2" 0)}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_rdy" -line 8 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_rdy" -line 8 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "tag_req_rdy" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_buf_vld" -line 83 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "stall" -line 83 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_buf_vld" -line 83 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "wr_buf_vld" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "wr_buf_vld" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "wr_buf_vld" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "wr_buf_vld" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_vld" -line 216 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_B_vld" -line 216 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_vld" -line 216 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "wr_tag_buf_A_vld" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "wr_tag_buf_A_vld" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_vld" -line 219 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_miss" -line 222 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_vld" -line 223 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_miss" -line 222 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_miss" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_miss" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_miss" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_tag_way0_hit" -line 315 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_tag_way1_hit" -line 315 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_tag_way0_hit" -line 315 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "A_tag_way0_hit" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_vld" -line 266 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "req_pld_A.addr.index" -line 266 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_index" -line 266 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_B_vld" -line 266 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "req_pld_A.addr.index" -line 266 -pos 2 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_B_index" -line 266 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "wr_tag_buf_A_pld\[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2\]" \
          -line 267 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "tag_array_A_dout\[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2\]" \
          -line 277 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 451.737312 -snap {("G1" 19)}
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_tag_way1_hit" -line 283 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "icache_top_tb.dut.u_icache_tag_array_ctrl.req_vld_A"
srcSignalViewAddSelectedToWave -win $_nTrace1 -clipboard
wvDrop -win $_nWave2
wvScrollUp -win $_nWave2 1
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
verdiSetActWin -dock widgetDock_<Signal_List>
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_tag_way0_hit" -line 57 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_tag_buf_A_index" -line 55 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cre_tag_req_pldB" -line 37 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "align" -line 38 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 916.543997 -snap {("G1" 21)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_pld.addr.offset" -line 82 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_pld" -line 9 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcHBSelect "icache_top_tb.dut.u_icache_req_arbiter" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSetScope "icache_top_tb.dut.u_icache_req_arbiter" -delim "." -win $_nTrace1
srcHBSelect "icache_top_tb.dut.u_icache_req_arbiter" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_req_pld" -line 26 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "tag_req_pld" -next
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pld_m" -line 72 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pld_m" -line 72 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -inst "arbiter" -line 61 -pos 1 -win $_nTrace1
srcAction -pos 60 3 2 -win $_nTrace1 -name "arbiter" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "select_pld" -line 39 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "select_pld" -line 35 -pos 2 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "select_onehot" -line 33 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "v_pld_s" -line 34 -pos 1 -win $_nTrace1
srcHBSelect "icache_top_tb.dut.u_icache_tag_array_ctrl" -win $_nTrace1
srcSetScope "icache_top_tb.dut.u_icache_tag_array_ctrl" -delim "." -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "icache_top_tb.dut.u_icache_tag_array_ctrl" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 13 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_miss" -line 15 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "B_miss" -line 16 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_update_en" -line 21 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 13 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "B_hit" -line 14 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_data" -line 22 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "entry_data" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_update_pld" -line 547 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 32 )} 
wvExpandBus -win $_nWave2
wvZoom -win $_nWave2 239.423738 1638.556207
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 33 )} 
wvSetPosition -win $_nWave2 {("G1" 33)}
wvExpandBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 37)}
wvSelectSignal -win $_nWave2 {( "G1" 35 )} 
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 34 )} 
wvSelectSignal -win $_nWave2 {( "G1" 34 )} 
wvSetPosition -win $_nWave2 {("G1" 34)}
wvExpandBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 40)}
wvScrollDown -win $_nWave2 3
wvSelectSignal -win $_nWave2 {( "G1" 39 )} 
wvSetPosition -win $_nWave2 {("G1" 39)}
wvExpandBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 45)}
wvSelectSignal -win $_nWave2 {( "G1" 39 )} 
wvSetPosition -win $_nWave2 {("G1" 39)}
wvCollapseBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 39)}
wvSetPosition -win $_nWave2 {("G1" 40)}
wvSelectSignal -win $_nWave2 {( "G1" 40 )} 
wvSelectSignal -win $_nWave2 {( "G1" 40 )} 
wvExpandBus -win $_nWave2
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 42 )} 
wvSelectSignal -win $_nWave2 {( "G1" 41 )} 
wvSelectSignal -win $_nWave2 {( "G1" 41 )} 
wvSetPosition -win $_nWave2 {("G1" 41)}
wvExpandBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 46)}
wvSelectSignal -win $_nWave2 {( "G1" 41 )} 
wvSetPosition -win $_nWave2 {("G1" 41)}
wvCollapseBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 41)}
wvSetPosition -win $_nWave2 {("G1" 43)}
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "mshr_update_pld" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "mshr_update_pld" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "req_pld_A" -line 326 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 33 )} 
wvSetPosition -win $_nWave2 {("G1" 33)}
wvCollapseBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 33)}
wvSetPosition -win $_nWave2 {("G1" 38)}
wvSelectSignal -win $_nWave2 {( "G1" 32 )} 
wvSetPosition -win $_nWave2 {("G1" 32)}
wvCollapseBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 32)}
wvSetPosition -win $_nWave2 {("G1" 33)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "req_vld_B" -line 327 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSignalViewSelect \
           "icache_top_tb.dut.u_icache_tag_array_ctrl.bypass_rd_dataramA_vld"
verdiSetActWin -dock widgetDock_<Signal_List>
srcDeselectAll -win $_nTrace1
srcSelect -signal "bypass_rd_dataramA_vld" -line 23 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_index_way_checkpass" -line 27 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "cre_tag_req_vld" -line 35 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 13 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bypass_rd_dataramA_vld" -line 23 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bypass_rd_dataramA_vld" -line 23 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_array_A_wr_en" -line 43 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tag_array_A_wr_en" -line 43 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "v_A_hazard_bitmap" -line 29 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "v_B_hazard_bitmap" -line 30 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcHBSelect "icache_top_tb.dut.u_icache_tag_array_ctrl.gen_hazard_bitmap_A\[2\]" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "icache_top_tb.dut.u_icache_mshr_file" -win $_nTrace1
srcSetScope "icache_top_tb.dut.u_icache_mshr_file" -delim "." -win $_nTrace1
srcHBSelect "icache_top_tb.dut.u_icache_mshr_file" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "alloc_index" -line 16 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "pre_tag_req_vld" -line 13 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 450.343435 -snap {("G1" 41)}
wvSetCursor -win $_nWave2 505.697926 -snap {("G1" 40)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataram_rd_rdy" -line 22 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_vld" -line 23 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataram_rd_rdy" -line 22 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 7 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 708.028133 -snap {("G1" 44)}
wvSelectSignal -win $_nWave2 {( "G1" 35 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_vld" -line 36 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_rdy" -line 37 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_entry_id" -line 39 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "icache_top_tb.dut.u_icache_mshr_file.MSHR_ENTRY_ARRAY\[0\].u_icache_mshr_entry" \
           -win $_nTrace1
srcSetScope \
           "icache_top_tb.dut.u_icache_mshr_file.MSHR_ENTRY_ARRAY\[0\].u_icache_mshr_entry" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "icache_top_tb.dut.u_icache_mshr_file.MSHR_ENTRY_ARRAY\[0\].u_icache_mshr_entry" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillA_done" -line 30 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillB_done" -line 31 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "release_en" -line 33 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "alloc_vld" -line 63 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "allocate_en" -line 65 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 40 )} 
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 450.343435 -snap {("G1" 41)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 64 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 64 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.valid" -line 64 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_data.pld" -line 88 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_data.pld" -line 88 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 55 )} 
wvExpandBus -win $_nWave2
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 56 )} 
wvSetPosition -win $_nWave2 {("G1" 56)}
wvExpandBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 60)}
wvZoom -win $_nWave2 365.402924 698.484255
wvScrollDown -win $_nWave2 2
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 60 )} 
wvSelectSignal -win $_nWave2 {( "G1" 60 )} 
wvExpandBus -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "v_A_hazard_bitmap" -line 91 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram_2sent" -line 108 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_data_2done" -line 108 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "linefill_data_2done" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "linefill_data_2done" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataA_done" -line 173 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillA_done" -line 164 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataA_done" -line 164 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 65 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillB_done" -line 170 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -win $_nWave2
wvZoomOut -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 170 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 67 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillB_done" -line 170 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillB_done" -line 170 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "allocate_en" -line 168 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 168 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.B_miss" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hazard_free" -line 174 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 174 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_vld" -line 174 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "B_hazard_free" -line 174 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentB" -line 174 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 155 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 155 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_vld" -line 156 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_rdy" -line 156 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "B_miss" -line 154 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_miss" -line 163 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataA_done" -line 163 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "allocate_en" -line 168 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 168 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 168 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 169 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 169 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.B_miss" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillB_done" -line 170 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "allocate_en" -line 163 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillA_done" -line 164 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 84 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 82 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "allocate_en" -line 168 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hit" -line 168 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 168 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 169 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 169 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 91 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefillB_done" -line 170 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 169 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 92 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentB" -line 153 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentB" -line 153 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 169 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 83 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 92 )} 
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_vld" -line 164 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_rdy" -line 164 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_2sent" -line 166 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentB" -line 166 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 166 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_2sent" -line 166 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentB" -line 166 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 166 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 508.937368 -snap {("G1" 98)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 528.931336 -snap {("G1" 98)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 163 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 163 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_2sent" -line 166 -pos 1 -win $_nTrace1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "linefill_2sent" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "linefill_2sent" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataA_done" -line 170 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_dataB_done" -line 175 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.B_miss" -line 177 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_sentA" -line 177 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 177 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_data_2done" -line 181 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 1046.956872 -snap {("G1" 105)}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_txreq_vld" -line 182 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.A_hit" -line 190 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "hazard_free" -line 190 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.A_hit" -line 190 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.A_hit" -line 190 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram" -line 193 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_vld" -line 200 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramB_rd_vld" -line 204 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_pld.rd_index" -line 202 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramB_rd_pld.rd_index" -line 206 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataram_rd_rdy" -line 211 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 211 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_vld" -line 211 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram" -line 200 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 115 )} 
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 1365.042727 -snap {("G1" 113)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mshr_entry_array.pld.pldA.txnid" -line 203 -pos 1 -win \
          $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 210 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 210 -pos 1 -win $_nTrace1
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect \
           "icache_top_tb.dut.u_icache_mshr_file.MSHR_ENTRY_ARRAY\[0\].u_icache_mshr_entry.hazard_free"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "hazard_free" -next
uniFindSearchString -widget MTB_SOURCE_TAB_1 -pattern "hazard_free" -next
srcDeselectAll -win $_nTrace1
srcSelect -signal "A_hazard_free" -line 131 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 110 )} 
verdiSetActWin -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 110)}
wvSelectSignal -win $_nWave2 {( "G1" 110 )} 
wvSelectSignal -win $_nWave2 {( "G1" 110 )} 
wvSetCursor -win $_nWave2 1068.768474 -snap {("G1" 116)}
wvSetCursor -win $_nWave2 1065.133207 -snap {("G1" 108)}
wvSelectSignal -win $_nWave2 {( "G1" 105 )} 
wvSetCursor -win $_nWave2 1048.774505 -snap {("G1" 105)}
wvSetCursor -win $_nWave2 1045.139239 -snap {("G1" 110)}
srcDeselectAll -win $_nTrace1
debReload
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 111 )} 
wvSelectSignal -win $_nWave2 {( "G1" 112 )} 
wvSetCursor -win $_nWave2 447.137831 -snap {("G1" 105)}
wvSelectSignal -win $_nWave2 {( "G1" 116 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram" -line 194 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G1" 110 )} 
wvSetPosition -win $_nWave2 {("G1" 116)}
verdiSetActWin -win $_nWave2
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 116)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 203 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 214 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "allocate_en" -line 214 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "hazard_free" -line 203 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 203 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
wvSelectSignal -win $_nWave2 {( "G1" 121 )} 
wvSetCursor -win $_nWave2 483.490500 -snap {("G1" 116)}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 \
           {( "G1" 109 110 111 112 113 114 115 116 117 118 119 \
           120 121 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 108)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G1" 106 )} 
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 1046.956872 -snap {("G1" 105)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 216 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram_2sent" -line 191 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_vld" -line 206 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_done" -line 206 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "hazard_free" -line 206 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_vld" -line 206 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 109 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram" -line 198 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram" -line 198 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram_2sent" -line 198 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "entry_active" -line 195 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 111 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram_2sent" -line 192 -pos 1 -win $_nTrace1
wvDrop -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "state_rd_dataram_2sent" -line 192 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_data_2done" -line 219 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcHBSelect "icache_top_tb.dut.u_data_array_ctrl" -win $_nTrace1
srcSetScope "icache_top_tb.dut.u_data_array_ctrl" -delim "." -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "dataramA_rd_vld" -line 9 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 110 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_txdat_vld" -line 24 -pos 1 -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_txdat_vld" -line 24 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_txdat_txnid" -line 25 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_txdat_data" -line 23 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_rxdat_pld" -line 19 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_rxdat_vld" -line 17 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_txdat_vld" -line 24 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "upstream_txdat_vld" -line 24 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "linefill_ack_entry_idx" -line 20 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "downstream_rxdat_pld" -line 19 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
debExit
