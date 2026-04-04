module EXDM_reg(
    output instruction_bus exdm_ib,
    output control_bus exdm_cb,
    output logic [15:0] exdm_aludata1,
    output logic [15:0] exdm_aludata2,
    output logic signed [15:0] exdm_outpc,
    output logic [15:0] exdm_rt,
    output logic [15:0] exdm_lr,
    //inputs
    input instruction_bus ib,
    input control_bus cb,
    input logic [15:0] alu_data1,
    input logic [15:0] alu_data2,
    input logic signed [15:0] out_pc,
    input logic [15:0] rt,
    input logic [15:0] lr,
    // global
    input logic clk,
    input logic resetn
);

    always_ff @(posedge clk) begin 
        if(!resetn) begin 
            exdm_ib <= 0;
            exdm_cb <= 0;
            exdm_aludata1 <= 0;
            exdm_aludata2 <= 0;
            exdm_outpc <= 0;
            exdm_rt <= 0;
            exdm_lr <= 0;
        end
        else begin 
            exdm_ib <= ib;
            exdm_cb <= cb;
            exdm_aludata1 <= alu_data1;
            exdm_aludata2 <= alu_data2;
            exdm_outpc <= out_pc;
            exdm_rt <= rt;
            exdm_lr <= lr;
        end
    end

endmodule