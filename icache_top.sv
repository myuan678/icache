module icache_top #(
    parameter integer unsigned ICACHE_SIZE = 32,//kB
    parameter integer unsigned ICACHE_LINE_SIZE = 64,//B
    parameter integer unsigned ICACHE_WAYS = 2,
)(
    input                     clk               ,
    input                     rst_n             ,

    input                     cpu_i_req         ,
    input    [31:0]           cpu_i_req_addr    ,
    input                     invalid_icache    ,
    input                     req_valid         ,    // valids for three req?
    output logic              rd_data           ,    //cpu req data
    output logic              rd_data_valid     ,
    output logic              i_stall           ,
    output logic              miss              , //?

    //downtream
    input                     l2mem_data_in     ,
    input                     bus_ack           ,
    output logic              bus_req           ,
    output logic    [31:0]    bus_addr          ,
  

);
logic   [17:0] tag;
logic   [7:0] index;
logic   [5:0] offset;
assign {tag,index,offset} = cpu_i_req_addr;
assign v_tag = {valid, tag}

req_arbiter u_req_arbiter(
    .clk         (clk            ),
    .rst_n       (rst_n          ),
    .invalidate  (invalid_icache ),
    .cpu_reg     (cpu_i_req      ),
    .prefetch_req(prefetch_req   ),
    .valid       (valid          ),
    .ready       (ready          ),
    .stall       (stall          ),
    .
);




tag_ctrl  u_tag_ctrl(
    .clk            (clk),//in
    .rst_n          (rst_n  ),//in
    .i_req          (       ),//in
    .i_req_addr     (       ),//in
    .wr_en          (       ),   //in
    //.wr_tag_data    (       ), // input index and tag?
    .hit_addr_out   (       ), //out  tag_addr_todataram
    .wr_data        (       ),//in update tagdata and valid bit
    .mshraddr_in    (       ),//in  
    .mshr_data_in   (       )//=in_req_addr??
    //.mshr_linefill_req(      ),//out
    .stall          (       ),//out
    .lru            (lru_bit),//out
    .way0_hit       (       ),//
    .way1_hit       (       ),//
    .hit            (       ),//out
    .miss           (       ),//out
    .mshr_data      (       ),//out
    .mshr_bus_req   (       ),//out
    .mshr_bus_addr  (       ),//out
    .bus_mshr_ack   (       )//in
)

prefetch_engine u_prefetch_engine(
    .clk            (clk        ),
    .rst_n          (rst_n      ),
    .miss           (miss       ),
    .addr_in        (miss_addr  ),
    .prefetch_en    (prefetch_en),
    .prefetch_addr  (prefetch_addr), //no need stall
    .
);

data_ram_ctrl u_data_ram_ctrl(
    .clk        (clk            ), 
    .rst_n      (rst_n          ),
    .addr_hit   (addr           ),
    .wr_en      (               ),
    .
    .addr_linefill(mshr_data    ), //mshr to linefill
    .data_in    (linefill_data  ),
    .data_out   (req_data_out   ),
    .
);

//linefill_ctrl?
linefill_ctrl u_linefill_ctrl(
    .clk                (clk                ), 
    .rst_n              (rst_n              ),
    .linefill_en        (mshr_linefill_en   ),
    .linefill_done      (linefill_done      ),
    .linefill_data_in   (l2mem_data_in      ),
    .linefill_addr_in   (mshr_data          ),
    .linefill_data_out  (data_ram_in_data   ),
    .
);

//tag_ram: valid bit, taginfo, index:8bit; offset:6bit;  tag:18bit; valid: 1bit;
spram_256x19 u_tag_ram(
    .clk        (clk    ),
    .rst_n      (rst_n  ),
    .cs         (       ),
    .wen        (       ),
    .addr       (       ),
    .din        (       ),
    .dout       (       ),
);

//spram_256x512
spram_256x128 u_data_ram_bank0(

);
spram_256x128 u_data_ram_bank1(

);
spram_256x128 u_data_ram_bank2(

);
spram_256x128 u_data_ram_bank3(

);



endmodule