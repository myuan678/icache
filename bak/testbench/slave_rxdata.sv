initial begin
    forever begin
        @(posedge clk);
        if(txreq_q.size()>0)begin
                rxdat_delay     = $urandom_range(5, 10);
                repeat(rxdat_delay)@(posedge clk);
                txreq = txreq_q.pop_front();
                txreq_entry_id = txreq_entry_id_q.pop_front();
                downstream_rxdat_vld                            <= 1;
                downstream_rxdat_pld.downstream_rxdat_opcode    <= txreq.opcode;
                downstream_rxdat_pld.downstream_rxdat_txnid     <= txreq.txnid;
                downstream_rxdat_pld.downstream_rxdat_data      <= txreq.addr;
                downstream_rxdat_pld.downstream_rxdat_entry_idx <= txreq_entry_id;
                $display("downstream_rxdat = %h   %t, nid=%0h,remain pkt=%0d",txreq.addr,$realtime,txreq.txnid,txreq_q.size() );
                do begin
                    @(posedge clk);
                end while(downstream_rxdat_rdy!==1'b1);
                rx_dat_cnt++;
                downstream_rxdat_vld                            <=   0;
                downstream_rxdat_pld.downstream_rxdat_opcode    <= 'b0;
                downstream_rxdat_pld.downstream_rxdat_txnid     <= 'b0;
                downstream_rxdat_pld.downstream_rxdat_data      <= 'b0;
                downstream_rxdat_pld.downstream_rxdat_entry_idx <= 'b0;           
        end
    end
end

////////////out of order rx data gen/////////////////
//initial begin
//    int random_index;
//    forever begin
//        @(posedge clk);
//        if(txreq_q.size()>0)begin
//                rxdat_delay     = $urandom_range(20, 21);
//                repeat(rxdat_delay)@(posedge clk);
//                random_index = $urandom_range(0,txreq_q.size()-1);
//                txreq = txreq_q[random_index];
//                txreq_entry_id = txreq_entry_id_q[random_index];
//                txreq_q.delete(random_index);
//                txreq_entry_id_q.delete(random_index);
//
//                //txreq = txreq_q.pop_front();
//                //txreq_entry_id = txreq_entry_id_q.pop_front();
//                downstream_rxdat_vld                            <= 1;
//                downstream_rxdat_pld.downstream_rxdat_opcode    <= txreq.opcode;
//                downstream_rxdat_pld.downstream_rxdat_txnid     <= txreq.txnid;
//                downstream_rxdat_pld.downstream_rxdat_data      <= txreq.addr;
//                downstream_rxdat_pld.downstream_rxdat_entry_idx <= txreq_entry_id;
//                $display("downstream_rxdat = %h   %t, nid=%0h,remain pkt=%0d",txreq.addr,$realtime,txreq.txnid,txreq_q.size() );
//                do begin
//                    @(posedge clk);
//                end while(downstream_rxdat_rdy!==1'b1);
//                rx_dat_cnt++;
//                downstream_rxdat_vld                            <=  0;
//                downstream_rxdat_pld.downstream_rxdat_opcode    <= 'b0;
//                downstream_rxdat_pld.downstream_rxdat_txnid     <= 'b0;
//                downstream_rxdat_pld.downstream_rxdat_data      <= 'b0;
//                downstream_rxdat_pld.downstream_rxdat_entry_idx <= 'b0;           
//        end
//    end
//end

