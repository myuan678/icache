module rr_arbiter (clk,rstn,request_sig,grant);

//Port declaration
input clk,rstn;
input [3:0]request_sig;
output [3:0]grant;

//Internals
reg  [1:0] rotate_ptr;
reg  [3:0] shift_request;
reg  [3:0] shift_grant;
reg  [3:0] grant_comb;
reg  [3:0] grant;

//Shift request to current priority
always @(*) 
begin
    case (rotate_ptr[1:0])
     2'b00: shift_request[3:0] = request_sig[3:0];
	 2'b01: shift_request[3:0] = {request_sig[0],request_sig[3:1]};
	 2'b10: shift_request[3:0] = {request_sig[1:0],request_sig[3:2]};
	 2'b11: shift_request[3:0] = {request_sig[2:0],request_sig[3]};
	endcase
end

//Priority arbiter
always @(*)
begin
   shift_grant[3:0] = 4'b0;
	if (shift_request[0])
	   shift_grant[0] = 1'b1;
	else if (shift_request[1])
	   shift_grant[1] = 1'b1;
    else if (shift_request[2])
	   shift_grant[2] = 1'b1;
	else if (shift_request[3])
	   shift_grant[3] = 1'b1;
end

//Grant signal
always @(*)
begin
  case (rotate_ptr[1:0])
     2'b00: grant_comb[3:0] = shift_grant[3:0];
	 2'b01: grant_comb[3:0] = {shift_grant[2:0],shift_grant[3]};
	 2'b10: grant_comb[3:0] = {shift_grant[1:0],shift_grant[3:2]};
	 2'b11: grant_comb[3:0] = {shift_grant[0],shift_grant[3:1]};
	endcase
end
//logic Implementation
always@ (posedge clk or negedge rstn)
begin
 if(!rstn)
   grant[3:0] <= 4'b0;
 else
   grant[3:0] = grant_comb[3:0] & ~grant[3:0];
end

//Updating rotate_ptr
always @ (posedge clk or negedge rstn)   
begin
 if(!rstn)
   rotate_ptr[1:0] <= 0;
 else
   case (1'b1)
     grant[0]: rotate_ptr[1:0] <= 2'b01;
	 grant[1]: rotate_ptr[1:0] <= 2'b10;
	 grant[2]: rotate_ptr[1:0] <= 2'b11;
	 grant[3]: rotate_ptr[1:0] <= 2'b00;
   endcase
end
endmodule





module round_robin_arbiter #(
 parameter N = 16
)(
input         clk,
input         rst_n,
input [N-1:0] req,
output[N-1:0] grant
);

logic [N-1:0] req_masked;
logic [N-1:0] mask_higher_pri_reqs;
logic [N-1:0] grant_masked;
logic [N-1:0] unmask_higher_pri_reqs;
logic [N-1:0] grant_unmasked;
logic no_req_masked;
logic [N-1:0] pointer_reg;

// Simple priority arbitration for masked portion

assign req_masked = req & pointer_reg;
assign mask_higher_pri_reqs[N-1:1] = mask_higher_pri_reqs[N-2: 0] | req_masked[N-2:0];
assign mask_higher_pri_reqs[0] = 1'b0;
assign grant_masked[N-1:0] = req_masked[N-1:0] & ~mask_higher_pri_reqs[N-1:0];
// Simple priority arbitration for unmasked portion
assign unmask_higher_pri_reqs[N-1:1] = unmask_higher_pri_reqs[N-2:0] | req[N-2:0];
assign unmask_higher_pri_reqs[0] = 1'b0;
assign grant_unmasked[N-1:0] = req[N-1:0] & ~unmask_higher_pri_reqs[N-1:0];

// Use grant_masked if there is any there, otherwise use grant_unmasked. 
assign no_req_masked = ~(|req_masked);
assign grant = ({N{no_req_masked}} & grant_unmasked) | grant_masked;
// Pointer update
always @ (posedge clk) begin
  if (rst_n) begin
    pointer_reg <= {N{1'b1}};
  end 
  else begin
    if (|req_masked) begin // Which arbiter was used?
      pointer_reg <= mask_higher_pri_reqs;
    end 
	else begin
      if (|req) begin // Only update if there's a req 
        pointer_reg <= unmask_higher_pri_reqs;
      end 
	  else begin
        pointer_reg <= pointer_reg ;
      end
    end
  end
end
endmodule
