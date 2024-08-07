//module pre_allocate 
//    import toy_pack::*;
//    #(
//    parameter ENTRY_NUM = 8, 
//    parameter INDEX_WIDTH = $clog2(ENTRY_NUM) 
//)(
//    input  logic                        clk                 ,
//    input  logic                        rst_n               ,
//    input  logic                        allocate_entry_en   ,
//    input  logic  [ENTRY_NUM-1  :0]     vld                 , 
//    output logic  [INDEX_WIDTH-1:0]     taken_index         , 
//    output logic                        taken_vld    
//);
//
//    logic                               fifo_empty          ;
//    logic                               fifo_full           ;
//    logic [INDEX_WIDTH-1    :0]         fifo_rd_data        ;
//    logic                               fifo_wr_en          ;
//    logic                               fifo_rd_en          ;
//    logic [INDEX_WIDTH-1    :0]         fifo_wr_data        ;
//    logic [ENTRY_NUM-1      :0]         prev_vld            ;
//    integer i;
//
//    sync_fifo #(
//        .FIFO_WIDTH     (INDEX_WIDTH+1  ),
//        .FIFO_DEPTH     (ENTRY_NUM      ), 
//        .FIFO_DEPTH_BIT (INDEX_WIDTH    )
//    ) u_sync_fifo (
//        .clk            (clk            ),
//        .rst_n          (rst_n          ),
//        .w_en           (fifo_wr_en     ),
//        .data_write     (fifo_wr_data   ),
//        .r_en           (fifo_rd_en     ),
//        .data_read      (fifo_rd_data   ),
//        .flag_empty     (fifo_empty     ),
//        .flag_full      (fifo_full      )
//    );
//
//
//    logic [INDEX_WIDTH-1:0] index;
//    logic [INDEX_WIDTH-1:0] current_index;
//    logic [ENTRY_NUM-1:0]   vld_reg;
//    always @(posedge clk or negedge rst_n) begin
//        if (~rst_n) begin
//            current_index <= 0;
//            vld_reg     <= 'b0;
//        end
//        else begin
//            current_index   <= (current_index==(ENTRY_NUM-1)) ? 0 : (current_index+1);
//            vld_reg         <= vld;
//        end
//    end
//
//    always_ff@(posedge clk or negedge rst_n)begin
//        if(!rst_n)begin
//            fifo_wr_en <= 1'b0;
//            fifo_wr_data <= 'b0;
//        end
//        else begin
//            if((vld_reg[current_index]==1'b1)  && !fifo_full)begin
//                fifo_wr_en <= 1;
//                fifo_wr_data <= current_index;
//            end
//            else begin
//                fifo_wr_en <= 1'b0;
//                fifo_wr_data <= 'b0;
//            end
//        end
//    end
//    //////////////////////////////////////////////////////////////////////////////////////////////
//    //always_ff@(posedge clk or negedge rst_n)begin
//    //    if(!rst_n)begin
//    //        fifo_wr_en <= 1'b0;
//    //        fifo_wr_data <= 'b0;
//    //    end
//    //    else begin
//    //        if((vld_reg[current_index]==1'b1)  && fifo_empty)begin
//    //            fifo_wr_en <= 1;
//    //            fifo_wr_data <= current_index;
//    //        end
//    //        else if((vld_reg[current_index]==1'b0) && (vld[current_index]==1'b1)  && !fifo_full )begin
//    //            fifo_wr_en <= 1'b1;
//    //            fifo_wr_data <= current_index;
//    //        end
//    //        else begin
//    //            fifo_wr_en <= 1'b0;
//    //            fifo_wr_data <= 'b0;
//    //        end
//    //    end
//    //end
//    /////////////////////////////////////////////////////////////////////////////////////////////
//
//
//    always_comb begin
//        if(allocate_entry_en && !fifo_empty)begin
//            fifo_rd_en = 1;
//        end
//        else begin
//            fifo_rd_en = 0;
//        end
//    end
//
//    // Output first available entry
//    always_ff@(posedge clk or negedge rst_n) begin
//        if(!rst_n)begin
//            taken_vld <= 1'b0            ;
//        end
//        else if (allocate_entry_en && !fifo_empty) begin
//            taken_vld <= 1'b1            ;
//        end 
//        else begin
//            taken_vld <= 1'b0            ;
//        end
//    end
//    assign taken_index = fifo_rd_data    ;
//    
//endmodule












module pre_allocate 
    import toy_pack::*;
    #(
    parameter ENTRY_NUM = 8, 
    parameter INDEX_WIDTH = $clog2(ENTRY_NUM) 
)(
    input  logic                        clk                 ,
    input  logic                        rst_n               ,
    input  logic                        allocate_entry_en   ,
    input  logic  [ENTRY_NUM-1  :0]     vld                 , 
    output logic  [INDEX_WIDTH-1:0]     taken_index         , 
    output logic                        taken_vld    
);


    logic [ENTRY_NUM-1  :0] selected_chn;
    logic [ENTRY_NUM-1  :0] vld_reg ;

    always_ff@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            vld_reg <= 'b0;
        end
        else if(allocate_entry_en)begin
            vld_reg <= vld;
        end
        else begin
            vld_reg <= 'b0;
        end
    end

    cmn_lead_one #(
        .ENTRY_NUM      (MSHR_ENTRY_NUM   )
    ) u_allocate_one(
        .v_entry_vld    (vld_reg          ),
        .v_free_idx_oh  (selected_chn     ),
        .v_free_idx_bin (taken_index      ),
        .v_free_vld     (taken_vld        )
    );


endmodule


    



    







