module icache_data_array_ctrl 
    import toy_pack::*;
    (
    input  logic                                        clk                       ,
    input  logic                                        rst_n                     ,
    input  mshr_entry_t                                 mshr_entry_array_msg[MSHR_ENTRY_NUM-1:0],
    
    //dataram rd
    input  logic                                        dataram_rd_vld            ,
    output logic                                        dataram_rd_rdy            ,
    input  logic                                        dataram_rd_way            ,
    input  logic  [ICACHE_INDEX_WIDTH-1:0]              dataram_rd_index          ,

    //downstream writeback data
    input  logic                                        downstream_rxdat_vld      ,
    output logic                                        downstream_rxdat_rdy      ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]          downstream_rxdat_opcode   ,
    input  logic [ICACHE_REQ_TXNID_WIDTH-1:0]           downstream_rxdat_txnid    ,
    input  logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           downstream_rxdat_entry_idx,  // downstream_txreq_index
    input  logic [ICACHE_DOWNSTREAM_DATA_WIDTH-1:0]     downstream_rxdat_data     ,

    output logic                                        linefill_done             ,
    output logic [MSHR_ENTRY_INDEX_WIDTH-1:0]           linefill_ack_mshr_index   ,

    //data out to requester
    output logic [ICACHE_UPSTREAM_DATA_WIDTH-1:0]       upstream_txdat_data       ,
    output logic                                        upstream_txdat_en             
);

logic                         data_array_wr_en  ;
logic [ICACHE_INDEX_WIDTH:0]  data_array_addr   ;
logic [255:0]                 data_array0_dout  ;
logic [255:0]                 data_array1_dout  ;
logic [255:0]                 data_array0_din   ;
logic [255:0]                 data_array1_din   ;


assign downstream_rxdat_rdy   = (data_array_wr_en == 1'b1);
assign dataram_rd_rdy         = (data_array_wr_en == 1'b0);


//linefill data

logic [ICACHE_DATA_WIDTH-1:0] linefill_data ;

always_comb begin
    if(downstream_rxdat_vld && downstream_rxdat_rdy)begin
        linefill_done            = 1'b1                      ;
        linefill_data            = downstream_rxdat_data     ;
        linefill_ack_mshr_index  = downstream_rxdat_entry_idx;
    end
    else begin
        linefill_done            = 1'b0                      ;
        linefill_data            = linefill_data             ;
        linefill_ack_mshr_index  = linefill_ack_mshr_index   ;
    end
end


//data_ram rd: hit   //1:wr; 0:rd
//data_ram wr: linefill done
//linefill done write data ram and tag ram


always_comb begin
    if(linefill_done)begin //get linefill data, write to dataram
        data_array_wr_en    = 1'b1;
        data_array_addr     = {mshr_entry_array_msg[downstream_rxdat_entry_idx].req_addr.index,mshr_entry_array_msg[downstream_rxdat_entry_idx].downstream_rep_way};       
        data_array0_din     = linefill_data[255:0];
        data_array1_din     = linefill_data[511:256];
    end
    else begin
        data_array_wr_en        = 1'b0;
        data_array_addr         = 'b0;
        data_array0_din         = 'b0;
        data_array1_din         = 'b0;
    end
end


//
//256bit  cacheline [255:0]
toy_mem_model_bit u_icache_data_array0 (
    .clk        (clk                  ),
    .en         (1'b1                 ),    
    .wr_en      (data_array_wr_en     ),
    .addr       (data_array_addr      ),
    .rd_data    (data_array0_dout     ),
    .wr_data    (data_array0_din      )
);

//256bit cacheline[511:256]
toy_mem_model_bit u_icache_data_array1 (
    .clk        (clk                  ),
    .en         (1'b1                 ),    
    .wr_en      (data_array_wr_en     ),
    .addr       (data_array_addr      ),
    .rd_data    (data_array1_dout     ),
    .wr_data    (data_array1_din      )
);


always_comb begin
    if(linefill_done == 1'b1 )begin
        upstream_txdat_en       = 1'b1                        ;
        upstream_txdat_data     = linefill_data               ;
    end
    else if(dataram_rd_rdy && dataram_rd_vld)begin
        upstream_txdat_en   = 1'b1                            ;
        upstream_txdat_data = {data_array1_dout,data_array0_dout}          ;
    end
    else begin
        upstream_txdat_en   = 1'b0                            ;
        upstream_txdat_data = 'b0                             ;
    end   
end




endmodule