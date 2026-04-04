import cpu_pkg::*;
module IDOP2_reg(
    // inputs
    output instruction_bus idop2_ib,
    output logic [15:0] idop2_r_data1,
    output logic [15:0] idop2_r_data2,
    output logic [15:0] idop2_r_data3,
    output logic [15:0] idop2_r_data4,
    output control_bus idop2_cb,
    output logic [15:0] idop2_pcnext,
    output logic [15:0] idop2_pc,
    // outputs
    input instruction_bus ib,
    input logic [15:0] r_data1,
    input logic [15:0] r_data2,
    input logic [15:0] r_data3,
    input logic [15:0] r_data4,
    input control_bus cb,
    input logic [15:0] pc_next,
    input logic [15:0] pc,
    // global
    input logic resetn,
    input logic clk
);
    always_ff @(posedge clk) begin 
        if(!resetn) begin 
            idop2_ib <= 0;
            idop2_r_data1 <= 16'b0;
            idop2_r_data2 <= 16'b0;
            idop2_r_data3 <= 16'b0;
            idop2_r_data4 <= 16'b0;
            idop2_cb <= 0;
            idop2_pcnext <= 0;
            idop2_pc <= 0;
        end
        else begin 
            idop2_ib <= ib;
            idop2_r_data1 <= r_data1;
            idop2_r_data2 <= r_data2;
            idop2_r_data3 <= r_data3;
            idop2_r_data4 <= r_data4;
            idop2_cb <= cb;
            idop2_pcnext <= pc_next;
            idop2_pc <= pc;
        end
    end
endmodule