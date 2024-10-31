module icache_mshr_entry
    import toy_pack::*; 
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      , 
    input  logic  [WAY_NUM-1                :0]         A_hit                      ,
    input  logic  [WAY_NUM-1                :0]         B_hit                      ,
    input  logic                                        A_miss                     ,
    input  logic                                        B_miss                     ,
    input  logic                                        bypass_rd_dataramA_vld     ,
    input  logic                                        bypass_rd_dataramB_vld     ,
    input  logic [MSHR_ENTRY_NUM-1          :0]         v_A_hazard_bitmap          ,
    input  logic [MSHR_ENTRY_NUM-1          :0]         v_B_hazard_bitmap          ,
    input  logic                                        A_index_way_checkpass      ,
    input  logic                                        B_index_way_checkpass      ,
    output logic                                        alloc_vld                  ,
    input  logic                                        alloc_rdy                  ,
    input  logic                                        dataram_rd_rdy             ,
    output logic                                        dataramA_rd_vld            ,
    output dataram_rd_pld_t                             dataramA_rd_pld            ,
    output logic                                        dataramB_rd_vld            ,
    output dataram_rd_pld_t                             dataramB_rd_pld            ,
    output logic                                        entry_active               ,
    input  entry_data_t                                 entry_data                 ,
    input  logic                                        entry_en                   ,
    output logic                                        downstream_txreq_vld       ,
    input  logic                                        downstream_txreq_rdy       ,
    output downstream_txreq_t                           downstream_txreq_pld       ,
    output mshr_entry_t                                 mshr_entry_array           ,
    input  logic                                        linefillA_done             ,
    input  logic                                        linefillB_done             ,
    input  logic [MSHR_ENTRY_NUM-1          :0]         v_release_en               ,
    output logic                                        release_en        

    //input  logic                                        downstream_txrsp_vld       ,//TODO
    //output logic                                        downstream_txrsp_rdy       ,
    //input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,
);
    logic                               mshr_entry_array_valid  ;
    logic                               state_rd_dataram_2sent  ;
    logic                               linefill_data_2done     ;
    logic   [MSHR_ENTRY_NUM-1       :0] v_A_keep_hazard_bitmap  ;
    logic   [MSHR_ENTRY_NUM-1       :0] v_B_keep_hazard_bitmap  ;
    logic                               A_index_way_release     ;
    logic                               B_index_way_release     ;
    logic                               A_hazard_free           ;
    logic                               B_hazard_free           ;
    logic                               hazard_free             ;
    logic                               linefill_sentA          ;
    logic                               linefill_sentB          ;
    logic                               linefill_2sent          ;
    logic                               linefill_dataA_done     ;
    logic                               linefill_dataB_done     ;
    logic                               state_rd_dataram        ;
    logic                               state_done              ;
    logic                               rxreq_type              ;
    logic                               pref_type               ;
    logic                               snp_type                ;
    logic                               allocate_en             ;
    logic                               first_valid             ;
    logic                               state_rd_sent_done      ;


    assign alloc_vld      = ~entry_active; 
    assign mshr_entry_array_valid = mshr_entry_array.valid;
    assign entry_active   = mshr_entry_array.valid | first_valid             ;
    assign allocate_en    = bypass_rd_dataramA_vld ? 1'b0 : entry_en;
    assign rxreq_type     = mshr_entry_array.pld.pldA.opcode == UPSTREAM_OPCODE;
    assign pref_type      = mshr_entry_array.pld.pldA.opcode == PREFETCH_OPCODE;
    assign snp_type       = mshr_entry_array.pld.pldA.opcode == DOWNSTREAM_OPCODE;
    
//=========================================================
//             mshr_entry  
//=========================================================

//entry pld
    always_ff@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            mshr_entry_array.pld            <= 'b0    ;
            mshr_entry_array.dest_wayA      <= 'b0    ;
            mshr_entry_array.dest_wayB      <= 'b0    ;
            mshr_entry_array.A_hzd_bitmap   <= 'b0    ;
            mshr_entry_array.B_hzd_bitmap   <= 'b0    ;
            mshr_entry_array.A_hit          <= 'b0    ;
            mshr_entry_array.B_hit          <= 'b0    ;
            mshr_entry_array.A_miss         <= 'b0    ;
            mshr_entry_array.B_miss         <= 'b0    ;
        end
        else if(allocate_en)begin
            mshr_entry_array.pld            <= entry_data.pld           ;
            mshr_entry_array.dest_wayA      <= entry_data.dest_wayA     ;
            mshr_entry_array.dest_wayB      <= entry_data.dest_wayB     ;
            mshr_entry_array.A_hzd_bitmap   <= v_A_hazard_bitmap        ;
            mshr_entry_array.B_hzd_bitmap   <= v_B_hazard_bitmap        ;
            mshr_entry_array.A_hit          <= |A_hit                   ;
            mshr_entry_array.B_hit          <= |B_hit                   ;
            mshr_entry_array.A_miss         <= A_miss                   ;
            mshr_entry_array.B_miss         <= B_miss                   ;
        end
    end

//entry valid 
    always_comb begin
        first_valid = 1'b0;
        if(allocate_en) first_valid = 1'b1;
    end
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)                                              mshr_entry_array.valid <= 1'b0;
        else if(allocate_en)                                    mshr_entry_array.valid <= 1'b1;
        //else if(state_rd_dataram)                             mshr_entry_array.valid <= 1'b0;
        //else if(state_rd_dataram_2sent | linefill_data_2done) mshr_entry_array.valid <= 1'b0;
        //else if(linefill_data_2done && mshr_entry_array.miss) mshr_entry_array.valid <= 1'b0;   
        else if(state_rd_sent_done)                             mshr_entry_array.valid <= 1'b0;
        else                                                    mshr_entry_array.valid <= mshr_entry_array.valid;
    end

//========================================================
// hazard_checking WAIT_dependency
//========================================================
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)              v_A_keep_hazard_bitmap <= 'b0;
        else if(allocate_en)    v_A_keep_hazard_bitmap <= v_A_hazard_bitmap;
        else                    v_A_keep_hazard_bitmap <= v_A_keep_hazard_bitmap &(~v_release_en);
    end
    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)              v_B_keep_hazard_bitmap <= 'b0;
        else if(allocate_en)    v_B_keep_hazard_bitmap <= v_B_hazard_bitmap;
        else                    v_B_keep_hazard_bitmap <= v_B_keep_hazard_bitmap &(~v_release_en);
    end

    assign A_index_way_release = ((|v_A_keep_hazard_bitmap)==1'b0);
    assign B_index_way_release = ((|v_B_keep_hazard_bitmap)==1'b0);

    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)        A_hazard_free <= 1'b0;
        else              A_hazard_free <= (A_index_way_checkpass && allocate_en) || ( A_index_way_release && mshr_entry_array_valid);
    end
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)        B_hazard_free <= 1'b0;
        else              B_hazard_free <= (B_index_way_checkpass && allocate_en) || ( B_index_way_release && mshr_entry_array_valid);
    end
    assign hazard_free = A_hazard_free && B_hazard_free;
    //TODO: 关于release_en，需要考虑是否分开AB,是否要做成linefill完一个就释放一个index？
    
//========================================================
// req downstream   REQ_LINEFILL state
//========================================================
//两个miss的，先发A，再发B。一个miss的，也先检查A是hit还是miss，然后再发B。
//发出后，将sentA置为1；再发B时要求看到sentA为1.


    logic linefill_sentA_edge;
    logic linefill_sentA_1d;
    always_ff@(posedge clk or negedge rst_n)begin
        if(~rst_n) linefill_sentA_1d <= 1'b1;
        else linefill_sentA_1d <= linefill_sentA;
    end
    assign linefill_sentA_edge = linefill_sentA & ~linefill_sentA_1d;
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)                                            linefill_sentA <= 1'b1;
        else if(allocate_en)                                  linefill_sentA <= ~A_miss;
        else if(downstream_txreq_vld && downstream_txreq_rdy) linefill_sentA <= 1'b1;
    end
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)                                            linefill_sentB <= 1'b1;
        else if(allocate_en && |A_hit)                        linefill_sentB <= ~B_miss;
        else if(linefill_sentA_edge && entry_active )         linefill_sentB <= ~mshr_entry_array.B_miss;
        else if(downstream_txreq_vld && downstream_txreq_rdy) linefill_sentB <= 1'b1;
    end
    assign linefill_2sent = linefill_sentB & linefill_sentA;


    //always_ff@(posedge clk or negedge rst_n) begin
    //    if(~rst_n)              linefill_dataA_done <= 1'b1;
    //    else if(allocate_en )   linefill_dataA_done <= ~A_miss;
    //    else if(linefillA_done) linefill_dataA_done <= 1'b1;
    //end
    //always_ff@(posedge clk or negedge rst_n) begin
    //    if(~rst_n)                               linefill_dataB_done <= 1'b1;
    //    else if(allocate_en && A_hit)            linefill_dataB_done <= ~B_miss;
    //    else if(linefill_sentA_edge && entry_active ) linefill_dataB_done <= ~mshr_entry_array.B_miss;
    //    else if(linefillB_done)                  linefill_dataB_done <= 1'b1;
    //end
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)              linefill_dataA_done <= 1'b0;
        else if(allocate_en )   linefill_dataA_done <= ~A_miss;
        else if(linefillA_done) linefill_dataA_done <= 1'b1;
    end
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)                                      linefill_dataB_done <= 1'b0;
        else if(allocate_en && A_hit)                   linefill_dataB_done <= ~B_miss;
        else if(linefill_sentA_edge && entry_active )   linefill_dataB_done <= ~mshr_entry_array.B_miss;
        else if(linefillB_done)                         linefill_dataB_done <= 1'b1;
    end

    
    assign linefill_data_2done  = linefill_dataA_done && linefill_dataB_done;
    assign downstream_txreq_vld = (A_hazard_free && (~linefill_sentA)) || (B_hazard_free && ( ~linefill_sentB));
    assign downstream_txreq_pld.pld = (linefill_sentA==1'b0) ? mshr_entry_array.pld.pldA : mshr_entry_array.pld.pldB ;
    assign downstream_txreq_pld.lineA = (linefill_sentA==1'b0) ? 1'b1 : 1'b0;////1: index; 0: index+1

//TODO: 1miss and 1hit的情况，怎样进入到state_done状态
//目前认为，如果是两个miss，则A的linefill_sent后再发起B的linefill_sent；如果一个hit+1个miss，先看A，如果AhitBmiss，则直接发起B的linefill_sent，如果Amiss Bhit，则因为先检查A，保证了A能发出
    //关键是等待linefill的返回，linefill_doneA和linefill_doneB都为1了说明两个都收到了，则进入到state_done状态。关键在于控制linefill_done的产生。
//进入state_done说明数据完备，可以发起dataram_rd了
    assign state_rd_dataram_2sent = hazard_free && mshr_entry_array.A_hit && mshr_entry_array.B_hit;
    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)                                                              state_rd_dataram <= 1'b1;
        else if (allocate_en)                                                   state_rd_dataram <= ~entry_active;
        //else if((linefill_data_2done && rxreq_type) | state_rd_dataram_2sent)   state_rd_dataram <= 1'b1;
        else if(dataramA_rd_vld && dataram_rd_rdy)   state_rd_dataram <= 1'b1;
        //else if(linefill_data_2done | state_rd_dataram_2sent) state_rd_dataram <= 1'b1;
    end


//========================================================
// read request 
//========================================================
    //assign dataramA_rd_vld           = (linefill_data_2done && hazard_free) | state_rd_dataram_2sent;
    assign dataramA_rd_vld           = (~state_rd_sent_done && state_rd_dataram_2sent && mshr_entry_array.A_hit&&  mshr_entry_array.B_hit ) | ( ~state_rd_sent_done && linefill_data_2done && ( mshr_entry_array.A_miss |  mshr_entry_array.B_miss) );
    //assign dataramA_rd_vld           = ~state_rd_dataram && hazard_free;
    assign dataramA_rd_pld.rd_way    = mshr_entry_array.dest_wayA                   ;
    assign dataramA_rd_pld.rd_index  = mshr_entry_array.pld.pldA.addr.index         ;  
    assign dataramA_rd_pld.rd_txnid  = mshr_entry_array.pld.pldA.txnid              ;
    assign dataramB_rd_vld           = (~state_rd_sent_done && state_rd_dataram_2sent && mshr_entry_array.A_hit&&  mshr_entry_array.B_hit ) | ( ~state_rd_sent_done && linefill_data_2done && ( mshr_entry_array.A_miss |  mshr_entry_array.B_miss) );;                             
    assign dataramB_rd_pld.rd_way    = mshr_entry_array.dest_wayB                   ;
    assign dataramB_rd_pld.rd_index  = mshr_entry_array.pld.pldB.addr.index         ;  
    assign dataramB_rd_pld.rd_txnid  = mshr_entry_array.pld.pldB.txnid              ;

    always_ff@(posedge clk or negedge rst_n)begin
        if(~rst_n)                                                                          state_rd_sent_done <= 1'b1;
        else if(allocate_en )                                                               state_rd_sent_done <= ~((|A_hit)|(|B_hit)|A_miss|B_miss);
        else if((dataramA_rd_vld && dataram_rd_rdy) | (linefill_data_2done && pref_type))   state_rd_sent_done <= 1'b1;
    end

    assign release_en = state_rd_sent_done;

    
    

//========================================================
// write dataram   linefill data  process in dataram_ctrl
//========================================================



















//===========================================
//===========================================

    
endmodule