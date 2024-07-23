
package toy_pack;

    //localparam integer unsigned ADDR_WIDTH                   = 32;
    localparam integer unsigned ICACHE_TAG_WIDTH             = 19;
    localparam integer unsigned ICACHE_INDEX_WIDTH           = 7 ;
    localparam integer unsigned ICACHE_OFFSET_WIDTH          = 6 ;
    localparam integer unsigned ICACHE_REQ_OPCODE_WIDTH      = 5 ;
    localparam integer unsigned ICACHE_REQ_TXNID_WIDTH       = 5 ;
    localparam integer unsigned WAY_NUM                      = 2 ;
    localparam integer unsigned ADDR_WIDTH = ICACHE_TAG_WIDTH + ICACHE_INDEX_WIDTH + ICACHE_OFFSET_WIDTH;

    
    localparam integer unsigned MSHR_ENTRY_NUM               = 8      ;
    localparam integer unsigned MSHR_ENTRY_INDEX_WIDTH       = $clog2(MSHR_ENTRY_NUM);
    localparam integer unsigned ICACHE_UPSTREAM_DATA_WIDTH   = 512    ;
    localparam integer unsigned ICACHE_DOWNSTREAM_DATA_WIDTH = 512    ;
    localparam integer unsigned DOWNSTREAM_OPCODE            = 5'd1   ;
    localparam integer unsigned UPSTREAM_OPCODE              = 5'd2   ;    
    localparam integer unsigned PREFETCH_OPCODE              = 5'd2   ;    
    localparam integer unsigned ICACHE_DATA_WIDTH            = 512    ;  //cache size 512bit
    localparam integer unsigned ICACHE_TAG_RAM_WIDTH         = ICACHE_TAG_WIDTH*WAY_NUM + 2;

    typedef enum logic [2:0] {
    IDLE                        ,
    COMP                        ,
    READ_DATA                   ,
    DOWNSTREAM_REQ              ,
    DOWNSTREAM_REQ_WAIT_FILL    ,
    WAIT_FILL_DONE      
    } state_t;

    typedef struct packed{
      logic [ICACHE_TAG_WIDTH-1            :0]           tag                        ;
      logic [ICACHE_INDEX_WIDTH-1          :0]           index                      ;
      logic [ICACHE_OFFSET_WIDTH-1         :0]           offset                     ;
      } req_addr_t;

    typedef struct {
      logic [ICACHE_REQ_OPCODE_WIDTH-1     :0]           opcode                     ;
      logic [ICACHE_REQ_TXNID_WIDTH-1      :0]           txnid                      ;
      req_addr_t                                         addr                       ;
    } pc_req_t;


    typedef struct {
      logic [ICACHE_REQ_OPCODE_WIDTH-1     :0]           downstream_txreq_opcode    ;
      logic [ICACHE_REQ_TXNID_WIDTH-1      :0]           downstream_txreq_txnid     ;
      req_addr_t                                         downstream_txreq_addr      ;
      } downstream_txreq_t;

    typedef struct {
      logic [ICACHE_REQ_OPCODE_WIDTH-1     :0]           downstream_rxdat_opcode    ;
      logic [ICACHE_REQ_TXNID_WIDTH-1      :0]           downstream_rxdat_txnid     ;
      logic [ICACHE_DOWNSTREAM_DATA_WIDTH-1:0]           downstream_rxdat_data      ;
      logic [ICACHE_INDEX_WIDTH-1          :0]           downstream_rxdat_entry_idx ;
    } downstream_rxdat_t;

    typedef struct {
        logic                                            valid                      ;
        pc_req_t                                         req_pld                    ; 
        logic                                            downstream_rep_way         ;
        logic [MSHR_ENTRY_NUM-1             :0]          hit_bitmap                 ;
    } mshr_entry_t;

endpackage