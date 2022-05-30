
import uvm_easy_mam_pkg::*;

program tb_top;
    initial begin
        bit[31:0] alloc_addr,len,used_addr[$];
        uvm_easy_mam     easy_mam= new();

        easy_mam.add_useful_mem("Mem[0]",32'h0000_0000,32'h2FFF_FFFF);
        easy_mam.add_useful_mem("Mem[1]",32'h4000_0000,32'h4FFF_0000);
        easy_mam.add_useful_mem("Mem[2]",32'h8000_0000,32'h8000_FFFF);
        easy_mam.add_useful_mem("Mem[3]",32'hD000_0000,32'hDFFF_FFFF);

        for(int i=0;i<4;i++) begin
            len=$urandom_range(1,10);
            alloc_addr = easy_mam.mem_auto_alloc(len);
            $display("rand memory alloc[%0d]: %0x, len=%0d",i,alloc_addr,len);
            used_addr.push_back(alloc_addr);
        end

        for(int i=0;i<4;i++) begin
            automatic string mem = $sformatf("Mem[%0d]",i);
            len=$urandom_range(1,10);
            alloc_addr = easy_mam.mem_auto_alloc(len,mem);
            used_addr.push_back(alloc_addr);
            $display("%s alloc: %0x, len=%0d",mem,alloc_addr,len);
        end
        foreach(used_addr[i]) easy_mam.mem_release(used_addr[i]);
    end
endprogram
