;package require fde

########################################################
# from lint.setup in /home/xuemengyuan/try/cache/lint.tcl
########################################################

fde::ffputs -type info "#########################################################"
fde::ffputs -type info "|lint.setup| start |from /home/xuemengyuan/try/cache/lint.tcl|"

set FDE_RUNTIME(lint.setup,start_seconds) [clock seconds]




    set setup(command)  "sg_shell -tcl"
    set setup(tool)     "spyglass"
    set setup(exit)     "exit"




set FDE_RUNTIME(lint.setup,end_seconds)     [clock seconds]
set FDE_RUNTIME(lint.setup,runtime_seconds) [expr $FDE_RUNTIME(lint.setup,end_seconds) - $FDE_RUNTIME(lint.setup,start_seconds) ]
set fmted_seconds [fde::fde_auto_format_seconds $FDE_RUNTIME(lint.setup,runtime_seconds)]

lappend FDE_RUNTIME_SEQ lint.setup

fde::ffputs -type info "|lint.setup| Finish, use $fmted_seconds.
"
;
