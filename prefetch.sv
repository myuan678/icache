module prefetch #(
    parameter 
) (
    input clk,
    input rst_n,

    //mshr
    input        miss,
    input [31:0] miss_addr,
    //input        mshr_full,  //mshr full, stop prefetch,
    //input        req_valid,  //miss req valid 
    input
    output       pref_ready,        
    //toarb
    input               arb_ready
    output logic        prefetch_req,
    output logic [31:0] prefetch_addr,
    output logic        prefetch_req_valid,
      
    
)