module icache_mshr_entry_buffer 
    import toy_pack::*; 
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,    
    input  logic  [WAY_NUM-1                :0]         tag_hit                    , //2way
    input  logic                                        tag_miss                   ,
    input  logic                                        allocate_en                ,
    input  entry_data_t                                 entry_data                 ,
    input  logic [MSHR_ENTRY_NUM-1          :0]         entry_bitmap               ,

    output logic                                        dataram_rd_vld             ,
    input  logic                                        dataram_rd_rdy             ,
    output logic                                        dataram_rd_way             ,
    output logic [ICACHE_INDEX_WIDTH-1      :0]         dataram_rd_index           ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1  :0]         dataram_rd_txnid           ,

    output logic                                        entry_valid                ,
    output logic                                        entry_idle                 ,
    output logic                                        entry_release_done         ,
    output logic                                        downstream_txreq_vld       ,
    input  logic                                        downstream_txreq_rdy       ,
    output pc_req_t                                     downstream_txreq_pld       ,
    output mshr_entry_t                                 mshr_entry_array           ,
    input  logic                                        downstream_release_en      ,
    input  logic                                        dataram_release_en         ,
    input  logic                                        linefill_done              

    //input  logic                                        downstream_txrsp_vld       ,//TODO
    //output logic                                        downstream_txrsp_rdy       ,
    //input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,
);
    logic                                               mshr_hit                   ;
    logic                                               mshr_miss                  ;
    entry_data_t                                        entry_data_keep            ;
    logic [MSHR_ENTRY_NUM-1     :0]                     entry_bitmap_keep          ;
    logic                                               entry_valid_1d             ;  
    logic                                               downstream_release_en_d1   ;
    logic                                               done                       ;

    assign mshr_miss                                    = ~mshr_hit && entry_valid ;
    assign entry_idle                                   = ~entry_valid             ;

    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            entry_valid_1d           <= 1'b0                                       ;
        end 
        else begin
            entry_valid_1d           <= entry_valid                                ;
        end
    end
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            entry_data_keep.pld      <= '{default:'0}                               ;
            entry_data_keep.dest_way <= 'b0                                         ;
            entry_bitmap_keep        <= 'b0                                         ;
        end
        else if (dataram_release_en | done)begin
            entry_data_keep.pld      <= '{default:'0}                               ;
            entry_data_keep.dest_way <= 'b0                                         ;
            entry_bitmap_keep        <= 'b0                                         ;
        end
        else if(entry_valid & ~entry_valid_1d)begin
            entry_data_keep          <= entry_data                                  ;
            entry_bitmap_keep        <= entry_bitmap                                ;
        end
        else begin
            entry_data_keep          <= entry_data_keep                             ;
            entry_bitmap_keep        <= entry_bitmap_keep                           ;
        end
    end
    
    always_comb begin
        if(entry_valid)begin
            mshr_hit = |entry_bitmap                                                ;
        end
        else begin
            mshr_hit = 1'b0                                                         ;     
        end
    end

    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            downstream_release_en_d1 <= 'b0                                         ;
        end
        else begin
            downstream_release_en_d1 <= downstream_release_en                       ;
        end
    end

    state_t cur_state, next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_state <= IDLE                                                     ;
        end                                 
        else begin                              
            cur_state <= next_state                                               ;
        end
    end

    always_comb begin
        next_state                          = cur_state                               ;
        entry_valid                         = 1'b0                                    ;
        dataram_rd_vld                      = 'b0                                     ;
        dataram_rd_index                    = 'b0                                     ;
        dataram_rd_txnid                    = 'b0                                     ;
        dataram_rd_way                      = 'b0                                     ;
        downstream_txreq_vld                = 'b0                                     ; 
        downstream_txreq_pld                = '{32'b0,5'b0,5'b0}                      ; 
        entry_release_done                  = 1'b0                                    ;
        done                                = 1'b0                                    ; 
        mshr_entry_array                    = '{1'b0, '{32'b0,5'b0,5'b0}, 1'b0, 8'b0 };
        case (cur_state)
            IDLE:begin
                if(allocate_en)begin
                    next_state              = COMP                                  ;
                end     
                else begin      
                    next_state              = IDLE                                  ;
                end
            end
            COMP: begin   
                entry_valid                 = 1'b1                                  ;
                mshr_entry_array.valid      = 1'b1                                  ;
                mshr_entry_array.req_pld    = entry_data.pld                        ;
                mshr_entry_array.dest_way   = entry_data.dest_way                   ;
                mshr_entry_array.hit_bitmap = entry_bitmap                          ;        
                if (|tag_hit & mshr_miss) begin
                    if(mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE)begin
                        next_state          = READ_DATA                             ;
                    end
                    else if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state          = END_STATE                             ;
                    end
                    else if(mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE)begin
                        next_state          = END_STATE                             ;
                    end
                end
                else if (|tag_hit && mshr_hit ) begin
                    if(mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE)begin
                        next_state          = DOWNSTREAM_REQ_WAIT_FILL              ;                 
                    end
                    else if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state          = END_STATE                             ;
                    end
                    else if (mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE)begin
                        next_state          = DOWNSTREAM_REQ_WAIT_FILL              ;
                    end
                end
                else if (tag_miss && mshr_miss) begin
                    if(mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE)begin
                        next_state          = DOWNSTREAM_REQ                        ;                    
                    end
                    else if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state          = END_STATE                             ;
                    end
                    else if (mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE)begin
                        next_state          = DOWNSTREAM_REQ                        ;
                    end
                end
                else begin
                    next_state              = IDLE                                  ;
                end
            end
            READ_DATA: begin
                entry_valid                 = 1'b1                                 ;           
                dataram_rd_vld              = 1'b1                                 ;
                dataram_rd_index            = entry_data_keep.pld.addr.index       ;
                dataram_rd_txnid            = entry_data_keep.pld.txnid            ;
                dataram_rd_way              = entry_data_keep.dest_way             ;
                if (dataram_release_en && dataram_rd_rdy) begin
                    next_state              = DATARAM_RELEASE                      ;
                end
                else begin
                    next_state              = READ_DATA                            ;
                end
            end         
            DATARAM_RELEASE:begin
                entry_valid                 = 1'b0                                 ;
                next_state                  = IDLE                                 ;                 
            end
            DOWNSTREAM_REQ: begin
                downstream_txreq_vld        = 1'b1                                 ;
                downstream_txreq_pld        = entry_data_keep.pld                  ;
                entry_valid                 = 1'b1                                 ;
                mshr_entry_array.valid      = 1'b1                                 ;
                mshr_entry_array.req_pld    = entry_data_keep.pld                  ;
                mshr_entry_array.dest_way   = entry_data_keep.dest_way             ;
                mshr_entry_array.hit_bitmap = entry_bitmap_keep                    ; 
                if(downstream_release_en && downstream_txreq_rdy)begin
                    next_state              = DOWNSTREAM_RELEASE                   ;   
                end
                else begin
                    next_state              = DOWNSTREAM_REQ                       ;
                end
            end
            DOWNSTREAM_REQ_WAIT_FILL: begin
                next_state                  = WAIT_FILL_DONE                       ;
                entry_valid                 = 1'b1                                 ;
                mshr_entry_array.valid      = 1'b1                                 ;
                mshr_entry_array.req_pld    = entry_data_keep.pld                  ;
                mshr_entry_array.dest_way   = entry_data_keep.dest_way             ;
                mshr_entry_array.hit_bitmap = entry_bitmap_keep                    ;
            end
            DOWNSTREAM_RELEASE:begin
                next_state                  = WAIT_FILL_DONE ;
                entry_valid                 = 1'b1                                 ;
                mshr_entry_array.valid      = 1'b1                                 ;
                mshr_entry_array.req_pld    = entry_data_keep.pld                  ;
                mshr_entry_array.dest_way   = entry_data_keep.dest_way             ;
                mshr_entry_array.hit_bitmap = entry_bitmap_keep                    ;
            end
            WAIT_FILL_DONE:begin
                if(linefill_done==1'b1)begin
                    entry_valid                 = 1'b1                             ;    
                    mshr_entry_array.valid      = 1'b1                             ;
                    mshr_entry_array.req_pld    = entry_data_keep.pld              ;
                    mshr_entry_array.dest_way   = entry_data_keep.dest_way         ;
                    mshr_entry_array.hit_bitmap = entry_bitmap_keep                ;
                    next_state                  = ENTRY_RELEASE_DONE                             ;
                    entry_release_done          = 1'b1                             ;
                end
                else begin
                    entry_valid = 1'b1;
                    mshr_entry_array.valid      = 1'b1                           ;
                    mshr_entry_array.req_pld    = entry_data_keep.pld            ;
                    mshr_entry_array.dest_way   = entry_data_keep.dest_way       ;
                    mshr_entry_array.hit_bitmap = entry_bitmap_keep              ;
                    next_state                  = WAIT_FILL_DONE                 ;
                end
            end
            ENTRY_RELEASE_DONE:begin
                next_state                  = END_STATE                      ;
                entry_valid                 = 1'b1                           ;
                mshr_entry_array.valid      = 1'b1                           ;
                mshr_entry_array.req_pld    = entry_data_keep.pld            ;
                mshr_entry_array.dest_way   = entry_data_keep.dest_way       ;
                mshr_entry_array.hit_bitmap = entry_bitmap_keep              ;
                entry_release_done          = 1'b0                           ;  
            end
            END_STATE:begin
                next_state                  = IDLE                           ;
                done                        = 1'b0                           ;
                entry_valid                 = 1'b0                           ;
                mshr_entry_array.valid      = 1'b0                           ;
            end
            default: next_state             = IDLE                           ;           
        endcase
    end

endmodule