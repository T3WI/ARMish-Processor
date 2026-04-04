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
    parameter MEM_SIZE = 256;
    logic [7:0] data_mem[0:255];           // 1 bit valid, 16 bits data
    logic [15:0] output_data;

    initial begin
        $readmemh("datamem.hex", data_mem);
    end
    // top level read logic
    always_ff @(posedge clk) begin 
        if(!reset) begin 
            r_data <= 16'b0;
            for(int i = 0; i < MEM_SIZE; i++) begin 
                data_mem[i] <= 0;
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
                data_mem[addr] <= w_data[15:8];
                data_mem[addr+1] <= w_data[7:0];
            end
            2'b10:
            begin 
                data_mem[addr] <= w_data[15:8];
            end
            2'b01:
            begin 
                data_mem[addr] <= w_data[7:0];
            end
            default: 
            begin 
            end
            endcase
        end
    end

    // read logic
    always_comb begin
        if(mem_read) begin 
            case(byte_sel)
                2'b11:
                begin
                    output_data[15:8] = data_mem[addr];
                    output_data[7:0] = data_mem[addr+1]; 
                end
                2'b10:
                begin 
                    output_data[15:8] = data_mem[addr];
                    output_data[7:0] = 8'h00;
                end
                2'b01:
                begin 
                    output_data[15:8] = 8'h00;
                    output_data[7:0] = data_mem[addr];
                end
                default: 
                begin 
                    output_data = 16'hfff;
                end 
            endcase
        end 
    end
endmodule
