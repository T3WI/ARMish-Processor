import cpu_pkg::*;
module WAIT4DM_reg(
    // OUTPUT SIGNALS
    output instruction_bus w4d_ib,
    output control_bus w4d_cb,
    output logic [15:0] w4d_aludata1,
    output logic [15:0] w4d_aludata2,
    // INPUT SIGNALS
    input instruction_bus ib,
    input control_bus cb,
    input logic [15:0] alu_data1,
    input logic [15:0] alu_data2,
    // GLOBAL SIGNALS
    input clk,
    input resetn
);
    always_ff @(posedge clk) begin 
        if(!resetn) begin 
            w4d_ib <= 0;
            w4d_cb <= 0;
            w4d_aludata1 <= 0;
            w4d_aludata2 <= 0;
        end
        else begin 
            w4d_ib <= ib;
            w4d_cb <= cb;
            w4d_aludata1 <= alu_data1;
            w4d_aludata2 <= alu_data2;
        end
    end
endmodule