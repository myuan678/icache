module rq_arbiter_v4 #(
    parameter REQ_NUM= 4,
    parameter PLD_TYPE = logic 
) (
    input    logic                        clk                        ,
    input    logic                        rst_n                      ,

    input    logic                        a_req_vld [REQ_NUM-1:0]    ,
    output   logic                        a_req_rdy [REQ_NUM-1:0]    ,
    input    PLD_TYPE                     a_req_pld [REQ_NUM-1:0]    ,

    input    logic                        out_req_rdy                , 
    output   logic                        out_req_vld                ,
    output   PLD_TYPE                     out_req_pld   
)


    logic [REQ_NUM-1:0]                   select_onehot              ;
    PLD_TYPE                              select_pld                 ;

genvar i;
generate 
    for(i=0;i<REQ_NUM;i=i+1)begin:select_req
        assign select_onehot[i] = (a_req_vld[i] && out_req_rdy)  ;
    end
endgenerate

cmn_real_mux_onehot #(
    .WIDTH          (REQ_NUM      ),
    .PLD_TYPE       (PLD_TYPE     )
) u_onehot_mux(
    .select_onehot  (select_onthot),
    .v_pld          (a_req_vld    ),
    .select_pld     (select_pld   )
);

assign out_req_vld  = |a_req_vld;
assign out_req_pld  = select_pld;
assign a_req_rdy    = select_onehot;




endmodule






module fix_priority_arb #(
    parameter integer unsigned WIDTH = 4,
    parameter type PLD_TYPE = logic ,
    parameter integer unsigned PLD_WIDTH = 32
    //parameter type PLD_TYPE  = logic [PLD_WIDTH-1:0]
    //parameter type PLD_TYPE  = logic
)(
    input  [WIDTH-1:0]       v_vld_s,
    output [WIDTH-1:0]       v_rdy_s,
    input  PLD_TYPE          v_pld_s [WIDTH-1:0],
    
    output                   vld_m,
    input                    rdy_m,
    output  PLD_TYPE         pld_m
);

    logic [WIDTH-1:0] select_onehot;
    logic [WIDTH-1:0] v_rdy_s_reg;

   

    generate 
        for(genvar i=0;i<WIDTH;i=i+1)begin:select_req
            assign select_onehot[i] = (v_vld_s[i] && rdy_m)  ;
        end
    endgenerate

    cmn_real_mux_onehot #(
        .WIDTH        (WIDTH        ),   
        .PLD_WIDTH    ($bits(PLD_TYPE)    ),
        .PLD_TYPE     (PLD_TYPE )    
    ) mux_inst (
        .select_onehot(select_onehot),
        .v_pld        (v_pld_s      ),
        .select_pld   (pld_m        )
    );

    //assign v_rdy_s = v_rdy_s_reg;
    //assign vld_m = |select_onehot;



////
    assign v_rdy_s = select_onehot;
    assign vld_m = |v_vld_s;

endmodule
