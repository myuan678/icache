module icache_req_arbiter (
    parameter integer unsigned NUM_REQS                         = 3                ,
    parameter integer unsigned ICACHE_UPSTREAM_ADDR_WIDTH       = 32               ,
    parameter integer unsigned ICACHE_DOWNSTREAM_ADDR_WIDTH     = 32               ,
    parameter integer unsigned ICACHE_DOWNSTREAM_TXNID_WIDTH    = 4                ,
    parameter integer unsigned ICACHE_REQ_OPCODE_WIDTH          = 7                ,
    parameter integer unsigned ICACHE_TAGREQ_ADDR_WIDTH         =32                 ,
    parameter integer unsigned ICACHE_TAGREQ_TXNID_WIDTH        = 4         
)(
    input  logic                                            clk                    ,             
    input  logic                                            rst_n                  ,
    input  logic                                            upstream_rxreq_vld     ,
    output logic                                            upstream_rxreq_rdy     ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              upstream_rxreq_opcode  ,
    input  logic [ICACHE_DOWNSTREAM_TXNID_WIDTH-1:0]        upstream_rxreq_txnid   ,
    input  logic [ICACHE_UPSTREAM_ADDR_WIDTH-1:0]           upstream_rxreq_addr    ,

    input  logic                                            downstream_rxsnp_vld   ,
    output logic                                            downstream_rxsnp_rdy   ,
    input  logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              downstream_rxsnp_opcode,
    input  logic [ICACHE_DOWNSTREAM_TXNID_WIDTH-1:0]        downstream_rxsnp_txnid ,
    input  logic [ICACHE_DOWNSTREAM_ADDR_WIDTH-1:0]         downstream_rxsnp_addr  ,

    input  logic                                            prefetch_req_vld       ,
    output logic                                            prefetch_req_rdy       ,
    input  logic  [ICACHE_DOWNSTREAM_ADDR_WIDTH-1:0]        prefetch_req_addr      ,

    output logic                                            tag_req_vld            ,
    input  logic                                            tag_req_rdy            ,
    output logic [ICACHE_REQ_OPCODE_WIDTH-1:0]              tag_req_opcode         ,
    output logic [ICACHE_TAGREQ_TXNID_WIDTH-1:0]            tag_req_txnid          ,
    output logic [ICACHE_TAGREQ_ADDR_WIDTH-1:0]             tag_req_addr           
);
    logic [1:0] selected_req;

    // States 
    localparam IDLE = 2'b00;
    localparam REQ1 = 2'b01;
    localparam REQ2 = 2'b10;
    localparam REQ3 = 2'b11;


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            selected_req <= IDLE;
        end else begin
            if (upstream_rxreq_vld) begin
                selected_req <= REQ1;
            end else if (downstream_rxsnp_vld) begin
                selected_req <= REQ2;
            end else if (prefetch_req_vld) begin
                selected_req <= REQ3;
            end else begin
                selected_req <= IDLE;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            upstream_rxreq_rdy              <= 1'b0;
            downstream_rxsnp_rdy            <= 1'b0;
            prefetch_req_rdy                <= 1'b0;
            tag_req_vld                     <= 1'b0;
            tag_req_add                     <= 32'b0;
        end else begin
            case (selected_req)
                REQ1: begin
                    upstream_rxreq_rdy      <= tag_req_ready ;
                    downstream_rxsnp_rdy    <= 1'b0;
                    prefetch_req_rdy        <= 1'b0;
                    tag_req_valid           <= upstream_rxreq_vld && tag_re_rdy;
                    tag_req_addr            <= upstream_rxreq_addr;
                end
                REQ2: begin
                    upstream_rxreq_rdy      <= 1'b0;
                    downstream_rxsnp_rdy    <= tag_req_rdy;
                    prefetch_req_rdy        <= 1'b0;
                    tag_req_valid           <= downstream_rxsnp_vld && tag_req_ready;
                    tag_req_addr            <= downstream_rxsnp_addr;
                end
                REQ3: begin
                    upstream_rxreq_rdy      <= 1'b0;
                    downstream_rxsnp_rdy    <= 1'b0;
                    prefetch_req_rdy        <= out_ready;
                    tag_req_valid           <= prefetch_req_vld && tag_req_rdy;
                    tag_req_addr            <= prefetch_req_addr;
                end
                default: begin
                    upstream_rxreq_rdy      <= 1'b0;
                    downstream_rxsnp_rdy    <= 1'b0;
                    prefetch_req_rdy        <= 1'b0;
                    tag_req_valid           <= 1'b0;
                    tag_req_addr            <= 32'b0;
                end
            endcase
        end
    end

endmodule
