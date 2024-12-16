module icache_tag_array_ctrl
    import toy_pack::*;
    (
    input  logic                                clk                                   ,
    input  logic                                rst_n                                 ,
    input  logic                                tag_req_vld                           ,
    output logic                                tagram_req_rdy                        ,
    input  pc_req_t                             tag_req_pld                           ,
    output logic                                tag_1_hit                             ,
    output logic                                tag_1_miss                            ,
    output logic                                tag_2_hit                             ,
    output logic                                tag_2_miss                            ,
    output logic                                tag_hit_miss                          ,
    output logic                                lru_a_pick                            ,
    output logic                                lru_b_pick                            ,
    output logic                                mshr_update_en                        ,
    output logic                                mshr_update_pld                       ,
    input  logic                                stall
    );
    logic                                       cre_tag_req_vld0                       ;
    pc_req_t                                    cre_tag_req_pld0                       ;
    logic                                       cre_tag_req_vld1                       ;
    pc_req_t                                    cre_tag_req_pld1                       ;
    logic                                       tag_array0_wr_en                       ;
    logic [ICACHE_INDEX_WIDTH-1     :0]         tag_array0_addr                        ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]         tag_array0_dout                        ;
    logic                                       tag_array0_dout_way0_vld               ;
    logic                                       tag_array0_dout_way1_vld               ;
    logic                                       tag_array1_wr_en                       ;
    logic [ICACHE_INDEX_WIDTH-1     :0]         tag_array1_addr                        ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]         tag_array1_dout                        ;
    logic                                       tag_array1_dout_way0_vld               ;
    logic                                       tag_array1_dout_way1_vld               ;
    logic                                       tag_array0_way0_hit                    ;
    logic                                       tag_array0_way1_hit                    ;
    logic                                       tag_array1_way0_hit                    ;
    logic                                       tag_array1_way1_hit                    ;

    logic [ICACHE_WAY_NUM-1         :0]         tag_array0_hit                         ;
    logic [ICACHE_WAY_NUM-1         :0]         tag_array1_hit                         ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]         tag_array0_din                         ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]         tag_array1_din                         ;
    logic [2**ICACHE_INDEX_WIDTH-1  :0]         lru                                    ;
    logic                                       mem_en                                 ;
    pc_req_t                                    req_pld0                               ;
    logic                                       req_vld0                               ;
    pc_req_t                                    req_pld1                               ;
    logic                                       req_vld1                               ;
    logic [ICACHE_INDEX_WIDTH-1     :0]         index                                  ;
    logic                                       lru_b_pick_1d                          ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]         tag_array1_dout_1d                     ;


    logic no_align;
    assign no_align = (tag_req_pld.addr.offset !== 'hff);


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
    
    always_comb begin
        cre_tag_req_vld0 = 1'b0;
        cre_tag_req_pld0 = '{default:'0};
        cre_tag_req_vld1 = 1'b0;
        cre_tag_req_pld1 = '{default:'0};
        if(tag_req_vld && tagram_req_rdy )begin
            if(no_align)begin //no aligned access
                cre_tag_req_vld0        = tag_req_vld;
                cre_tag_req_pld0        = tag_req_pld;
                cre_tag_req_vld1        = tag_req_vld;
                cre_tag_req_pld1.addr   = tag_req_pld.addr+h'40;
                cre_tag_req_pld1.opcode = tag_req_pld.opcode;
                cre_tag_req_pld1.txnid  = tag_req_pld.txnid;
            end
            else begin  //aligned,one read
                cre_tag_req_vld0        = tag_req_vld;
                cre_tag_req_pld0        = tag_req_pld;
                cre_tag_req_vld1        = 0;
                cre_tag_req_pld1        = '{default:'0};
            end
        end
    end

    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            req_vld0    <= 1'b0;
            req_pld0    <= '{default:'0};
            req_vld1    <= 1'b0;
            req_pld1    <= '{default:'0};
        end
        else begin
            req_vld0     <= cre_tag_req_vld0;
            req_pld0     <= cre_tag_req_pld0;
            req_vld1     <= cre_tag_req_vld1;
            req_pld1     <= cre_tag_req_pld1;
        end
        else begin
            req_vld0    <= 1'b0;
            req_pld0    <= '{default:'0};
            req_vld1    <= 1'b0;
            req_pld1    <= '{default:'0};
        end
    end

    
    always_comb begin
        if(wr_buf_1_vld && wr_buf_2_vld)begin
            tag_array0_addr = wr_buf_1_pld.addr.index;
            tag_array1_addr = wr_buf_1_pld.addr.index;
        end
        else if
    end







    


    assign tagram_req_rdy                = (tag_array0_wr_en == 1'b0) && (tag_array1_wr_en == 1'b0) && !stall  ;
    assign index_a                       = req_pld0.addr.index                   ;
    assign index_b                       = req_pld1.addr.index                   ;
    assign mem_en                        = cre_tag_req_vld0 | req_vld0  | tag_2_miss_1d; 

    assign tag_array0_way0_hit           = req_vld0 && ({1'b1,req_pld0.addr.tag} == tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]);
    assign tag_array0_way1_hit           = req_vld0 && ({1'b1,req_pld0.addr.tag} == tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]) ;

    assign tag_array1_way0_hit           = req_vld1 && ({1'b1,req_pld1.addr.tag} == tag_array1_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]);
    assign tag_array1_way1_hit           = req_vld1 && ({1'b1,req_pld1.addr.tag} == tag_array1_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]) ;

    assign tag_array0_hit                = {tag_array0_way0_hit, tag_array0_way1_hit};
    assign tag_array1_hit                = {tag_array1_way0_hit, tag_array1_way1_hit};

    

    
    always_comb begin
        tag_array0_dout_way0_vld        = 0                                         ;
        tag_array0_dout_way1_vld        = 0                                         ;
        tag_array1_dout_way0_vld        = 0                                         ;
        tag_array1_dout_way1_vld        = 0                                         ;
        if((tag_array0_wr_en) && (mem_en))begin
            tag_array0_dout_way0_vld    = tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1]   ;
            tag_array0_dout_way1_vld    = tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1] ;
            tag_array1_dout_way0_vld    = tag_array1_dout[ICACHE_TAG_RAM_WIDTH-1]   ;
            tag_array1_dout_way1_vld    = tag_array1_dout[ICACHE_TAG_RAM_WIDTH/2-1] ;
        end
    end

    

//wr_en  1:write; 0:read
//if snp miss, nothing to do; if hit,update tag.valid and lru
//if  read miss,update tag array; if hit,update lru

//tmp delete DOWNSTREAM and PREFETCH
   
    

    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            lru <= 'b0                      ;
        end
        else if(no_align==1'b1)begin
            if (tag_array0_dout_way0_vld== 1'b0 && tag_array1_dout_way0_vld==1'b0)begin
                lru[index_a] <= 1'b0          ;
                lru[index_b]<=1'b0          ;
            end
            else if (tag_array0_dout_way0_vld== 1'b1 && tag_array0_dout_way1_vld == 1'b0)begin
                lru[index_a] <= 1'b1 ;
                lru[index_b] <= 1'b0 ;
            end
            else if(tag_array0_dout_way0_vld== 1'b0 && tag_array0_dout_way1_vld == 1'b1)begin
                lru[index_a] <= 1'b0;
                lru[index_b] <= 
            end
            else begin
                if (tag_array0_dout_way0_vld == 1'b1 && tag_array0_dout_way1_vld == 1'b1)begin
                    if ((tag_array0_way0_hit == 1'b1)  && (tag_array0_way1_hit == 1'b0))begin
                        lru[index_a] <= 1'b1          ;
                    end
                    else if ((tag_array0_way0_hit == 1'b0)  && (tag_array0_way1_hit == 1'b1)) begin
                        lru[index_a] <= 1'b0          ;
                    end
                    else if (tag_miss) begin
                        lru[index_a] <= ~lru[index] ;
                    end
                end
            end
        end
        else if(no_align==1'b0)begin
            lru[index_b] <= lru[index_b];
            if(tag_array0_dout_way0_vld==1'b0)begin
                lru[index_a]<= 1'b0;
            end
            else if(tag_array0_dout_way0_vld==1'b1 && tag_array0_dout_way1_vld==1'b0)begin
                lru[index_a]<= 1'b1;
            end
            else if(tag_array0_dout_way0_vld && tag_array0_dout_way1_vld)begin
                if(tag_array0_way0_hit)begin
                    lru[index_a]<= 1'b1;
                end
                else if(tag_array0_way1_hit)begin
                    lru[index_a]<= 1'b0;
                end
                else begin
                    lru[index_a]<= ~lru[index];
                end
            end
            else begin
                lru[index_a]<= ~lru[index_a];
            end
        end
    end



//TODO:lru pick：两个miss时第二个写需要能够保持miss当拍的数据和lru结果，为了能够在写第二个miss时数据正确
    always_comb begin
        lru_a_pick = 1'b0;
        if(tag_array0_way0_hit)begin
            lru_pick_a = 1'b0;
        end
        else if(tag_array0_way1_hit)begin
            lru_pick_a = 1'b1;
        end
        else begin
            lru_pick_a = lru[index];
        end
    end
    always_comb begin
        lru_b_pick = 1'b0;
        if(tag_array1_way0_hit)begin
            lru_pick_b = 1'b0;
        end
        else if(tag_array1_way1_hit)begin
            lru_pick_b = 1'b1;
        end
        else begin
            lru_pick_b = lru[index+1];
        end
    end
    always_comb begin
        lru_a_pick = 1'b0;
        lru_b_pick = 1'b0;
        if(no_align==1'b0)begin
            if(tag_array0_way0_hit)begin
                lru_a_pick = 1'b0;
            end
            else if(tag_array0_way1_hit)begin
                lru_a_pick = 1'b1;
            end
            else begin
                lru_a_pick = lru[index];
            end
        end
        else if(no_align==1'b1)begin
            if(tag_2_hit)begin
                lru_a_pick = tag_array0_way0_hit ? 1'b0 : 1'b1;
                lru_b_pick = tag_array1_way0_hit ? 1'b0 : 1'b1;
            end
            else if(tag_hit_miss)begin
                if(tag_array0_hit)begin
                    lru_a_pick = tag_array0_way0_hit ? 1'b0 : 1'b1;
                    lru_b_pick = lru[index+1];
                end
                else if(tag_array1_hit)begin
                    lru_a_pick = lru[index];
                    lru_b_pick = tag_array1_way0_hit ? 1'b0 : 1'b1;
                end
            end
            else if(tag_2_miss)begin
                lru_a_pick = lru[index];
                lru_b_pick = lru[index+1];
            end
        end
    end

    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            lru_b_pick_1d       <= 'b0              ;
            tag_array1_dout_1d  <= 'b0              ;
        end
        else if(tag_2_miss)begin
            lru_b_pick_1d       <= lru_b_pick       ;
            tag_array1_dout_1d  <= tag_array1_dout  ;
        end
    end

    always_comb begin
        if(no_align==1'b0)begin
            if(wr_buf1_vld==1'b0 && wr_buf_2_vld == 1'b0)begin
                mshr_update_en = 1'b1;
                mshr_update_pld = {cre_tag_req_pld0, {PLD_WIDTH{1'b0}}};
            end
            else begin
                mshr_update_en = 1'b0;
                mshr_update_pld = 'b0;
            end
        end
        else if(no_align==1'b1)begin
            if(wr_buf_1_vld ==1'b0 && wr_buf_2_vld==1'b0)begin
                mshr_update_en  = 1'b1;
                mshr_update_pld = {cre_tag_req_pld0, cre_tag_req_pld1};
            end
            else begin
                mshr_update_en  = 1'b0;
                mshr_update_pld = 'b0;
            end
        end
        else begin
            mshr_update_en  = 1'b0;
            mshr_update_pld = '{default:'0};
        end
    end

    always_comb begin
        if(tag_array1_way0_hit)begin
            lru_b_pick = 1'b0;
        end
        else if(tag_array1_way1_hit)begin
            lru_b_pick = 1'b1;
        end
        else begin
            lru_b_pick = lru_b[index];
        end
    end


    toy_mem_model_bit #(
        .ADDR_WIDTH(ICACHE_INDEX_WIDTH   ),
        .DATA_WIDTH(ICACHE_TAG_RAM_WIDTH )
    ) u_icache_tag_array0(
        .clk        (clk                 ),
        .en         (mem_en              ),
        .wr_en      (tag_array0_wr_en    ),
        .addr       (tag_array0_addr     ),
        .rd_data    (tag_array0_dout     ),
        .wr_data    (tag_array0_din      )
    );

    toy_mem_model_bit #(
        .ADDR_WIDTH(ICACHE_INDEX_WIDTH   ),
        .DATA_WIDTH(ICACHE_TAG_RAM_WIDTH )
    ) u_icache_tag_array1(
        .clk        (clk                 ),
        .en         (mem_en              ),
        .wr_en      (tag_array1_wr_en    ),
        .addr       (tag_array1_addr     ),
        .rd_data    (tag_array1_dout     ),
        .wr_data    (tag_array1_din      )
    );


endmodule



