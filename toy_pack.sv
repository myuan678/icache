
package toy_pack;

    localparam integer unsigned ADDR_WIDTH                   = 32;
    localparam integer unsigned ICACHE_TAG_WIDTH             = 20;
    localparam integer unsigned ICACHE_INDEX_WIDTH           = 7;
    localparam integer unsigned ICACHE_OFFSET_WIDTH          = 6;
    localparam integer unsigned ICACHE_REQ_OPCODE_WIDTH      = 5;
    localparam integer unsigned ICACHE_REQ_TXNID_WIDTH       = 5;
    localparam integer unsigned WAY_NUM                      = 2;

    
    localparam integer unsigned MSHR_ENTRY_NUM               = 8;
    localparam integer unsigned MSHR_ENTRY_INDEX_WIDTH       = $clog2(MSHR_ENTRY_NUM);
    localparam integer unsigned ICACHE_UPSTREAM_DATA_WIDTH   = 512;
    localparam integer unsigned ICACHE_DOWNSTREAM_DATA_WIDTH = 512;
    localparam integer unsigned DOWNSTREAM_OPCODE            = 7'd1;
    localparam integer unsigned UPSTREAM_OPCODE              = 7'd2;    
    localparam integer unsigned PREFETCH_OPCODE              = 7'd2;    
    localparam integer unsigned ICACHE_DATA_WIDTH            = 512;  //cache size 512bit
    localparam integer unsigned ICACHE_TAG_RAM_WIDTH         = ICACHE_TAG_WIDTH*WAY_NUM + 2;

    typedef struct packed{
      logic [ICACHE_TAG_WIDTH-1:0]          tag                 ;
      logic [ICACHE_INDEX_WIDTH-1:0]        index               ;
      logic [ICACHE_OFFSET_WIDTH-1:0]       offset              ;
    } req_addr_t;


    typedef struct {
        logic                               valid               ;
        req_addr_t                          req_addr            ;
        logic [ICACHE_REQ_TXNID_WIDTH-1:0]  req_txnid           ;
        logic [ICACHE_REQ_OPCODE_WIDTH-1:0] req_opcode          ;
        logic                               downstream_rep_way  ;
        logic [MSHR_ENTRY_NUM-1:0]          hit_bitmap          ;
    } mshr_entry_t;

endpackage