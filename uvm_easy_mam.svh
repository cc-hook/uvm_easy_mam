
import uvm_pkg::*;
`include "uvm_macros.svh"

class uvm_easy_mam;
    protected string m_name;
    protected uvm_mem_mam:: alloc_mode_e m_alloc_mode;
    protected uvm_mem_mam     mem_mam[string];
    protected uvm_mem_region  used_region[bit[31:0]];

    function new(string name="uvm_easy_mam");
        m_name = name;
        m_alloc_mode = uvm_mem_mam::GREEDY;
        used_region.delete();
        mem_mam.delete();
    endfunction

    //add useful memory,
    virtual function void add_useful_mem(input string mem_name,
                                         input bit[31:0] start_addr,
                                         input bit[31:0] end_addr,
                                         input int n_bytes=1);
        uvm_mem_mam     new_mam;
        uvm_mem_mam_cfg mem_info = new();

        mem_info.n_bytes     =n_bytes;
        mem_info.mode        =m_alloc_mode;
        mem_info.start_offset=start_addr;
        mem_info.end_offset  =end_addr;
        new_mam = new(mem_name,mem_info);
        mem_mam[mem_name] = new_mam;
    endfunction

    //memory rand alloc by len
    virtual function bit[31:0] mem_auto_alloc(input bit[31:0] len,
                                              input string mem_name="",
                                              uvm_mem_mam_policy    alloc = null);
        string alloc_mem_name;                                          
        bit[31:0] alloc_addr;
        uvm_mem_region  alloc_region;
        if(mem_name!="") alloc_mem_name = mem_name;
        else if(mem_mam.size()>0) begin
            string str_list[$];
            int idx=$urandom_range(0,mem_mam.num()-1);
            foreach(mem_mam[i]) str_list.push_back(i);
            alloc_mem_name = str_list[idx];
        end else begin
            $display("mem_auto_alloc: please add useful memory first....");
            $finish();
        end
        alloc_region = mem_mam[alloc_mem_name].request_region(len,alloc);
        alloc_addr =  alloc_region.get_start_offset();
        used_region[alloc_addr] = alloc_region;
        return alloc_addr;
    endfunction

    //memory rand alloc by len
    virtual function void mem_release(input bit[31:0] addr);
        string release_mem_name=match_mem_by_addr(addr);

        if(release_mem_name=="") begin
            $display("mem_release: %0x not match any useful mem, please check...",addr);
            $finish();
        end
        if(!used_region.exists(addr)) begin
            $display("mem_release: %0x not exists in used_region, please check...",addr);
            $finish();
        end

        mem_mam[release_mem_name].release_region(used_region[addr]);
        $display("mem_release: %0x ~ %0x",addr,used_region[addr].get_end_offset());
        used_region.delete(addr);
    endfunction

    virtual function string match_mem_by_addr(input bit[31:0] addr);
        bit[31:0] start_addr,end_addr;
        uvm_mem_mam_cfg tmp_cfg;
        foreach(mem_mam[i]) begin
            tmp_cfg = mem_mam[i].reconfigure();
            start_addr=tmp_cfg.start_offset;
            end_addr  =tmp_cfg.end_offset;
            if((addr>=start_addr) && (addr<=end_addr)) begin
                return i;
            end 
        end
        return "";
    endfunction
endclass
