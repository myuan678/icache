module bin_reader;
    bit [31:0] data_buffer;
    int file;
    int read_bytes;

    initial begin
        file = $fopen("/data/usr/huangt/toy_model2/trace_replay/align_pc_trace.bin", "rb");
        if (file == 0) begin
            $display("Error: Cannot open file.");
            $finish;
        end

        while (!$feof(file)) begin
            read_bytes = $fread(data_buffer, file);
            if (read_bytes != 4) begin
                $display("Warning: Incomplete read, read %0d bytes.", read_bytes);
                break;
            end

            $display("Read 32-bit value: %h", data_buffer);
        end

        $fclose(file);
    end
endmodule



