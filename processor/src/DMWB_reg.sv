module DMWB_reg(
    // Output Signals
    output instruction_bus dmwb_ib,
    output control_bus dmwb_cb,
    output logic [15:0] dmwb_aludata1,
    output logic [15:0] dmwb_aludata2,
    output logic [15:0] dmwb_memdata,
    // Input signals
    input instruction_bus ib,
    input control_bus cb,
    input logic [15:0] alu_data1,
    input logic [15:0] alu_data2,
    input logic [15:0] mem_data,
    // Global Signals
    input clk,
    input resetn
);
    always_ff@(posedge clk) begin 
        if(!resetn) begin 
            dmwb_ib <= 0;
            dmwb_cb <= 0;
            dmwb_aludata1 <= 0;
            dmwb_aludata2 <= 0;
            dmwb_memdata <= 0;
        end
        else begin 
            dmwb_ib <= ib;
            dmwb_cb <= cb;
            dmwb_aludata1 <= alu_data1;
            dmwb_aludata2 <= alu_data2;
            dmwb_memdata <= mem_data;
        end
    end

endmodule