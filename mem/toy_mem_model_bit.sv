//module toy_mem_model_bit #(
//    parameter string            ARGPARSE_KEY    = "HEX",
//    parameter integer unsigned  ALLOW_NO_HEX    = 1,
//    parameter integer unsigned  ADDR_WIDTH      = 32,
//    parameter integer unsigned  DATA_WIDTH      = 32
//) (
//    input  logic                     clk,
//    input  logic                     en,
//    input  logic [ADDR_WIDTH-1:0]    addr,
//    output logic [DATA_WIDTH-1:0]    rd_data,
//    input  logic [DATA_WIDTH-1:0]    wr_data,
//    input  logic                     wr_en
//);
//
//    typedef logic [ADDR_WIDTH-1:0]    logic_addr;
//    typedef logic [DATA_WIDTH-1:0]    logic_data;
//    
//    logic_data              memory[logic_addr];
//    string                  arg_parse_str;
//    string                  code_path;
//
//    // 读取函数 - 如果地址不存在返回0
//    function automatic logic [DATA_WIDTH-1:0] read_memory(logic [ADDR_WIDTH-1:0] address);
//        return memory.exists(address) ? memory[address] : '0;
//    endfunction
//    
//    // 初始化过程
//    initial begin
//        memory.delete();
//        $sformat(arg_parse_str, "%s=%%s", ARGPARSE_KEY);
//        
//        if($value$plusargs(arg_parse_str, code_path)) begin
//            $readmemh(code_path, memory);
//            
//            if($test$plusargs("DEBUG")) begin
//                $display("Memory initialized from file %s", code_path);
//                for(int i=0; i<10; i++) begin
//                    $display("memory row[%0d] = %h", i, read_memory(i));
//                end
//            end
//        end 
//        else begin
//            if(ALLOW_NO_HEX!=0) begin
//                if($test$plusargs("DEBUG"))
//                    $info("No HEX file provided via +%s", ARGPARSE_KEY);
//            end
//            else begin
//                $error("Missing required parameter +%s", ARGPARSE_KEY);
//                $finish;
//            end
//        end
//    end
//
//    // 同步写逻辑
//    always_ff @(posedge clk) begin
//        if(en && wr_en) begin
//            memory[addr] <= wr_data;
//        end
//    end
//    
//    // 同步读逻辑
//    always_ff @(posedge clk) begin
//        if(en && !wr_en) begin
//            rd_data <= read_memory(addr);
//        end
//    end
//    
//    // Debug信息（可选）
//    initial begin
//        if($test$plusargs("DEBUG")) begin
//            forever begin
//                @(posedge clk)
//                if(en)
//                    if(wr_en)
//                        $display("[%s][wr] addr=%h data=%h", ARGPARSE_KEY, addr, wr_data);
//                    else
//                        $display("[%s][rd] addr=%h data=%h", ARGPARSE_KEY, addr, read_memory(addr));
//            end
//        end
//    end
//
//endmodule
//module toy_mem_model_bit #(
//    parameter string            ARGPARSE_KEY    = "HEX" ,
//    parameter integer unsigned  ALLOW_NO_HEX    = 1     ,
//    parameter integer unsigned  ADDR_WIDTH      = 32    ,
//    parameter integer unsigned  DATA_WIDTH      = 32
//) (
//    input  logic                     clk         ,
//    input  logic                     en          ,
//    input  logic [ADDR_WIDTH-1:0]    addr        ,
//    output logic [DATA_WIDTH-1:0]    rd_data     ,
//    input  logic [DATA_WIDTH-1:0]    wr_data     ,
//    // input  logic [DATA_WIDTH/8-1:0]  wr_byte_en  ,
//    input  logic                     wr_en       
//);
//
//    //logic [DATA_WIDTH-1:0] mem [0:1<<10-1];
//
//    typedef logic [ADDR_WIDTH-1:0]    logic_addr   ;
//    typedef logic [DATA_WIDTH-1:0]    logic_data   ;
//
//
//    logic_data              memory[logic_addr]    ;
//    //logic   [35:0]          tmp_data              ;
//    logic [DATA_WIDTH-1:0]  tmp_data             ;
//    string                  arg_parse_str         ;
//    string                  code_path             ;
//
//    function logic_data read_memory(logic_addr address);
//        logic_data data;
//
//        if (memory.exists(address)) begin
//            data = memory[address];
//        end else begin
//            $display("address is %d", address);
//            memory[address] = {DATA_WIDTH{1'b0}};
//            data = {DATA_WIDTH{1'b0}}; 
//        end
//
//        return data;
//    endfunction
//
//
//
//
//    initial begin
//        $sformat(arg_parse_str, "%s=%%s", ARGPARSE_KEY);
//        
//        // memory initialize ===========================================================
//        if($value$plusargs(arg_parse_str, code_path)) begin
//            $readmemh(code_path, memory);
//            if($test$plusargs("DEBUG")) begin
//                $display("print memory first 10 row parse from arg %s:", ARGPARSE_KEY);
//                for(int i=0;i<10;i++) begin
//                    $display("memory row[%0d] = %h" , i, read_memory(i));
//                end
//            end
//        end else begin
//            if(ALLOW_NO_HEX!=0) begin
//                if($test$plusargs("DEBUG"))
//                    $info("Missing required parameter +%s",ARGPARSE_KEY);
//            end
//            else begin
//                $error("Missing required parameter +%s",ARGPARSE_KEY);
//                $finish;
//            end
//        end
//
//        // memory write handler ========================================================
//        forever begin
//            @(posedge clk)
//            if(wr_en && en) begin
//                tmp_data = wr_data;
//                memory[addr] <= tmp_data;
//            end
//        end
//    end
//
//
//    // memory read handler =========================================================
//    initial begin
//        forever begin
//            //#500;
//            @(posedge clk)            
//            if(en && ~wr_en) rd_data = read_memory(addr);
//        end
//    end
//
//
//
//    initial begin
//        if($test$plusargs("DEBUG")) begin
//            forever begin
//                @(posedge clk)
//                if(en)
//                    if(wr_en)
//                        $display("[%s][wr] %h : %h", ARGPARSE_KEY, addr, wr_data    );
//                    else
//                        $display("[%s][rd] %h : %h", ARGPARSE_KEY, addr, read_memory(addr) );
//            end
//        end
//    end
//
//
//
//endmodule
module toy_mem_model_bit #(
    parameter string            ARGPARSE_KEY    = "HEX",
    parameter integer unsigned  ALLOW_NO_HEX    = 1,
    parameter integer unsigned  ADDR_WIDTH      = 32,
    parameter integer unsigned  DATA_WIDTH      = 32
) (
    input  logic                     clk,
    input  logic                     en,
    input  logic [ADDR_WIDTH-1:0]    addr,
    output logic [DATA_WIDTH-1:0]    rd_data,
    input  logic [DATA_WIDTH-1:0]    wr_data,
    input  logic                     wr_en
);

    typedef logic [ADDR_WIDTH-1:0]    logic_addr;
    typedef logic [DATA_WIDTH-1:0]    logic_data;
    
    logic_data              memory[logic_addr];
    string                  arg_parse_str;
    string                  code_path;
    
    bit initialized = 0;
    logic [DATA_WIDTH-1:0] default_value;

    // 添加地址有效性检查函数
    function automatic bit is_valid_address(logic [ADDR_WIDTH-1:0] addr);
        return !(|($isunknown(addr))); // 检查地址是否包含x或z
    endfunction

    // 修改read_memory函数，增加地址检查
    function automatic logic [DATA_WIDTH-1:0] read_memory(logic [ADDR_WIDTH-1:0] address);
        logic [DATA_WIDTH-1:0] data;
        
        if (!initialized || !is_valid_address(address)) begin
            data = '0;
            if ($test$plusargs("DEBUG") && !is_valid_address(address))
                $display("[%m] Warning: Reading from invalid address %h, returning zero", address);
        end
        else begin
            if (!memory.exists(address)) begin
                memory[address] = '0;
                if ($test$plusargs("DEBUG"))
                    $display("[%m] Auto-initializing address %h to zero", address);
            end
            data = memory[address];
        end
        
        return data;
    endfunction

    // 修改write_memory函数，增加地址检查
    function automatic void write_memory(logic [ADDR_WIDTH-1:0] address, logic [DATA_WIDTH-1:0] data);
        if (initialized && is_valid_address(address)) begin
            memory[address] = data;
            if ($test$plusargs("DEBUG"))
                $display("[%m] Writing address %h with data %h", address, data);
        end
        else if ($test$plusargs("DEBUG")) begin
            $display("[%m] Warning: Attempted write to invalid address %h ignored", address);
        end
    endfunction
    
    // 初始化过程
    initial begin
        default_value = '0;
        memory.delete();
        initialized = 0;
        
        $sformat(arg_parse_str, "%s=%%s", ARGPARSE_KEY);
        
        if($value$plusargs(arg_parse_str, code_path)) begin
            if ($test$plusargs("DEBUG"))
                $display("[%m] Loading memory contents from %s", code_path);
            
            $readmemh(code_path, memory);
            
            if($test$plusargs("DEBUG")) begin
                $display("[%m] Memory initialized from file %s", code_path);
                for(int i=0; i<10; i++) begin
                    $display("[%m] memory row[%0d] = %h", i, read_memory(i));
                end
            end
        end 
        else begin
            if(ALLOW_NO_HEX!=0) begin
                if($test$plusargs("DEBUG"))
                    $info("[%m] No HEX file provided via +%s, initializing empty memory", ARGPARSE_KEY);
            end
            else begin
                $error("[%m] Missing required parameter +%s", ARGPARSE_KEY);
                $finish;
            end
        end

        #1 initialized = 1;
        
        if ($test$plusargs("DEBUG"))
            $display("[%m] Memory initialization completed");
    end

    // 同步写逻辑
    always_ff @(posedge clk) begin
        if(en && wr_en) begin
            write_memory(addr, wr_data);
        end
    end
    
    // 同步读逻辑，增加地址检查
    always_ff @(posedge clk) begin
        if(en && !wr_en) begin
            if (is_valid_address(addr)) begin
                rd_data <= read_memory(addr);
            end
            else begin
                rd_data <= '0;
                if ($test$plusargs("DEBUG"))
                    $display("[%m] Warning: Reading invalid address %h", addr);
            end
        end
    end
    
    // Debug监控
    initial begin
        if($test$plusargs("DEBUG")) begin
            forever begin
                @(posedge clk)
                if(en) begin
                    if(wr_en) begin
                        if (is_valid_address(addr))
                            $display("[%m][%s][wr] addr=%h data=%h", ARGPARSE_KEY, addr, wr_data);
                        else
                            $display("[%m][%s][wr] Warning: Invalid address %h", ARGPARSE_KEY, addr);
                    end
                    else begin
                        if (is_valid_address(addr))
                            $display("[%m][%s][rd] addr=%h data=%h", ARGPARSE_KEY, addr, read_memory(addr));
                        else
                            $display("[%m][%s][rd] Warning: Invalid address %h", ARGPARSE_KEY, addr);
                    end
                end
            end
        end
    end

endmodule