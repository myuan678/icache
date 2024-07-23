################################################################################
#This is an internally genertaed by SpyGlass for Message Tagging Support
################################################################################


use spyglass;
use SpyGlass;
use SpyGlass::Objects;
spyRebootMsgTagSupport();

spySetMsgTagCount(0,44);
spyParseTextMessageTagFile("/home/xuemengyuan/try/cache_v1/icache/work/lint/workspace/lint/icache_top/mygoal/spyglass_spysch/dw/SPY_PRECOMPILED_LIBS/dw_libs_all_compile_work/spyglass_spysch/sg_msgtag.txt");

if(!defined $::spyInIspy || !$::spyInIspy)
{
    spyDefineReportGroupingOrder("ALL",
(
"BUILTIN"   => [SGTAGTRUE, SGTAGFALSE]
)
);
}
spyMessageTagTestBenchmark(1,"/home/xuemengyuan/try/cache_v1/icache/work/lint/workspace/lint/icache_top/mygoal/spyglass_spysch/dw/SPY_PRECOMPILED_LIBS/dw_libs_all_compile_work/spyglass.vdb");

1;
