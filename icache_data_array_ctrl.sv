module icache_data_array_ctrl 
    import toy_pack::*;
    (
    input  logic                                        clk                                     ,
    input  logic                                        rst_n                                   ,
    input  mshr_entry_t                                 mshr_entry_array_msg[MSHR_ENTRY_NUM-1:0],

    input  logic                                        dataram_rd_vld                          ,
    output logic                                        dataram_rd_rdy                          ,
    input  logic                                        dataram_rd_way                          ,
    input  logic  [ICACHE_INDEX_WIDTH-1         :0]     dataram_rd_index                        ,
    input  logic  [ICACHE_REQ_TXNID_WIDTH-1     :0]     dataram_rd_txnid                        ,

    input  logic                                        downstream_rxdat_vld                    ,
    output logic                                        downstream_rxdat_rdy                    ,
    input  downstream_rxdat_t                           downstream_rxdat_pld                    ,  //downstream_rxdat_pld 

    output logic [MSHR_ENTRY_NUM-1              :0]     v_linefill_done                         ,
    output logic [ICACHE_UPSTREAM_DATA_WIDTH-1  :0]     upstream_txdat_data                     ,
    output logic                                        upstream_txdat_vld                      ,
    output logic [ICACHE_REQ_TXNID_WIDTH-1      :0]     upstream_txdat_txnid             
    );


    logic                                               data_array_wr_en                        ;
    logic       [ICACHE_INDEX_WIDTH             :0]     data_array_addr                         ;
    logic       [255                            :0]     data_array0_dout                        ;
    logic       [255                            :0]     data_array1_dout                        ;
    logic       [255                            :0]     data_array0_din                         ;
    logic       [255                            :0]     data_array1_din                         ;
    mshr_entry_t                                        saved_mshr_entry_array_msg[MSHR_ENTRY_NUM-1:0];
    logic       [MSHR_ENTRY_INDEX_WIDTH-1       :0]     downstream_rxdat_entry_idx              ;
    logic       [ICACHE_DATA_WIDTH-1            :0]     linefill_data                           ;
    logic       [ICACHE_REQ_TXNID_WIDTH-1       :0]     linfill_done_txnid                      ;
    logic                                               linefill_done                           ;
    logic                                               dataram_rd_vld_1d                       ;
    logic       [ICACHE_REQ_TXNID_WIDTH-1       :0]     dataram_rd_txnid_out                    ;
    logic                                               mem_en                                  ;
    logic       [MSHR_ENTRY_NUM-1               :0]     v_linefill_done_reg                     ;
    logic       [MSHR_ENTRY_INDEX_WIDTH         :0]     next_valid_index                        ;
    logic       [ICACHE_DATA_WIDTH-1            :0]     captured_linefill_data                  ; 
    logic                                               uptxdat_en                              ;   
    typedef enum logic [1:0] {
      IDLE,
      LINEFILL_OUTPUT
    } linefill_state_t;
    linefill_state_t current_state, next_state;
    
    assign uptxdat_en = downstream_rxdat_pld.downstream_rxdat_opcode == UPSTREAM_OPCODE         ;
    assign mem_en                       = dataram_rd_vld | linefill_done                        ;
    assign downstream_rxdat_entry_idx   = downstream_rxdat_pld.downstream_rxdat_entry_idx       ;
    assign dataram_rd_rdy               = (data_array_wr_en == 1'b0)                            ;
    
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            downstream_rxdat_rdy     <= 1'b0;
        end
        else if(downstream_rxdat_vld )begin
            downstream_rxdat_rdy     <= 1'b1;
        end
        else begin
            downstream_rxdat_rdy     <= 1'b0;
        end
    end

    always_comb begin
        if(downstream_rxdat_vld && downstream_rxdat_rdy )begin
            linefill_done            = 1'b1                                           ;
            data_array_wr_en         = 1'b1                                           ;
            linefill_data            = downstream_rxdat_pld.downstream_rxdat_data     ;
            linfill_done_txnid       = downstream_rxdat_pld.downstream_rxdat_txnid    ;
        end
        else begin
            linefill_done            = 1'b0                                           ;
            data_array_wr_en         = 1'b0                                           ;
            linefill_data            = 'b0                                            ; 
            linfill_done_txnid       = 'b0                                            ;
        end
    end

    always_comb begin
        v_linefill_done             = '{MSHR_ENTRY_NUM{1'b0}}                         ;
        for (integer i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
            if (i== downstream_rxdat_entry_idx && downstream_rxdat_vld)begin
                v_linefill_done[i]  = 1'b1                                            ;
            end
            else if (linefill_done == 1'b1 && mshr_entry_array_msg[i].hit_bitmap[downstream_rxdat_entry_idx] == 1'b1) begin
                v_linefill_done[i] = 1'b1                                             ;
            end else begin
                v_linefill_done[i] = 1'b0                                             ;
            end
        end
    end


//data_ram rd: hit   //1:wr; 0:rd
//data_ram wr: linefill done
//linefill done write data ram and tag ram
//if(linefill_done)begin //get linefill data, write to dataram
    always_comb begin
        if(linefill_done )begin
            data_array_addr      = {mshr_entry_array_msg[downstream_rxdat_entry_idx].req_pld.addr.index,mshr_entry_array_msg[downstream_rxdat_entry_idx].dest_way};       
            data_array0_din      = linefill_data[255:0];
            data_array1_din      = linefill_data[511:256];
        end
        else begin
            data_array_addr      = {dataram_rd_index,dataram_rd_way};
            data_array0_din      = 'b0;
            data_array1_din      = 'b0;
        end
    end
    
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            dataram_rd_vld_1d    <= 1'b0;
            dataram_rd_txnid_out <= 'b0;
        end
        else begin
            dataram_rd_vld_1d    <= dataram_rd_vld;
            dataram_rd_txnid_out <= dataram_rd_txnid;
        end
    end

    //256bit  cacheline [255:0]
    toy_mem_model_bit #(
        .ADDR_WIDTH(ICACHE_INDEX_WIDTH+1  ),
        .DATA_WIDTH(256                   )
    )u_icache_data_array0 (
        .clk        (clk                  ),
        .en         (mem_en               ),    
        .wr_en      (data_array_wr_en     ),
        .addr       (data_array_addr      ),
        .rd_data    (data_array0_dout     ),
        .wr_data    (data_array0_din      )
    );

    //256bit cacheline[511:256]
    toy_mem_model_bit #(
        .ADDR_WIDTH(ICACHE_INDEX_WIDTH+1  ),
        .DATA_WIDTH(256                   )
    ) u_icache_data_array1 (
        .clk        (clk                  ),
        .en         (mem_en               ),    
        .wr_en      (data_array_wr_en     ),
        .addr       (data_array_addr      ),
        .rd_data    (data_array1_dout     ),
        .wr_data    (data_array1_din      )
    );

    function [MSHR_ENTRY_INDEX_WIDTH:0] find_next_valid_bit;
        input [MSHR_ENTRY_NUM-1:0] vector;
        integer i;
        begin
            find_next_valid_bit = {(MSHR_ENTRY_INDEX_WIDTH+1){1'b1}}; //defult: no valid bit
            for (i = 0; i < MSHR_ENTRY_NUM; i = i + 1) begin
                if (vector[i]) begin
                    find_next_valid_bit = i;
                    break;
                end
            end
        end
    endfunction


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            current_state               <= IDLE                         ;
        end
        else begin
            current_state               <= next_state;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            //current_state               <= IDLE                         ;
            v_linefill_done_reg         <= {(MSHR_ENTRY_NUM){1'b0}}     ;
            upstream_txdat_vld          <= 1'b0                         ;
            upstream_txdat_data         <= 'b0                          ;
            upstream_txdat_txnid        <= 'b0                          ;
            captured_linefill_data      <= 'b0                          ;
            saved_mshr_entry_array_msg  <= '{default: '0}               ;
        end 
        else begin
            //current_state               <= next_state;
            case (current_state)
                IDLE: begin
                    if (linefill_done && uptxdat_en) begin
                        v_linefill_done_reg          <= v_linefill_done                 ;
                        captured_linefill_data       <= linefill_data                   ; // linefill_data
                        saved_mshr_entry_array_msg   <= mshr_entry_array_msg            ;
                    end
                    else begin
                        if (dataram_rd_rdy && dataram_rd_vld_1d) begin
                            upstream_txdat_vld       <= 1'b1                             ;
                            upstream_txdat_data      <= {data_array1_dout, data_array0_dout};
                            upstream_txdat_txnid     <= dataram_rd_txnid_out                 ;
                        end 
                        else begin
                            upstream_txdat_vld       <= 1'b0                             ;
                            upstream_txdat_data      <= 'b0                              ;
                            upstream_txdat_txnid     <= 'b0                              ;
                        end
                    end
                end
                LINEFILL_OUTPUT: begin
                    if (next_valid_index != {(MSHR_ENTRY_INDEX_WIDTH+1){1'b1}}) begin
                        upstream_txdat_vld          <= 1'b1;
                        upstream_txdat_data         <= captured_linefill_data; 
                        upstream_txdat_txnid        <= saved_mshr_entry_array_msg[next_valid_index].req_pld.txnid;
                        v_linefill_done_reg[next_valid_index] <= 1'b0; 
                    end else begin
                        upstream_txdat_vld          <= 1'b0 ;
                        upstream_txdat_data         <= 'b0  ;
                        upstream_txdat_txnid        <= 'b0  ;
                    end
                end
            endcase
        end
    end

    always_comb begin
        next_state          = current_state;
        next_valid_index    = find_next_valid_bit(v_linefill_done_reg);

        case (current_state)
            IDLE: begin
                if (linefill_done && uptxdat_en) begin
                    next_state = LINEFILL_OUTPUT;
                end 
                else if (dataram_rd_rdy && dataram_rd_vld) begin
                    next_state = IDLE;
                end
            end
            LINEFILL_OUTPUT: begin
                if (next_valid_index == {(MSHR_ENTRY_INDEX_WIDTH+1){1'b1}}) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = LINEFILL_OUTPUT;
                end
            end
        endcase
    end
endmodule
    
