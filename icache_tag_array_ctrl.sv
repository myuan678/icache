module icache_tag_array_ctrl
    import toy_pack::*;
    (
    input  logic                                        clk                     ,
    input  logic                                        rst_n                   ,
    input  logic                                        tag_req_vld             ,
    output logic                                        tagram_req_rdy          ,
    input  pc_req_t                                     tag_req_pld             ,
    output logic                                        tag_miss                ,
    output logic [WAY_NUM-1:0]                          tag_hit                 ,
    output logic                                        lru_pick                ,
    input  logic                                        stall

    );

    logic                                               cre_tag_req_vld         ;
    pc_req_t                                            cre_tag_req_pld         ;
    always_comb begin
        cre_tag_req_vld = 1'b0;
        cre_tag_req_pld = '{default:'0};
        if(tag_req_vld && tagram_req_rdy )begin
            cre_tag_req_vld = tag_req_vld;
            cre_tag_req_pld = tag_req_pld;
        end
    end
 
    logic                                tag_array0_wr_en                       ;
    logic [ICACHE_INDEX_WIDTH-1     :0]  tag_array0_addr                        ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]  tag_array0_dout                        ;
    logic                                tag_array0_dout_way0_vld               ;
    logic                                tag_array0_dout_way1_vld               ;
    logic                                tag_way0_hit                           ;
    logic                                tag_way1_hit                           ;
    logic [ICACHE_TAG_RAM_WIDTH-1   :0]  tag_array0_din                         ;
    logic [2**ICACHE_INDEX_WIDTH-1  :0]  lru                                    ;
    logic                                mem_en                                 ;
    pc_req_t                             req_pld                                ;
    logic                                req_vld                                ;
    logic [ICACHE_INDEX_WIDTH-1     :0]  index                                  ;

    assign index                         = req_pld.addr.index                   ;
    assign mem_en                        = cre_tag_req_vld | req_vld            ;
    assign tagram_req_rdy                = (tag_array0_wr_en == 1'b0) && !stall ;
    assign tag_way0_hit                  = req_vld && ({1'b1,req_pld.addr.tag} == tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2]);
    assign tag_way1_hit                  = req_vld && ({1'b1,req_pld.addr.tag} == tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]) ;

    assign tag_hit                       = {tag_way0_hit,tag_way1_hit}          ;
    assign tag_miss                      = ~(tag_way0_hit | tag_way1_hit) && req_vld ;

    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            req_vld    <= 1'b0;
            req_pld    <= '{default:'0};
        end
        else if(cre_tag_req_vld)begin
            req_vld     <= 1'b1;
            req_pld    <= cre_tag_req_pld;
        end
        else begin
            req_vld    <= 1'b0;
            req_pld    <= '{default:'0};
        end
    end

//wr_en  1:write; 0:read
//if snp miss, nothing to do; if hit,update tag.valid and lru
//if  read miss,update tag array; if hit,update lru
    always_comb begin
        if(tag_miss)begin
            if(req_pld.opcode == DOWNSTREAM_OPCODE )begin
                tag_array0_wr_en         = 1'b0                                 ;
                tag_array0_din           = 'b0                                  ;
                tag_array0_addr          = req_pld.addr.index                   ;
            end
            else if((req_pld.opcode == UPSTREAM_OPCODE || req_pld.opcode == PREFETCH_OPCODE))begin
                tag_array0_wr_en         = 1'b1                                 ;   
                tag_array0_din           = lru_pick ? {tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b1,req_pld.addr.tag}
                                     : {1'b1,req_pld.addr.tag,tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1:0]};
                tag_array0_addr          = req_pld.addr.index                   ;
            end
            else begin
                tag_array0_wr_en         = 1'b0                                 ;
                tag_array0_din           = 'b0                                  ;
                tag_array0_addr          = req_pld.addr.index                   ;
            end
        end
        else if(|tag_hit && req_pld.opcode == DOWNSTREAM_OPCODE)begin
            tag_array0_wr_en             = 1'b1;
            tag_array0_din               = tag_way0_hit ? {1'b0,tag_array0_dout[ICACHE_TAG_RAM_WIDTH-2:0]} : {tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1:ICACHE_TAG_RAM_WIDTH/2],1'b0,tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-2:0]} ;
            tag_array0_addr              = req_pld.addr.index                   ;
        end
        else begin
            tag_array0_wr_en             = 1'b0                                 ;
            tag_array0_din               = 'b0                                  ;
            tag_array0_addr              = tag_req_pld.addr.index               ;
        end
    end



    always_comb begin
        tag_array0_dout_way0_vld = 0                                                ;
        tag_array0_dout_way1_vld = 0                                                ;
        if((tag_array0_wr_en) && (mem_en))begin
            tag_array0_dout_way0_vld    = tag_array0_dout[ICACHE_TAG_RAM_WIDTH-1]   ;
            tag_array0_dout_way1_vld    = tag_array0_dout[ICACHE_TAG_RAM_WIDTH/2-1] ;
        end
    end

    //always_comb begin
    //    if (tag_array0_dout_way0_vld== 1'b0)begin
    //        lru[index] = 1'b0          ;
    //    end
    //    else if (tag_array0_dout_way0_vld== 1'b1 && tag_array0_dout_way1_vld == 1'b0)begin
    //        lru[index] = 1'b1          ;
    //    end
    //    else if (tag_array0_dout_way0_vld== 1'b1 && tag_array0_dout_way1_vld == 1'b1)begin
    //          if ((tag_way0_hit == 1'b1)  && (tag_way1_hit == 1'b0))begin
    //              lru[index] = 1'b1          ;
    //          end
    //          else if ((tag_way0_hit == 1'b0)  && (tag_way1_hit == 1'b1)) begin
    //              lru[index] = 1'b0          ;
    //          end
    //          else if (tag_miss) begin
    //              //lru_pick = ~lru[index]   ;
    //              lru[index] = 1'b0;
    //          end
    //    end
    //end
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            lru <= 'b0                      ;
        end
        else if (tag_array0_dout_way0_vld== 1'b0)begin
            lru[index] <= 1'b0              ;
        end
        else if (tag_array0_dout_way0_vld== 1'b1 && tag_array0_dout_way1_vld == 1'b0)begin
            lru[index] <= 1'b1              ;
        end
        else if (tag_array0_dout_way0_vld== 1'b1 && tag_array0_dout_way1_vld == 1'b1)begin
            if ((tag_way0_hit == 1'b1)  && (tag_way1_hit == 1'b0))begin
                lru[index] <= 1'b1          ;
            end
            else if ((tag_way0_hit == 1'b0)  && (tag_way1_hit == 1'b1)) begin
                lru[index] <= 1'b0          ;
            end
            else if (tag_miss) begin
                lru[index] <= ~lru[index]   ;
            end
        end
    end

    always_comb begin
        if(tag_way0_hit)begin
            lru_pick = 1'b0;
        end
        else if(tag_way1_hit)begin
            lru_pick = 1'b1;
        end
        else begin
            lru_pick = lru[index];
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


endmodule



