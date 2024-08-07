verdiSetActWin -dock widgetDock_<Message>
simSetSimulator "-vcssv" -exec "simv" -args "+v2k -a com.log +WAVE"
debImport "-sv" "-dbdir" "simv.daidir"
debLoadSimResult /home/xuemengyuan/try/cache_v1/icache/work/rtl_sim/wave.fsdb
wvCreateWindow
verdiWindowResize -win $_Verdi_1 "199" "57" "800" "578"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetCursor -win $_nWave2 2685.681818
verdiSetActWin -win $_nWave2
srcHBSelect "icache_top_tb" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSetScope "icache_top_tb" -delim "." -win $_nTrace1
srcHBSelect "icache_top_tb" -win $_nTrace1
verdiSetActWin -win $_nWave2
