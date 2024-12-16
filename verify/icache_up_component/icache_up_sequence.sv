class icache_up_sequence;
    import toy_pack::*;
    icache_cfg          cfg                     ;
    mailbox             drv_mbx                 ;
    event               drv_send_done           ;
    int                 file                    ;
    int                 read_bytes              ;
    typedef struct packed {
        logic [ICACHE_TAG_WIDTH-1:0]    tag     ;
        logic [ICACHE_INDEX_WIDTH-1:0]  index   ;
        logic [ICACHE_OFFSET_WIDTH-1:0] offset  ;
    } addr_t;
    addr_t    data_buffer                       ;

    rand bit txnid;

    function new();
        cfg = new();  
    endfunction

    virtual task base_seq(int num=10);
      for (int i = 0; i < num; i++) begin
        icache_up_transaction up_trans = new;
        up_trans.randomize();
        $display("[UP_SEQ] base seq transaction random start");
        if(cfg.debug_en) $display ("T=%0t [UP_SEQUENCE] ITEM NUM :%0d/%0d create next transaction", $time, i+1, num);
        up_trans.delay = 0;
        drv_mbx.put(up_trans);
        //@(drv_send_done);
      end
      $display ("T=%0t [UP_SEQUENCE] Done generation of %0d transactions", $time, num);
    endtask


        
    virtual task trace_seq();
        string trace_file_path = "/data/usr/xuemy/try/cache_v1/icache_v1_1008_release/trace_replay/align_pc_trace_2.bin";
        if($value$plusargs("trace_file=%s", trace_file_path))begin;
           $display("trace_file_path=%s", trace_file_path);
        end
        file = $fopen(trace_file_path, "rb");
        if (file == 0) begin
            $display("Error: Cannot open file.");
            $finish;
        end
        while (!$feof(file)) begin
            icache_up_transaction up_trans_trace = new;
            up_trans_trace.randomize();
            read_bytes = $fread(data_buffer, file); 
            if (read_bytes != 4) begin
                $display("Warning: Incomplete read, read %0d bytes.", read_bytes);
                break;
            end
            up_trans_trace.tag    = data_buffer.tag;  
            up_trans_trace.index  = data_buffer.index;
            up_trans_trace.offset = data_buffer.offset;
            if(cfg.debug_en)  $display ("T=%0t [TRACE_SEQUENCE]", $time);
            drv_mbx.put(up_trans_trace);
            @(drv_send_done);
        end
        $fclose(file);
    endtask

endclass
