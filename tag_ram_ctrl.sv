module tag_ram_ctrl(
    parameter 
)(
    input  clk,
    input rst_n,
    input i_req_addr,
    input i_req,
    //input update_lru_en,
    input wr_data,
    input mshraddr_in,
    input mshr_data_in,
    input bus_mshr_ack,

    output way0_hit,
    output way1_hit,
    output hit,
    output miss
    output tag_valid,
    output hit_addr_out,
    output mshr_linefill_en,
    output stall,
    output lru,
    output mshr_bus_req,
    output mshr_bus_addr,
);
    logic    [31:0]           i_req_addr,
    logic                     i_req,
    logic                     req_valid,
    logic                     wr_en,
    logic    [31:0]           wr_tag_data,
    logic    [31:0]           tag_addr_to_dataram,  
    logic                     i_hit,
    logic                     i_miss,
            //to l2mem   
    logic                     i_mem_req,
    logic    [31:0]           i_mem_addr,
    logic    [31:0]           i_mem_wdata,
    logic                     i_hit,
    logic                     i_miss,


endmodule