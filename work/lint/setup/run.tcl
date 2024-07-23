
package require fde
set FDE_PRINT_PIPE /home/xuemengyuan/try/cache_v1/icache/work/lint/.pipe/fde_print.pipe
puts "start to open $FDE_PRINT_PIPE"
set FDE_PRINT_FP [open $FDE_PRINT_PIPE {WRONLY NONBLOCK}]
puts "open success."
;package require fde

########################################################
# from lint in /home/xuemengyuan/try/cache/lint.tcl
########################################################

fde::ffputs -type info "#########################################################"
fde::ffputs -type info "|lint| start |from /home/xuemengyuan/try/cache/lint.tcl|"

set FDE_RUNTIME(lint,start_seconds) [clock seconds]




    namespace import fde::*
    fde::ffputs -type info "this is lint flow root."



package require fde

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

package require fde

########################################################
# from lint.user_config in /home/xuemengyuan/try/cache_v1/icache/qc/lint.tcl
########################################################

fde::ffputs -type info "#########################################################"
fde::ffputs -type info "|lint.user_config| start |from /home/xuemengyuan/try/cache_v1/icache/qc/lint.tcl|"

set FDE_RUNTIME(lint.user_config,start_seconds) [clock seconds]




    set design(top_name)    "icache_top"
    #set design(filelist)    "$env(TOY_SCALAR_PATH)/rtl/toy_scalar.f"
    set design(filelist)    "/home/xuemengyuan/try/cache_v1/icache/icache_filelist.f"
    #set lint(waiver)        "$env(TOY_SCALAR_PATH)/qc/lint.awl"
    set lint(waiver)        "/home/xuemengyuan/try/cache_v1/icache/qc/lint.awl"




set FDE_RUNTIME(lint.user_config,end_seconds)     [clock seconds]
set FDE_RUNTIME(lint.user_config,runtime_seconds) [expr $FDE_RUNTIME(lint.user_config,end_seconds) - $FDE_RUNTIME(lint.user_config,start_seconds) ]
set fmted_seconds [fde::fde_auto_format_seconds $FDE_RUNTIME(lint.user_config,runtime_seconds)]

lappend FDE_RUNTIME_SEQ lint.user_config

fde::ffputs -type info "|lint.user_config| Finish, use $fmted_seconds.
"

package require fde

########################################################
# from lint.run in /home/xuemengyuan/try/cache/lint.tcl
########################################################

fde::ffputs -type info "#########################################################"
fde::ffputs -type info "|lint.run| start |from /home/xuemengyuan/try/cache/lint.tcl|"

set FDE_RUNTIME(lint.run,start_seconds) [clock seconds]




    fde::ffputs -type info "this is lint run stage"

    #puts FDE_PRINT_OFF

    new_project lint -projectwdir [file normalize .] -force
    
   
    # read_sdc_data -top $design(top_name) $design(sdc)

    fde::ffputs -type info "Start to set design top name as \"$design(top_name)\"."
    current_design $design(top_name)
    
    fde::ffputs -type info "Start to read design filelist:$design(filelist)."
    read_file -type sourcelist $design(filelist)

    fde::ffputs -type info "Start to read lint waiver:$lint(waiver)."
    read_file -type awl $lint(waiver)


    fde::ffputs -type info "start to read sdc/library and setup."
    fde::ffputs -type info "lint use step:syn and check:setup view."


    set view_dict [fde_get_timing_view -step syn -check setup]

    set view_num [dict size $view_dict]
    if {$view_num < 1} {
        fde::ffputs -type info "No view in step:syn and check:setup, use spyglass default lib and no sdc loaded."

        sdc_data -file $fde::FDE_HOME/../../demo/lint/src/test.sdc
        read_file -type gateslib $env(SPYGLASS_HOME)/examples/sg_shell/design_query/example.lib
    } else {
    
        fde::ffputs -type info "There are $view_num views in step:syn and check:setup."
        if {$view_num eq 1} {
        } else {
            fde::ffputs -type info "More than one view in step:syn and check:setup."
        }

        set mode    [dict keys $view_dict]
        set pvt     [dict get $view_dict $mode]

        fde::ffputs -type info "Use mode:$mode and pvt:$pvt."

        set sdc [fde::get_timing_mode -mode $mode]
        fde::ffputs -type info "read sdc:$sdc"

        set lib_dict [fde::ff_lib_read -file [fde::get_target_library] -pvt $pvt -name [fde::fde_get_std_sets]]
        fde::ffputs -type info "get library dict lib_dict:$lib_dict"

        set lib_list [fde::ff_lib_get -data $lib_dict -key lib]
        fde::ffputs -type info "start to set lib_list:[lindex $lib_list 0]"

        fde::ffputs -type info "start to read sdc $sdc"
        sdc_data -file $sdc

        set tmp [subst [lindex $lib_list 0]]
        fde::ffputs -type info "start to read library $tmp"
        read_file -type gateslib $tmp
    }


    
    



    set_option sdc2sgdc yes
    set_option enable_precompile_vlog yes
    # set_option enableSV yes
    set_option sort yes
    set_option 87 yes
    set_option language_mode mixed
    set_option designread_disable_flatten yes
    set_option sgsyn_clock_gating yes
    set_option allow_module_override yes
    set_option vlog2001_generate_name yes
    set_option handlememory yes
    set_option define_cell_sim_depth 11
    set_option mthresh 400000
    set_option disable_html_report {html}
    set_option enable_save_restore yes
    # set_option designread_enable_synthesis yes
    set_option designread_synthesis_mode opt
    # set_option elab_precompile yes
    set_option enable_sglib_debug yes
    set_option enable_gateslib_autocompile yes
    set_option enable_sglib_debug yes
    set_option enableSV09 1
    set_option enableSVA yes
    set_option allow_non_lrm yes
    set_option dw yes
    # set_option use_vcs_synthesis yes

    
    # need spyglass version > 2016
    # set_option enable_sg_reports_summary yes  
    # set_parameter enable_glitchfreecell_detection yes
    set_parameter pt no
    #set_option auto_save yes

    current_methodology $SPYGLASS_HOME/GuideWare/latest/block/rtl_handoff
    # current_goal lint/lint_rtl -top $design(top_name)
    set_option top $design(top_name)

    set goal_name mygoal

    # define_goal $goal_name -policy {lint starc starc2002 starc2005 spyglass openmore morelint latch simulation miscellaneous} {}
    define_goal $goal_name -policy {lint starc starc2002 starc2005 spyglass simulation latch morelint openmore} {
        set_goal_option define_severity lint+S1_error+ERROR
        set_goal_option define_severity lint+S2_error+ERROR
        set_goal_option define_severity lint+S3_error+ERROR
        set_goal_option define_severity lint+S4_error+ERROR
        set_goal_option define_severity lint+S5_error+ERROR

        set_goal_option define_severity starc2005+S1_error+ERROR
        set_goal_option define_severity starc2005+S2_error+ERROR
        set_goal_option define_severity starc2005+S3_error+ERROR
        set_goal_option define_severity starc2005+S4_error+ERROR
        set_goal_option define_severity starc2005+S5_error+ERROR

        set_goal_option define_severity starc2002+S1_error+ERROR
        set_goal_option define_severity starc2002+S2_error+ERROR
        set_goal_option define_severity starc2002+S3_error+ERROR
        set_goal_option define_severity starc2002+S4_error+ERROR
        set_goal_option define_severity starc2002+S5_error+ERROR

        set_goal_option define_severity starc+S1_error+ERROR
        set_goal_option define_severity starc+S2_error+ERROR
        set_goal_option define_severity starc+S3_error+ERROR
        set_goal_option define_severity starc+S4_error+ERROR
        set_goal_option define_severity starc+S5_error+ERROR

        set_goal_option define_severity openmore+S1_error+ERROR
        set_goal_option define_severity openmore+S2_error+ERROR
        set_goal_option define_severity openmore+S3_error+ERROR
        set_goal_option define_severity openmore+S4_error+ERROR
        set_goal_option define_severity openmore+S5_error+ERROR

        set_goal_option define_severity morelint+S1_error+ERROR
        set_goal_option define_severity morelint+S2_error+ERROR
        set_goal_option define_severity morelint+S3_error+ERROR
        set_goal_option define_severity morelint+S4_error+ERROR
        set_goal_option define_severity morelint+S5_error+ERROR

        set_goal_option define_severity latch+S1_error+ERROR
        set_goal_option define_severity latch+S2_error+ERROR
        set_goal_option define_severity latch+S3_error+ERROR
        set_goal_option define_severity latch+S4_error+ERROR
        set_goal_option define_severity latch+S5_error+ERROR

        set_goal_option define_severity simulation+S1_error+ERROR
        set_goal_option define_severity simulation+S2_error+ERROR
        set_goal_option define_severity simulation+S3_error+ERROR
        set_goal_option define_severity simulation+S4_error+ERROR
        set_goal_option define_severity simulation+S5_error+ERROR

        # [source $env(PRJ_ICDIR)/demo/lint/lint_rules.tcl]
        source $fde::FDE_HOME/../../demo/lint/lint_rules.tcl
        source $fde::FDE_HOME/../../demo/lint/ver2021_add.tcl
    }
    current_goal mygoal -top $design(top_name)

    run_goal
    puts FDE_PRINT_ON




set FDE_RUNTIME(lint.run,end_seconds)     [clock seconds]
set FDE_RUNTIME(lint.run,runtime_seconds) [expr $FDE_RUNTIME(lint.run,end_seconds) - $FDE_RUNTIME(lint.run,start_seconds) ]
set fmted_seconds [fde::fde_auto_format_seconds $FDE_RUNTIME(lint.run,runtime_seconds)]

lappend FDE_RUNTIME_SEQ lint.run

fde::ffputs -type info "|lint.run| Finish, use $fmted_seconds.
"

package require fde

########################################################
# from lint.post in /home/xuemengyuan/try/cache/lint.tcl
########################################################

fde::ffputs -type info "#########################################################"
fde::ffputs -type info "|lint.post| start |from /home/xuemengyuan/try/cache/lint.tcl|"

set FDE_RUNTIME(lint.post,start_seconds) [clock seconds]




    puts "this is lint post stage"

    save_project
    fde::ffputs -type info "start to create a run_gui command."
    fde::ff_create_file -path "../gui_start" -chmod +x "#!/bin/csh -f\nspyglass -project [file normalize lint.prj] &"

    set res [exec python3 $fde::FDE_HOME/utils/spyglass_lint_moresimple_log_parse.py lint/consolidated_reports/$design(top_name)_$goal_name/moresimple.rpt]
    
    fde::ffputs -type info "Lint summarize:\n$res"

    fde::ffputs -type info "run [file normalize ../gui_start] to start gui."




set FDE_RUNTIME(lint.post,end_seconds)     [clock seconds]
set FDE_RUNTIME(lint.post,runtime_seconds) [expr $FDE_RUNTIME(lint.post,end_seconds) - $FDE_RUNTIME(lint.post,start_seconds) ]
set fmted_seconds [fde::fde_auto_format_seconds $FDE_RUNTIME(lint.post,runtime_seconds)]

lappend FDE_RUNTIME_SEQ lint.post

fde::ffputs -type info "|lint.post| Finish, use $fmted_seconds.
"

package require fde

########################################################
# from lint.exit in /home/xuemengyuan/try/cache/lint.tcl
########################################################

fde::ffputs -type info "#########################################################"
fde::ffputs -type info "|lint.exit| start |from /home/xuemengyuan/try/cache/lint.tcl|"

set FDE_RUNTIME(lint.exit,start_seconds) [clock seconds]





    #exit




set FDE_RUNTIME(lint.exit,end_seconds)     [clock seconds]
set FDE_RUNTIME(lint.exit,runtime_seconds) [expr $FDE_RUNTIME(lint.exit,end_seconds) - $FDE_RUNTIME(lint.exit,start_seconds) ]
set fmted_seconds [fde::fde_auto_format_seconds $FDE_RUNTIME(lint.exit,runtime_seconds)]

lappend FDE_RUNTIME_SEQ lint.exit

fde::ffputs -type info "|lint.exit| Finish, use $fmted_seconds.
"


set FDE_RUNTIME(lint,end_seconds)     [clock seconds]
set FDE_RUNTIME(lint,runtime_seconds) [expr $FDE_RUNTIME(lint,end_seconds) - $FDE_RUNTIME(lint,start_seconds) ]
set fmted_seconds [fde::fde_auto_format_seconds $FDE_RUNTIME(lint,runtime_seconds)]

lappend FDE_RUNTIME_SEQ lint

fde::ffputs -type info "|lint| Finish, use $fmted_seconds.
"
;

    proc encode_array_from_py {arr_name} {
        global $arr_name
        set res ""
        foreach {key value} [array get $arr_name] {
            set res "$res%%%$key%%%%$value%%%%%
"
        }
        return $res 
    }

    set ARR [encode_array_from_py FDE_RUNTIME]
    set TIME_TABLE [fde::ffpy report_time_table.py $FDE_RUNTIME_SEQ $ARR]
    ffputs -type info "Time cost:
$TIME_TABLE"
    $setup(exit)

