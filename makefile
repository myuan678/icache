RTL_COMPILE_OUTPUT 	= /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/work/rtl_compile
RTL_SIM_OUTPUT      = /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/work/rtl_sim
RTL_SIM_COV         = /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/work/rtl_sim_cov
RTL_NEWSIM_OUTPUT   = /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/work/rtl_new_sim
VERILATOR           = /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/work/verilator	

.PHONY: compile lint

compile:
	mkdir -p $(RTL_COMPILE_OUTPUT)
	cd $(RTL_COMPILE_OUTPUT) ;vcs -kdb -full64 -debug_access -sverilog -f /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/icache_compile.f +lint=PCWM +lint=TFIPC-L +define+TOY_SIM

sim:
	mkdir -p $(RTL_SIM_OUTPUT)
	cd $(RTL_SIM_OUTPUT); vcs -sverilog -kdb +v2k -debug_access+all -debug_all -full64 -timescale=1ns/1ns -l com.log -f /data/usr/xuemy/try/icache_for_scalar/icache/icache_filelist.f -R +WAVE
new_sim:
	mkdir -p $(RTL_NEWSIM_OUTPUT)
	cd $(RTL_NEWSIM_OUTPUT); vcs -sverilog -kdb +v2k -debug_access+all -debug_all -full64 -timescale=1ns/1ns -l com.log -f /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/icache_sim_filelist.f -R +WAVE


sim_cov:
	mkdir -p $(RTL_SIM_COV)
	cd $(RTL_SIM_COV); vcs -sverilog -kdb +v2k -debug_access+all -debug_all -full64 -timescale=1ns/1ns -l com.log -f /data/usr/xuemy/try/cache_v1/icache_v1_1008_release/icache_filelist.f -cm line+cond+fsm+branch+tgl -R +WAVE -cm_name simv -cm_dir ./coverage

ver:
	verilator -f icache_filelist.f

# wsl compile
comp:
	mkdir -p $(RTL_COMPILE_OUTPUT)
	cd $(RTL_COMPILE_OUTPUT) ;vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed -kdb -lca -full64 -debug_access -sverilog -f $(SIM_FILELIST) +lint=PCWM +lint=TFIPC-L +define+TOY_SIM

lint:
	fde -file qc/lint.tcl -flow lint

isa:
	cd ./rv_isa_test/build ;ctest -j64


dhry:
	${RTL_COMPILE_OUTPUT}/simv +HEX=${RV_TEST_PATH}/hello_world/build/dhrystone_itcm.hex +DATA_HEX=${RV_TEST_PATH}/hello_world/build/dhrystone_dtcm.hex +TIMEOUT=200000 +WAVE +PC=pc_trace.log 

cm:
	${RTL_COMPILE_OUTPUT}/simv +HEX=${RV_TEST_PATH}/hello_world/build/coremark_itcm.hex +DATA_HEX=${RV_TEST_PATH}/hello_world/build/coremark_dtcm.hex  +TIMEOUT=0 +PC=pc_trace.log

verdi:
	verdi -sv -f $(SIM_FILELIST) -ssf wave.fsdb -dbdir $(RTL_COMPILE_OUTPUT)/simv.daidir


verdi_sim:
	verdi -sv -ssf wave.fsdb -dbdir simv.daidir &

#verilator:
#	/data/usr/liuyunqi/sw/verilator5018/bin/verilator -Wno-UNSIGNED -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-ASCRANGE -Wno-IMPLICIT -Wno-PINMISSING -Wno-WIDTHCONCAT -DVERILATOR_COMPIL -f icache_filelist.f --top-module icache_top --cc --exe --timing --sv --Wall

verilator:
	mkdir -p $(VERILATOR)
	cd $(VERILATOR);  /data/usr/liuyunqi/sw/verilator5018/bin/verilator -Wno-UNSIGNED -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-ASCRANGE -Wno-IMPLICIT -Wno-PINMISSING -Wno-WIDTHCONCAT -DVERILATOR_COMPIL -f /data/usr/xuemy/try/icache_for_scalar/icache/verilator_sim.f --top-module icache_top --cc --exe --timing --sv --Wall

#1. make verilator
#2. make -C obj_dir -f Vicache_top.mk
#3. ./obj_dir/Vicache_top
