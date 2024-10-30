module icache_tag_array_ctrl
    import toy_pack::*;
    (
    input  logic                                clk                                   ,
    input  logic                                rst_n                                 ,
    input  logic                                dataram_rd_rdy                        ,
    input  logic                                tag_req_vld                           ,
    output logic                                tag_req_rdy                           ,
    input  pc_req_t                             tag_req_pld                           ,
    input  logic [MSHR_ENTRY_INDEX_WIDTH-1:0]   tag_req_index                         ,
    input  mshr_entry_t                         vv_mshr_entry_array[MSHR_ENTRY_NUM-1:0],

    output logic[WAY_NUM-1:0]                   A_hit                                 ,
    output logic[WAY_NUM-1:0]                   B_hit                                 ,
    output logic                                A_miss                                ,
    output logic                                B_miss                                ,

    output logic    pre_tag_req_vld,
    //output pc_req_t pre_tag_req_pld,

    output logic                                mshr_update_en                        ,
    output entry_data_t                         entry_data                            ,
    output logic                                bypass_rd_dataramA_vld                ,
    output dataram_rd_pld_t                     bypass_rd_dataramA_pld                ,
    output logic                                bypass_rd_dataramB_vld                ,
    output dataram_rd_pld_t                     bypass_rd_dataramB_pld                ,
    output logic                                A_index_way_checkpass                 ,
    output logic                                B_index_way_checkpass                 ,
    output logic [MSHR_ENTRY_NUM-1:0]           v_A_hazard_bitmap                     ,
    output logic [MSHR_ENTRY_NUM-1:0]           v_B_hazard_bitmap                     ,
    input  logic [MSHR_ENTRY_INDEX_WIDTH:0]     entry_release_done_index              ,
    input  logic                                stall
    );

    logic                               cre_tag_req_vld         ;
    pc_req_t                            cre_tag_req_pldA        ;
    pc_req_t                            cre_tag_req_pldB        ;
    logic                               align                   ;
    logic                               req_vld_A               ;
    logic                               req_vld_B               ;
    pc_req_t                            req_pld_A               ;
    pc_req_t                            req_pld_B               ;
    logic                               tag_array_A_wr_en       ;
    logic                               tag_array_B_wr_en       ;
    logic                               wr_buf_vld              ;
    logic                               mem_en                  ;
    logic [ICACHE_INDEX_WIDTH-1     :0] tag_array_A_addr        ;
    logic [ICACHE_INDEX_WIDTH-1     :0] tag_array_B_addr        ;
    logic                               wr_tag_buf_A_vld        ;
    logic                               wr_tag_buf_B_vld        ;
    logic [ICACHE_TAG_RAM_WIDTH-1  :0]  wr_tag_buf_A_pld        ;
    logic [ICACHE_TAG_RAM_WIDTH-1  :0]  wr_tag_buf_B_pld        ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0] tag_array_A_din         ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0] tag_array_B_din         ;
    logic [ICACHE_INDEX_WIDTH-1     :0] wr_tag_buf_A_index      ;
    logic [ICACHE_INDEX_WIDTH-1     :0] wr_tag_buf_B_index      ;
    logic                               A_tag_way0_hit          ;
    logic                               A_tag_way1_hit          ;
    logic                               B_tag_way0_hit          ;
    logic                               B_tag_way1_hit          ;
    mshr_pld_t                          mshr_update_pld         ;
    
    logic                               tag_arrayA_dout_way0_vld;
    logic                               tag_arrayA_dout_way1_vld;
    logic                               tag_arrayA_dout_vld     ;  
    logic                               tag_arrayB_dout_way0_vld;
    logic                               tag_arrayB_dout_way1_vld;
    logic                               tag_arrayB_dout_vld     ;
    logic                               lru_a                   ;
    logic                               lru_b                   ;
    logic                               lru_a_pick              ;
    logic                               lru_b_pick              ;
    logic [2**ICACHE_INDEX_WIDTH-1  :0] lru                     ;
    logic                               dest_wayA               ;
    logic                               dest_wayB               ;
    logic                               bypass_hazard_free      ;   
    logic [ICACHE_TAG_RAM_WIDTH-1   :0] tag_array_A_dout        ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0] tag_array_B_dout        ;
    logic [ICACHE_INDEX_WIDTH-1     :0] indexA  ;
    logic [ICACHE_INDEX_WIDTH-1     :0] indexB  ;
    
    assign align = (tag_req_pld.addr.offset == {ICACHE_OFFSET_WIDTH{1'b1}});
    assign tag_req_rdy = (wr_buf_vld==1'b0) && (stall==1'b0);


//--------------------------------------------------------------
//          3 to 1 mux  to select wr buffer and new req
//--------------------------------------------------------------
//目前考虑采用的tagram读取方式为，不管是对齐还是非对齐都会同时去读两个ram，区别是地址为（N和N）还是（N和N+1），这样方便两块dataram的地址连接，可以固定dataram1固接tagram1的地址，dataram2固接tagram2的地址；
//非对齐的两个都miss时需要用两拍来写入tag ram，相当于三选1的固定优先级arb，req_arb的req优先级最低；
//在hit/miss检查时，查找当前的buffer是否有效如果有效且index相同，则根据buffer来判断hit/miss，否则，去读tagram来判断hit/miss；
//更新buffer，若一个miss，则更新第一个buffer，若两个miss则同时更新两个buffer；
//对于lru的更新，只需要维护一份lru table，若是非对齐访问则会一次性更新两个lru bit，若是对齐访问则只更新一个bit
//每个tagram会对应产生各自的hit和miss，用于更新各自对应的buffer

//所以需要考虑是对齐还是非对齐的地方在于：

//=====================================================
// arb between tag_req and wr_buf_A and wr_buf_B
//=====================================================
//arb between tag_req and wr_buf_A and wr_buf_B
    
    always_comb begin
        if(wr_tag_buf_A_vld | wr_tag_buf_B_vld)begin
            cre_tag_req_vld = 1'b0;
        end
        else if(wr_tag_buf_A_vld==1'b0 && wr_tag_buf_B_vld==1'b0 && tag_req_rdy)begin
            cre_tag_req_vld = tag_req_vld ;
        end
        else begin
            cre_tag_req_vld = 1'b0;
        end
    end
    assign pre_tag_req_vld = cre_tag_req_vld;
    //assign pre_tag_req_pld 
    assign cre_tag_req_pldA = tag_req_pld;
    assign cre_tag_req_pldB = align ? tag_req_pld : (tag_req_pld+'h40);

    always_ff@(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            req_vld_A  <= 1'b0;
            req_vld_B  <= 1'b0;
        end
        else begin
            req_vld_A <= cre_tag_req_vld;
            req_vld_B <= cre_tag_req_vld;
        end
    end

    //always_ff@(posedge clk)begin
    //    if(wr_tag_buf_A_vld==1'b0 && wr_tag_buf_B_vld==1'b0)begin
    //        if(align == 1'b0)begin
    //            req_pld_A <= cre_tag_req_pldA;
    //            req_pld_B <= cre_tag_req_pldB;
    //        end
    //        else begin
    //            req_pld_A <= cre_tag_req_pldA;
    //            req_pld_B <= cre_tag_req_pldB;
    //        end
    //    end
    //end
    always_ff@(posedge clk)begin
        if(wr_tag_buf_A_vld==1'b0 && wr_tag_buf_B_vld==1'b0)begin
            req_pld_A <= cre_tag_req_pldA;
            req_pld_B <= cre_tag_req_pldB; 
        end
    end
    

//===========================================
//        tag  ram
//===========================================

    assign tag_array_A_wr_en = wr_buf_vld;
    assign tag_array_B_wr_en = wr_buf_vld;
    assign mem_en            = wr_buf_vld | cre_tag_req_vld;
    //assign tag_array_A_addr  = wr_tag_buf_A_vld  ? wr_tag_buf_A_index 
    //                          : wr_tag_buf_B_vld ? wr_tag_buf_B_index 
    //                          : cre_tag_req_pldA.addr.index;
    always_comb begin
        tag_array_A_addr = 'b0;
        if(wr_tag_buf_A_vld)        tag_array_A_addr = wr_tag_buf_A_index;
        else if(wr_tag_buf_B_vld)   tag_array_A_addr = wr_tag_buf_B_index;
        else if(cre_tag_req_vld)    tag_array_A_addr =  cre_tag_req_pldA.addr.index;
    end
    //assign tag_array_B_addr  = wr_tag_buf_A_vld  ? wr_tag_buf_A_index 
    //                          : wr_tag_buf_B_vld ? wr_tag_buf_B_index
    //                          : (cre_tag_req_pldB.addr.index);
    always_comb begin
        tag_array_B_addr = 'b0;
        if(wr_tag_buf_A_vld)        tag_array_B_addr = wr_tag_buf_A_index;
        else if(wr_tag_buf_B_vld)   tag_array_B_addr = wr_tag_buf_B_index;
        else if(cre_tag_req_vld)    tag_array_B_addr =  cre_tag_req_pldB.addr.index;
    end

    always_comb begin
        tag_array_A_din = 'b0;
        tag_array_B_din = 'b0;
        if(wr_tag_buf_A_vld)begin
            tag_array_A_din = wr_tag_buf_A_pld;
            tag_array_B_din = wr_tag_buf_A_pld;
        end
        else if(wr_tag_buf_A_vld==1'b0 && wr_tag_buf_B_vld)begin
            tag_array_A_din = wr_tag_buf_B_pld;
            tag_array_B_din = wr_tag_buf_B_pld;
        end
    end
    toy_mem_model_bit #(
        .ADDR_WIDTH(ICACHE_INDEX_WIDTH   ),
        .DATA_WIDTH(ICACHE_TAG_RAM_WIDTH )
    ) u_icache_tag_array0(
        .clk        (clk                 ),
        .en         (mem_en              ),
        .wr_en      (tag_array_A_wr_en    ),
        .addr       (tag_array_A_addr     ),
        .rd_data    (tag_array_A_dout     ),
        .wr_data    (tag_array_A_din      )
    );

    toy_mem_model_bit #(
        .ADDR_WIDTH(ICACHE_INDEX_WIDTH   ),
        .DATA_WIDTH(ICACHE_TAG_RAM_WIDTH )
    ) u_icache_tag_array1(
        .clk        (clk                  ),
        .en         (mem_en               ),
        .wr_en      (tag_array_B_wr_en    ),
        .addr       (tag_array_B_addr     ),
        .rd_data    (tag_array_B_dout     ),
        .wr_data    (tag_array_B_din      )
    );

//===========================================
//        update wr tag buffer
//===========================================
//vld 
    assign wr_buf_vld       = wr_tag_buf_A_vld | wr_tag_buf_B_vld;
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            wr_tag_buf_A_vld <= 1'b0;
        end
        else begin
            if(A_miss )                 wr_tag_buf_A_vld <= 1'b1;
            else if(wr_tag_buf_A_vld)   wr_tag_buf_A_vld <= 1'b0;
            else                        wr_tag_buf_A_vld <= 1'b0;
        end
    end
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            wr_tag_buf_B_vld <= 1'b0;
        end
        else begin
            if(B_miss)                                           wr_tag_buf_B_vld <= 1'b1;
            else if(wr_tag_buf_A_vld==1'b0 && wr_tag_buf_B_vld)  wr_tag_buf_B_vld <= 1'b0;
            else                                                 wr_tag_buf_B_vld <= 1'b0;
        end
    end
    //pld
    always_ff@(posedge clk ) begin
        wr_tag_buf_A_index <= req_pld_A.addr.index;
        wr_tag_buf_B_index <= req_pld_B.addr.index;
        if(A_miss && B_miss)begin 
            wr_tag_buf_A_pld <= lru_a_pick ? {tag_array_A_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b1,req_pld_A.addr.tag}
                                        : {1'b1,req_pld_A.addr.tag, tag_array_A_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]};
            wr_tag_buf_B_pld <= lru_b_pick ? {tag_array_B_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b1,req_pld_B.addr.tag}
                                        : {1'b1,req_pld_B.addr.tag, tag_array_B_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]};
        end
        else if (A_miss && B_hit)begin
            wr_tag_buf_A_pld <= lru_a_pick ? {tag_array_A_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b1,req_pld_A.addr.tag}
                                        : {1'b1,req_pld_A.addr.tag, tag_array_A_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]};
            wr_tag_buf_B_pld <= 'b0;
        end
        else if(A_hit && B_miss)begin
            wr_tag_buf_A_pld <= 'b0;
            wr_tag_buf_B_pld <= lru_b_pick ? {tag_array_B_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b1,req_pld_B.addr.tag}
                                        : {1'b1,req_pld_B.addr.tag, tag_array_B_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]};
        end
    end

//===========================================
//        hit/miss check
//===========================================

    always_comb begin
        A_tag_way0_hit = 1'b0;
        A_tag_way1_hit = 1'b0;
        if(req_vld_A)begin
            if((wr_tag_buf_A_vld &&req_pld_A.addr.index == wr_tag_buf_A_index) || (wr_tag_buf_B_vld && req_pld_A.addr.index == wr_tag_buf_B_index))begin
                if(({1'b1,req_pld_A.addr.tag} == wr_tag_buf_A_pld[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]) || ({1'b1,req_pld_A.addr.tag} == wr_tag_buf_B_pld[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]))begin
                    A_tag_way0_hit = 1'b1;
                    A_tag_way1_hit = 1'b0;
                end
                else if(({1'b1,req_pld_A.addr.tag} == wr_tag_buf_A_pld[ICACHE_TAG_RAM_WIDTH/2-1:0]) || ({1'b1,req_pld_A.addr.tag} == wr_tag_buf_B_pld[ICACHE_TAG_RAM_WIDTH/2-1:0]))begin
                    A_tag_way0_hit = 1'b0;
                    A_tag_way1_hit = 1'b1;
                end
            end
            else begin
                if({1'b1,req_pld_A.addr.tag} ==tag_array_A_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2])begin
                    A_tag_way0_hit = 1'b1;
                    A_tag_way1_hit = 1'b0;
                end
                else if({1'b1,req_pld_A.addr.tag} ==tag_array_A_dout[ICACHE_TAG_RAM_WIDTH/2-1:0])begin
                    A_tag_way0_hit = 1'b0;
                    A_tag_way1_hit = 1'b1;
                end
            end
        end
    end

    always_comb begin
        B_tag_way0_hit = 1'b0;
        B_tag_way1_hit = 1'b0;
        if(req_vld_B)begin
            if((wr_tag_buf_A_vld &&req_pld_A.addr.index == wr_tag_buf_A_index) || (wr_tag_buf_B_vld && req_pld_A.addr.index == wr_tag_buf_B_index))begin
                if(({1'b1,req_pld_B.addr.tag} == wr_tag_buf_A_pld[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]) || ({1'b1,req_pld_B.addr.tag} == wr_tag_buf_B_pld[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]))begin
                    B_tag_way0_hit = 1'b1;
                    B_tag_way1_hit = 1'b0;
                end
                else if(({1'b1,req_pld_B.addr.tag} == wr_tag_buf_A_pld[ICACHE_TAG_RAM_WIDTH/2-1:0]) || ({1'b1,req_pld_B.addr.tag} == wr_tag_buf_B_pld[ICACHE_TAG_RAM_WIDTH/2-1:0]))begin
                    B_tag_way0_hit = 1'b0;
                    B_tag_way1_hit = 1'b1;
                end
            end
            else begin
                if({1'b1,req_pld_B.addr.tag} ==tag_array_B_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2])begin
                    B_tag_way0_hit = 1'b1;
                    B_tag_way1_hit = 1'b0;
                end
                else if({1'b1,req_pld_B.addr.tag} ==tag_array_B_dout[ICACHE_TAG_RAM_WIDTH/2-1:0])begin
                    B_tag_way0_hit = 1'b0;
                    B_tag_way1_hit = 1'b1;
                end
            end
        end
    end

    assign A_hit  = {A_tag_way0_hit , A_tag_way1_hit};
    assign B_hit  = {B_tag_way0_hit , B_tag_way1_hit};
    assign A_miss = (~(A_tag_way0_hit | A_tag_way1_hit)) && req_vld_A;
    assign B_miss = (~(B_tag_way0_hit | B_tag_way1_hit)) && req_vld_B;


//========================================================
//         hazard check and behavior mapping 
//========================================================
    assign mshr_update_pld.pldA = req_pld_A;
    assign mshr_update_pld.pldB = req_pld_B;
    always_comb begin
        mshr_update_en = 1'b0;
        if(req_vld_A | req_vld_B)begin
            if(req_pld_A.opcode == DOWNSTREAM_OPCODE) mshr_update_en = 1'b0;
            else                                      mshr_update_en = 1'b1;
        end
    end

    generate 
        for (genvar i = 0; i < MSHR_ENTRY_NUM; i++)begin:gen_hazard_bitmap_A
            always_comb begin
                v_A_hazard_bitmap[i] = 0;
                if(mshr_update_en)begin
                    if((i==tag_req_index) | (i==entry_release_done_index[MSHR_ENTRY_INDEX_WIDTH-1:0]))begin
                       v_A_hazard_bitmap[i] = 1'b0; 
                    end
                    else if( (req_pld_A.addr.index==vv_mshr_entry_array[i].pld.pldA.addr.index) && (((~A_tag_way0_hit)==vv_mshr_entry_array[i].dest_wayA) | ((A_tag_way1_hit)==vv_mshr_entry_array[i].dest_wayA)))begin
                        v_A_hazard_bitmap[i] = 1'b1; 
                    end
                    else if( (req_pld_A.addr.index==vv_mshr_entry_array[i].pld.pldB.addr.index) && (((~A_tag_way0_hit)==vv_mshr_entry_array[i].dest_wayB) | ((A_tag_way1_hit)==vv_mshr_entry_array[i].dest_wayB)))begin
                        v_A_hazard_bitmap[i] = 1'b1;
                    end
                end
            end
        end
    endgenerate
    assign A_index_way_checkpass = ((|v_A_hazard_bitmap)==1'b0);

    generate 
        for (genvar i = 0; i < MSHR_ENTRY_NUM; i++)begin:gen_hazard_bitmap_B
            always_comb begin
                v_B_hazard_bitmap[i] = 0;
                if(mshr_update_en)begin
                    if((i==tag_req_index) | (i==entry_release_done_index[MSHR_ENTRY_INDEX_WIDTH-1:0]))begin
                       v_B_hazard_bitmap[i] = 1'b0; 
                    end
                    else if( (req_pld_B.addr.index==vv_mshr_entry_array[i].pld.pldA.addr.index) && (((~B_tag_way0_hit)==vv_mshr_entry_array[i].dest_wayA) | ((B_tag_way1_hit)==vv_mshr_entry_array[i].dest_wayA)))begin
                        v_B_hazard_bitmap[i] = 1'b1; 
                    end
                    else if( (req_pld_B.addr.index==vv_mshr_entry_array[i].pld.pldB.addr.index) && (((~B_tag_way0_hit)==vv_mshr_entry_array[i].dest_wayB) | ((B_tag_way1_hit)==vv_mshr_entry_array[i].dest_wayB)))begin
                        v_B_hazard_bitmap[i] = 1'b1;
                    end
                end
            end
        end
    endgenerate
    assign B_index_way_checkpass = ((|v_B_hazard_bitmap)==1'b0);


//========================================================
//             lru weight update 
//========================================================


assign tag_arrayA_dout_way0_vld = tag_array_A_dout[ICACHE_TAG_RAM_WIDTH-1];
assign tag_arrayA_dout_way1_vld = tag_array_A_dout[ICACHE_TAG_RAM_WIDTH/2-1];
assign tag_arrayA_dout_vld = tag_arrayA_dout_way0_vld && tag_arrayA_dout_way1_vld;

assign tag_arrayB_dout_way0_vld = tag_array_B_dout[ICACHE_TAG_RAM_WIDTH-1];
assign tag_arrayB_dout_way1_vld = tag_array_B_dout[ICACHE_TAG_RAM_WIDTH/2-1];
assign tag_arrayB_dout_vld = tag_arrayB_dout_way0_vld && tag_arrayB_dout_way1_vld;

    assign  indexA        = req_pld_A.addr.index;
    assign  indexB        = req_pld_B.addr.index;



    always_ff @(posedge clk or negedge rst_n) begin  
        if (!rst_n) begin  
            lru_a <= 1'b0;  
            lru_b <= 1'b0;  
            lru[indexA] <= 1'b0;  
            lru[indexB] <= 1'b0;  
        end 
        else begin  
            // 更新lru_a和lru[indexA]  
            if (tag_arrayA_dout_way0_vld == 1'b0) begin  
                lru_a <= 1'b0;  
                lru[indexA] <= 1'b0;  
            end 
            else if (tag_arrayA_dout_way1_vld == 1'b0) begin  
                lru_a <= tag_arrayA_dout_way0_vld;  
                lru[indexA] <= tag_arrayA_dout_way0_vld;  
            end 
            else begin  
                if (A_tag_way0_hit) begin  
                    lru_a <= 1'b1;  
                    lru[indexA] <= 1'b1;  
                end else if (A_tag_way1_hit) begin  
                    lru_a <= 1'b0;  
                    lru[indexA] <= 1'b0;  
                end else if (A_miss) begin  
                    lru_a <= ~lru_a;  
                    lru[indexA] <= ~lru[indexA];  
                end  
            end  
  
            // 更新lru_b和lru[indexB]  
            if (tag_arrayB_dout_way0_vld == 1'b0) begin  
                lru_b <= 1'b0;  
                lru[indexB] <= 1'b0;  
            end 
            else if (tag_arrayB_dout_way1_vld == 1'b0) begin  
                lru_b <= tag_arrayB_dout_way0_vld;  
                lru[indexB] <= tag_arrayB_dout_way0_vld;  
            end 
            else begin  
                if (B_tag_way0_hit) begin  
                    lru_b <= 1'b1;  
                    lru[indexB] <= 1'b1;  
                end else if (B_tag_way1_hit) begin  
                    lru_b <= 1'b0;  
                    lru[indexB] <= 1'b0;  
                end else if (B_miss) begin  
                    lru_b <= ~lru_b;  
                    // 注意：这里根据需求，lru[indexB]可能应该被设置为0或其他值  
                    lru[indexB] <= ~lru[indexB]; // 或者使用其他逻辑  
                end  
            end  
        end  
    end  
  
    assign lru_a_pick = lru[indexA];  
    assign lru_b_pick = lru[indexB];  

    //always_ff@(posedge clk or negedge rst_n) begin
    //    if(!rst_n)begin
    //        lru_a      <= 'b0                     ;
    //        lru[indexA] <= 'b0;
    //    end
    //    else if (tag_arrayA_dout_way0_vld == 1'b0)begin
    //        lru_a      <= 1'b0                     ;
    //        lru[indexA] <= 1'b0;
    //    end
    //    else if (tag_arrayA_dout_way0_vld == 1'b1 && tag_arrayA_dout_way1_vld == 1'b0)begin
    //        lru_a      <= 1'b1                     ;
    //        lru[indexA] <= 1'b1;
    //    end
    //    else if (tag_arrayA_dout_way0_vld == 1'b1 && tag_arrayA_dout_way1_vld == 1'b1)begin
    //        if ((A_tag_way0_hit == 1'b1) )begin
    //            lru_a  <= 1'b1                     ;
    //            lru[indexA] <= 1'b1;
    //        end
    //        else if ((A_tag_way1_hit == 1'b1)) begin
    //            lru_a  <= 1'b0                     ;
    //            lru[indexA] <= 1'b0;
    //        end
    //        else if (A_miss) begin
    //            lru_a  <= ~lru_a                   ;
    //            lru[indexA] <= ~lru[indexA];
    //        end
    //    end
    //end
    //always_ff@(posedge clk or negedge rst_n) begin
    //    if(!rst_n)begin
    //        lru_b      <= 'b0                     ;
    //        lru[indexB]<= 'b0 ;
    //    end
    //    else if (tag_arrayB_dout_way0_vld == 1'b0)begin
    //        lru_b       <= 1'b0                   ;
    //        lru[indexB]<= 1'b0;
    //    end
    //    else if (tag_arrayB_dout_way0_vld == 1'b1 && tag_arrayB_dout_way1_vld == 1'b0)begin
    //        lru_b      <= 1'b1                     ;
    //        lru[indexB]<= 1'b1;
    //    end
    //    else if (tag_arrayB_dout_way0_vld == 1'b1 && tag_arrayB_dout_way1_vld == 1'b1)begin
    //        if ((B_tag_way0_hit == 1'b1) )begin
    //            lru_b  <= 1'b1                     ;
    //            lru[indexB]<= 1'b1;
    //        end
    //        else if ((B_tag_way1_hit == 1'b1)) begin
    //            lru_b  <= 1'b0                     ;
    //            lru[indexB]<= 1'b0;
    //        end
    //        else if (B_miss) begin
    //            lru_b  <= ~lru_b                   ;
    //            lru[indexB]<= 1'b0;
    //        end
    //    end
    //end
    //assign lru_a_pick = lru[indexA];
    //assign lru_b_pick = lru[indexB];





    always_comb begin
        dest_wayA = 1'b0;
        if(A_tag_way0_hit)      dest_wayA = 1'b0;
        else if(A_tag_way1_hit) dest_wayA = 1'b1;
        else                    dest_wayA = lru_a_pick;
    end
    always_comb begin
        dest_wayB = 1'b0;
        if(B_tag_way0_hit)      dest_wayB = 1'b0;
        else if(B_tag_way1_hit) dest_wayB = 1'b1;
        else                    dest_wayB = lru_b_pick;
    end

 

//=========================================================
//             bypass read data ram (2hit && hazard_free) 
//=========================================================

assign bypass_hazard_free              = A_index_way_checkpass && B_index_way_checkpass;
assign bypass_rd_dataramA_vld          = bypass_hazard_free && ((A_tag_way0_hit || A_tag_way1_hit) && (B_tag_way0_hit || B_tag_way1_hit)) && dataram_rd_rdy;
assign bypass_rd_dataramA_pld.rd_index = mshr_update_pld.pldA.addr.index;
assign bypass_rd_dataramA_pld.rd_way   = A_tag_way0_hit ? 1'b0 : 1'b1;
assign bypass_rd_dataramA_pld.rd_txnid = mshr_update_pld.pldA.txnid;

assign bypass_rd_dataramB_vld          = bypass_hazard_free && ((A_tag_way0_hit || A_tag_way1_hit) && (B_tag_way0_hit || B_tag_way1_hit)) && dataram_rd_rdy;
assign bypass_rd_dataramB_pld.rd_index = mshr_update_pld.pldB.addr.index;
assign bypass_rd_dataramB_pld.rd_way   = B_tag_way0_hit ? 1'b0 : 1'b1;
assign bypass_rd_dataramB_pld.rd_txnid = mshr_update_pld.pldB.txnid;


assign entry_data.pld = mshr_update_pld;
assign entry_data.dest_wayA = dest_wayA;
assign entry_data.dest_wayB = dest_wayB;


//===========================================
//===========================================


endmodule



