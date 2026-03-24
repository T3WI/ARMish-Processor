module data_memory(
    output logic [15:0] r_data,
    input logic [15:0] w_data,
    input logic [15:0] addr,
    input logic mem_write,
    input logic mem_read,
    input logic [1:0] byte_sel,
    input logic clk,
    input logic reset
    );
    import cpu_pkg::mem_loc_t;
    parameter MEM_SIZE = 256;
    mem_loc_t data_mem[0:255];           // 1 bit valid, 16 bits data
    logic [15:0] output_data;

    // top level read logic
    always_ff @(posedge clk) begin 
        if(reset) begin 
            r_data <= 16'b0;
            for(int i = 0; i < MEM_SIZE; i++) begin 
                data_mem[i].data <= 0;
                data_mem[i].valid <= 0;
            end
        end
        else begin 
            if (mem_read) begin 
                r_data <= output_data;
            end
            else begin 
                r_data <= 4'b0;
            end
        end
    end

    // write logic
    always_ff @(posedge clk) begin 
        if(mem_write) begin 
            case(byte_sel) 
            2'b11: 
            begin 
                data_mem[addr].data <= w_data[15:8];
                data_mem[addr+1].data <= w_data[7:0];
                data_mem[addr].valid <= 1;
                data_mem[addr+1].valid <= 1;
            end
            2'b10:
            begin 
                data_mem[addr].data <= w_data[15:8];
                data_mem[addr].valid <= 1;
            end
            2'b01:
            begin 
                data_mem[addr].data <= w_data[7:0];
                data_mem[addr].valid <= 1;
            end
            default: 
            begin 
            end
            endcase
        end
    end

    // read logic
    logic v1, v2;
    assign v1 = data_mem[addr].valid;
    assign v2 = data_mem[addr+1].valid;
    always_comb begin
        if(mem_read) begin 
            case(byte_sel)
                2'b11:
                begin
                    output_data[15:8] = v1 ? data_mem[addr].data : 8'hff;
                    output_data[7:0] = v2 ? data_mem[addr+1].data : 8'hff; 
                end
                2'b10:
                begin 
                    output_data[15:8] = v1 ? data_mem[addr].data : 8'hff;
                    output_data[7:0] = 8'h00;
                end
                2'b01:
                begin 
                    output_data[15:8] = 8'h00;
                    output_data[7:0] = v1 ? data_mem[addr].data : 8'hff;
                end
                default: 
                begin 
                    output_data = 16'hfff;
                end 
            endcase
        end 
    end
endmodule
