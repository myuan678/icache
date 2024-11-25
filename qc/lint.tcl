
#source $env(FDE_HOME)/demo/lint/lint.tcl
source /home/xuemengyuan/try/cache/lint.tcl

fde_add -obj lint.user_config -name user_config -position on {
    set design(top_name)    "icache_top"
    #set design(filelist)    "$env(TOY_SCALAR_PATH)/rtl/toy_scalar.f"
    set design(filelist)    "/home/xuemengyuan/try/cache_v1/icache/icache_filelist.f"
    #set lint(waiver)        "$env(TOY_SCALAR_PATH)/qc/lint.awl"
    set lint(waiver)        "/home/xuemengyuan/try/cache_v1/icache/qc/lint.awl"
}
