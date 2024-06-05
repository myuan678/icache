module fix_priority_arb #(
    parameter N = 4
)(
    input clk,
    input rst_n,
    input logic [N-1:0] req,
    output logic [N-1:0] grant,
    output logic [N-1:0] grant_valid
)

logic [N-1:0] pre_req;

assign pre_req[0] = 1'b0; 
assign preq_req[REQ_WIDTH-1:1] = req[REQ_WIDTH-2:0] | pre_req[REQ_WIDTH-2:0];
assign gnt = req & ~pre_req;

endmodule
//assign gnt = req & (~(req-1));