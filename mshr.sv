module mshr #(
    parameter
) (
    input clk,
    input rst_n,
    input i_req,
    input i_req_addr,

    output mshr_hit,
    output mshr_miss,
    output logic stall,

    //data_ram
    output 
    
    //l2
    output logic mshr_addr,
    output logic tag_data,  //to_data_ram
    output logic req_bus,
    input        bus_ack, 

    //linefill
    output logic linfefill_req,   
    output logic linefill_addr,
    output logic valid,
    input       linefill_done,   //linefill_done to delete mshr entry?

    //prefetch
    output logic miss,
    output logic miss_addr,
    //output mshr_full,
    output  

    //behavior
    output logic mshr_hit,
    output logic mshr_miss,
    //input  addr,
    input  
    output 
    input  

);





endmodule