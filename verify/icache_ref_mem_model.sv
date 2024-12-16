class mem_model;
    bit[255:0] mem[bit[31:0]]; 

    //function write_mem(bit[31:0] addr);
    //    for(int i=0;i<8;i++)begin
    //        mem[addr][i*32+:32] = $urandom(addr+i);
    //    end
    //    $display(" [MEM_MODEL]  WRITE mem[%0h]=%h", addr,mem[addr]);
    //endfunction


    function read_mem(bit[31:0] addr);
        bit [255:0] data;
        //data = mem[addr];
        if (mem.exists(addr)) begin
            data = mem[addr];
        end else begin
            for(int i=0;i<8;i++)begin
                mem[addr][i*32+:32] = $urandom(addr+i);
                data[i*32+:32] = mem[addr][i*32+:32];
            end
            //mem[addr] = $urandom(addr);
            //data = mem[addr];
        end
        $display("[MEM_MODEL] READ mem[%0h]=%h", addr,data);

        return data;
    endfunction
endclass
