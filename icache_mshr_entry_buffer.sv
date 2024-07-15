module icache_mshr_entry_buffer 
    import toy_pack::*; 
    (
    input  logic                                        clk                        ,
    input  logic                                        rst_n                      ,    
    input  logic  [WAY_NUM-1:0]                         tag_hit                    , //2way
    input  logic                                        tag_miss                   ,
    input  logic                                        mshr_hit                   ,
    input  logic                                        mshr_miss                  ,
    input  mshr_entry_t                                 mshr_entry_array           ,

    output logic                                        dataram_rd_vld             ,
    input  logic                                        dataram_rd_rdy             ,
    output logic                                        dataram_rd_way             ,
    output logic [ICACHE_INDEX_WIDTH-1:0]               dataram_rd_index           ,

    output logic                                        entry_valid                ,
    input  logic                                        linefill_done              ,
    
    output logic                                        downstream_txreq_vld       ,
    input  logic                                        downstream_txreq_rdy       ,
    output logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txreq_opcode    ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1:0]           downstream_txreq_txnid     ,
    output req_addr_t                                   downstream_txreq_addr      ,

    input  logic                                        downstream_txrsp_vld       ,//TODO
    output logic                                        downstream_txrsp_rdy       ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_txrsp_opcode    ,

    output req_addr_t                                   miss_addr_for_prefetch     ,
    output logic                                        miss_for_prefetch          

    //input  logic                                        mshr_full                  ,
    //output logic                                        miss_for_prefetch          ,
    //output logic                                        mshr_miss                  ,
    //output logic [ICACHE_TAG_REQ_ADDR_WIDTH-1:0]        miss_addr_for_prefetch     ,
    //output logic                                        entry_idle                 ,
    //input  logic                                        linefill_addr              ,
    //input  logic                                        linefill_done_idx          , 

);

assign downstream_rdy = 1'b1;
// FSM state
typedef enum logic [2:0] {
    IDLE                        ,
    COMP                        ,
    READ_DATA                   ,
    DOWNSTREAM_REQ              ,
    DOWNSTREAM_REQ_WAIT_FILL    ,
    WAIT_FILL_DONE      
} state_t;

state_t cur_state, next_state;


//assign downstream_rep_way = lru_pick_way                            ;
//assign entry_valid = mshr_entry_array.valid                         ;
// FSM
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state <= IDLE                                           ;
    end                                 
    else begin                              
        cur_state <= next_state                                     ;
    end
end
always_comb begin
    next_state           = cur_state                                ;
    //downstream_txreq_vld = 1'b0                                     ;
    //dataram_rd_vld       = 1'b0                                     ;
    //stall                = 1'b0                                     ;
    //mshr_entry_array     = 53'b0                                    ;
    case (cur_state)
        IDLE: begin
            if (mshr_entry_array.valid==1'b1)     next_state = COMP ;
            else                 next_state = IDLE                  ;                          
        end
        COMP: begin           
            if (|tag_hit && mshr_miss) begin
                if(mshr_entry_array.req_opcode == UPSTREAM_OPCODE)begin
                    next_state              = READ_DATA             ;
                end
                else if(mshr_entry_array.req_opcode == DOWNSTREAM_OPCODE)begin
                    next_state              = IDLE                  ;
                    entry_valid             = 1'b0                  ;
                end
                else if(mshr_entry_array.req_opcode == PREFETCH_OPCODE)begin
                    next_state              = IDLE                  ;
                    entry_valid             = 1'b0                  ;
                end
            end
            else if (|tag_hit && mshr_hit ) begin
                if(mshr_entry_array.req_opcode == UPSTREAM_OPCODE)begin
                    next_state              = DOWNSTREAM_REQ_WAIT_FILL;                    
                end
                else if(mshr_entry_array.req_opcode == DOWNSTREAM_OPCODE)begin
                    next_state              = IDLE                  ;
                    entry_valid             = 1'b0                  ;
                end
                else if (mshr_entry_array.req_opcode == PREFETCH_OPCODE)begin
                    next_state              = DOWNSTREAM_REQ_WAIT_FILL;
                end
            end
            else if (tag_miss && mshr_miss)begin
                if(mshr_entry_array.req_opcode == UPSTREAM_OPCODE)begin
                    next_state              = DOWNSTREAM_REQ        ;                    
                end
                else if(mshr_entry_array.req_opcode == DOWNSTREAM_OPCODE)begin
                    next_state              = IDLE                  ;
                    entry_valid             = 1'b0                  ;
                end
                else if (mshr_entry_array.req_opcode == PREFETCH_OPCODE)begin
                    next_state              = DOWNSTREAM_REQ        ;
                end
            end
            else begin
                next_state                  = IDLE                  ;
            end
        end
        READ_DATA: begin
            dataram_rd_vld   = 1'b1                                 ;
            dataram_rd_index = mshr_entry_array.req_addr.index      ;
            dataram_rd_way   = tag_hit[0] ? 1'b0 : 1'b1             ;
            if (dataram_rd_vld && dataram_rd_rdy) begin         
                next_state              = IDLE                      ;
                entry_valid             = 1'b0                      ;
                dataram_rd_vld          = 1'b0                      ;
            end         
            else begin          
                next_state              = READ_DATA                 ;
                entry_valid             = 1'b0                      ;
                dataram_rd_vld          = dataram_rd_vld            ;
            end
        end
        DOWNSTREAM_REQ: begin
            miss_addr_for_prefetch      = mshr_entry_array.req_addr ;
            miss_for_prefetch           = 1'b1                      ;

            downstream_txreq_vld        = 1'b1                      ;
            downstream_txreq_addr       = mshr_entry_array.req_addr ;
            downstream_txreq_txnid      = mshr_entry_array.req_txnid;
            //downstream_txreq_entry      = mshr_entry_array.entry_id ; 
            if (downstream_txreq_vld && downstream_txreq_rdy) begin  
                downstream_txreq_vld    = 1'b0                      ;
                next_state              = WAIT_FILL_DONE            ;
            end
            else begin
                //linefill_en 
                downstream_txreq_vld = downstream_txreq_vld         ;
                next_state = DOWNSTREAM_REQ                         ;   
            end
        end
        DOWNSTREAM_REQ_WAIT_FILL: begin
            next_state = WAIT_FILL_DONE                             ;
        end
        WAIT_FILL_DONE:begin
            if(linefill_done)begin
                next_state = IDLE                                   ;
            end
            else begin
                next_state = WAIT_FILL_DONE                         ;
            end
        end
        //WAIT_FILL_DONE: begin
        //    if (linefill_done) begin
        //        next_state = RELEASE_ENTRY;
        //    end
        //    else begin
        //        netx_state= WAIT_FILL_DONE;
        //    end
        //end
        //RELEASE_ENTRY:begin
        //    mshr_entry_array.valid = 1'b0;
        //    mshr_entry_array_msg <= mshr_entry ;
        //    entry_idle = 1'b1;
        //    next_state = IDLE;
        //end
        default: next_state = IDLE;
    endcase
end



endmodule
