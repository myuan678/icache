RTL_COMPILE_OUTPUT 	= /home/xuemengyuan/try/cache_v1/icache/work/rtl_compile

.PHONY: compile lint

compile:
	mkdir -p $(RTL_COMPILE_OUTPUT)
	cd $(RTL_COMPILE_OUTPUT) ;vcs -kdb -full64 -debug_access -sverilog -f /home/xuemengyuan/try/cache_v1/icache/icache_filelist.f +lint=PCWM +lint=TFIPC-L +define+TOY_SIM



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