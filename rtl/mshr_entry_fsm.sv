module icache_mshr_entry_buffer 
    import toy_pack::*; 
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      , 
    input  logic                                        cre_tag_req_vld            ,
    input  logic  [WAY_NUM-1                :0]         tag_hit                    , //2way
    input  logic                                        tag_miss                   ,
    input  logic                                        allocate_en                ,
    input  entry_data_t                                 entry_data                 ,
    input  logic [MSHR_ENTRY_NUM-1          :0]         entry_index_way_bitmap     ,
    input  logic [MSHR_ENTRY_NUM-1          :0]         entry_index_way_bit_keep   , 

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
    output logic                                        hit_entry_done             ,
    input  logic                                        linefill_done              
    );

    logic                                               mshr_hit                   ;
    logic                                               mshr_miss                  ;
    entry_data_t                                        entry_data_keep            ;
    logic [MSHR_ENTRY_NUM-1     :0]                     entry_index_way_bitmap_keep;
    logic                                               entry_valid_1d             ;  
    logic                                               done                       ;
    

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
            entry_data_keep.pld        <= '{default:'0}                             ;
            entry_data_keep.dest_way   <= 'b0                                       ;
            entry_index_way_bitmap_keep <= 'b0                                      ;
        end
        else if (hit_entry_done | done)begin
            entry_data_keep.pld         <= '{default:'0}                            ;
            entry_data_keep.dest_way    <= 'b0                                      ;
            entry_index_way_bitmap_keep <= 'b0                                      ;
        end
        else if(entry_valid & ~entry_valid_1d)begin
            entry_data_keep             <= entry_data                               ;
            entry_index_way_bitmap_keep <= entry_index_way_bitmap                   ;
        end
        else begin
            entry_data_keep             <= entry_data_keep                          ;
            entry_index_way_bitmap_keep <= entry_index_way_bitmap                   ;
        end
    end
    
    logic index_way_checkpass;
    always_comb begin
        index_way_checkpass     = 1'b0;
        if(entry_valid)begin
            index_way_checkpass = (|entry_index_way_bitmap == 1'b0);
        end
    end

    logic index_way_release;
    always_comb begin
        index_way_release     = 1'b0;
        if(entry_valid)begin
            index_way_release = (|entry_index_way_bit_keep == 1'b0);
        end
    end

    state_t cur_state, next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_state <= IDLE;
        end                                 
        else begin                              
            cur_state <= next_state;
        end
    end

always_comb begin
    case(cur_state)
        IDLE:begin
            if(cre_tag_req_vld)     next_state = ALLOC;
            else                    next_state = IDLE;
        end
        ALLOC:begin
            if(allocate_en)begin
                if(|tag_hit && index_way_checkpass)begin
                    if(mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE)begin
                        if ( dataram_release_en && dataram_rd_rdy==1'b1) begin
                            next_state              = READ_DATA                 ;
                        end
                        else if (dataram_release_en && dataram_rd_rdy==1'b0)begin
                            next_state              = WAIT_DATARAM_RDY          ;
                        end
                    end
                    else if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state          = END_STATE                         ;
                    end
                    else if(mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE)begin
                        next_state          = END_STATE                         ;
                    end
                end
                else if (|tag_hit && index_way_checkpass==1'b0 ) begin
                    if(mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE)begin
                        next_state          = WAIT_READ_REQ                       ;                 
                    end
                    else if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state          = END_STATE                           ;
                    end
                    else if (mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE)begin
                        next_state          = END_STATE                           ;
                    end
                end
                else if (tag_miss && index_way_checkpass ) begin
                    if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state          = END_STATE                         ;
                    end
                    else if((mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE) || (mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE))begin
                        next_state      = DOWNSTREAM_REQ                        ;
                    end                                                    
                end
                else if(tag_miss && index_way_checkpass==1'b0 )begin
                    if((mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE) || (mshr_entry_array.req_pld.opcode == PREFETCH_OPCODE))begin
                        next_state = WAIT_DOWNSTREAM_REQ                        ;
                    end
                    else if(mshr_entry_array.req_pld.opcode == DOWNSTREAM_OPCODE)begin
                        next_state = END_STATE                                  ;   
                    end
                end
            end
            else begin
                next_state              = ALLOC                                 ;
            end
        end
        WAIT_DATARAM_RDY:begin
            if(dataram_release_en && dataram_rd_rdy)    next_state              = READ_DATA           ;
            else                  next_state              = WAIT_DATARAM_RDY    ;
        end
        WAIT_READ_REQ:begin
            if(index_way_release)begin
                if(dataram_release_en && (dataram_rd_rdy==1'b1))begin
                    next_state = READ_DATA                                      ;        
                end
                else if(dataram_release_en && (dataram_rd_rdy==1'b0))begin
                    next_state = WAIT_DATARAM_RDY                               ;    
                end
                else begin
                    next_state = WAIT_READ_REQ                                  ;    
                end
            end
            else begin
                next_state = WAIT_READ_REQ                                      ;    
            end
        end
        READ_DATA: begin
            next_state                  = IDLE                                  ;  
        end
        WAIT_DOWNSTREAM_REQ:begin
            if(index_way_release)   next_state              = DOWNSTREAM_REQ     ;
            else                    next_state              = WAIT_DOWNSTREAM_REQ;
        end
        DOWNSTREAM_REQ: begin
            if(downstream_release_en && downstream_txreq_rdy)begin
                next_state              = DOWNSTREAM_RELEASE                     ;   
            end
            else begin
                next_state              = DOWNSTREAM_REQ                         ;
            end
        end
        DOWNSTREAM_RELEASE:begin
            next_state                  = WAIT_FILL_DONE                         ;
        end
        WAIT_FILL_DONE:begin
            if(linefill_done==1'b1)begin
                next_state          = END_STATE                              ;
            end
            else begin
                next_state          = WAIT_FILL_DONE                         ;
            end
        end
        END_STATE:begin
                    next_state          = IDLE                                   ;
        end
        default:    next_state          = IDLE                                   ;
    endcase
end

assign entry_release_done = (cur_state == END_STATE);
assign done               = (cur_state == END_STATE);
assign hit_entry_done     = (cur_state == READ_DATA);
assign entry_valid        = mshr_entry_array.valid  ;


always_comb begin
    if((cur_state == ALLOC) && allocate_en && (|tag_hit==1'b1)  && (index_way_checkpass==1'b1) && (mshr_entry_array.req_pld.opcode == UPSTREAM_OPCODE)) begin
        dataram_rd_vld   = 1'b1                             ;
        dataram_rd_index = entry_data.pld.addr.index        ;
        dataram_rd_way   = entry_data.dest_way              ;
        dataram_rd_txnid = entry_data.pld.txnid             ;
    end
    else if((cur_state == WAIT_DATARAM_RDY) | ((cur_state == WAIT_READ_REQ) && (index_way_release==1'b1)))begin
        dataram_rd_vld   = 1'b1;
        dataram_rd_index = entry_data_keep.pld.addr.index   ;
        dataram_rd_way   = entry_data_keep.dest_way         ;
        dataram_rd_txnid = entry_data_keep.pld.txnid        ;
    end
    else begin
        dataram_rd_vld   = 1'b0;
        dataram_rd_index =  'b0;
        dataram_rd_way   =  'b0;
        dataram_rd_txnid =  'b0;
    end
end


always_comb begin
    downstream_txreq_vld = 1'b0;
    downstream_txreq_pld = '{default:'0};
    if(cur_state== DOWNSTREAM_REQ)begin
        downstream_txreq_vld = 1'b1;
        downstream_txreq_pld = entry_data_keep.pld;
    end
end

always_comb begin
    mshr_entry_array.valid            = 1'b0                        ;
    mshr_entry_array.req_pld          = '{default: '0}              ;
    mshr_entry_array.dest_way         = 'b0                         ;
    if(cur_state == ALLOC && allocate_en)begin
        mshr_entry_array.valid            = 1'b1                        ;
        mshr_entry_array.req_pld          = entry_data.pld              ;
        mshr_entry_array.dest_way         = entry_data.dest_way         ;
    end
    else if(cur_state ==READ_DATA | cur_state ==WAIT_DATARAM_RDY | cur_state == WAIT_READ_REQ 
            | cur_state==WAIT_DOWNSTREAM_REQ | cur_state == DOWNSTREAM_REQ | cur_state== DOWNSTREAM_RELEASE 
            | cur_state==WAIT_FILL_DONE | cur_state==END_STATE )begin
        mshr_entry_array.valid      = 1'b1                              ;
        mshr_entry_array.req_pld    = entry_data_keep.pld               ;
        mshr_entry_array.dest_way   = entry_data_keep.dest_way          ;
    end
end

always_comb begin
    if(cur_state==ALLOC)begin
        mshr_entry_array.index_way_bitmap = entry_index_way_bitmap      ;
    end
    else if(cur_state==WAIT_READ_REQ | cur_state==WAIT_DOWNSTREAM_REQ )begin
        mshr_entry_array.index_way_bitmap = entry_index_way_bitmap_keep ;
    end
    else begin
        mshr_entry_array.index_way_bitmap = 'b0;
    end
end


endmodule

        


