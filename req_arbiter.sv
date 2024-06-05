module arbiter #(
    parameter int unsigned NUM_REQS = 3,
) (
    input                           clk,
    input                           rst_n,
    input           [NUM_REQS-1:0]  req,
    output logic    [NUM_REQS-1:0]  gnt_out,
    output logic    [NUM_REQS-1:0]  grants,
    output logic    [NUM_REQS-1:0]  gnt_valid

    output logic                    arb_ready,
    input           [NUM_REQS-1:0]  req_valid,
);

logic [NUM_REQS-1:0] cur_state;
logic [NUM_REQS-1:0] next_state;

always_comb begin
generate 
    if(SIM)begin
        assign grants = reqs & ~(reqs - 1'b1);
    end
    else if(COMP)begin
        assign pre_reqs[NUM_REQS-1:0] = reqs[NUM_REQS-2:0] & pre_reqs[NUM_REQS-2:0];
        assign grants = reqs & ~pre_reqs;
    end
    else begin
        assign pre_reqs[0] = 1'b0;
        assign grants[0] = reqs[0];
        genvar i;
        for(i=1; i<NUM_REQS; i=i+1) begin
            assign pre_reqs[i] = |reqs[i-1:0];
            assign grants[i] = reqs[i] & ~pre_reqs[i];
        end
    end
endgenerate

endmodule

    (input clk,
    input rst_n,

    input cpu_req,
    input cpu_req_valid,
    output logic ready_1,

    input invalidate_icache,
    input invalidate_valid,
    output logic ready_2,

    input prefetch_req,
    input prefetch_req_valid,
    output logic ready_3,

    output logic [2:0]grants,
    output logic grants_valid,
    input        arb_ready
);






/////
always @ (posedge clk or posedge reset) begin
    if (reset) begin
        priority <= 4'b0;
        grant <= 4'b0;
        grant_valid <= 1'b0;
    end else begin
        for (i = 0; i < 4; i = i + 1) begin
            if (request[i] && (~grant[i])) begin
                priority <= i;
            end
        end
        grant <= 4'b0;
        grant[priority] <= 1;
        
        if (grant_ready[priority]) begin
            grant_valid <= 1'b1;
        end else begin
            grant_valid <= 1'b0;
        end
    end
end




logic  grant_1 = ~io_in_0_valid; 
  assign io_in_0_ready = io_out_ready; 
  assign io_in_1_ready = grant_1 & io_out_ready; 
  assign io_out_valid = ~grant_1 | io_in_1_valid; 
  assign io_out_bits = io_in_0_valid ? io_in_0_bits : io_in_1_bits; 
  assign io_chosen = io_in_0_valid ? 1'h0 : 1'h1; 
endmodule


