module OP2EX_reg(
    // outputs
    output instruction_bus op2ex_ib,
    output control_bus op2ex_cb,
    output logic [15:0] op2ex_rmdec,
    output logic [15:0] op2ex_rn,
    output logic [15:0] op2ex_pcnext,
    output logic [15:0] op2ex_pc,
    output logic [15:0] op2ex_rm,
    output logic [15:0] op2ex_rt,
    //inputs
    input instruction_bus ib,
    input control_bus cb,
    input logic [15:0] rm_dec,
    input logic [15:0] rn,
    input logic [15:0] pc_next,
    input logic [15:0] pc,
    input logic [15:0] rm,
    input logic [15:0] rt,
    // global
    input logic clk,
    input logic resetn
);
    always_ff @(posedge clk) begin 
        if(!resetn) begin 
            op2ex_ib <= 0;
            op2ex_cb <= 0;
            op2ex_rmdec <= 0;
            op2ex_rn <= 0;
            op2ex_pcnext <= 0;
            op2ex_pc <= 0;
            op2ex_rm <= 0;
            op2ex_rt <= 0;
        end
        else begin 
            op2ex_ib <= ib;
            op2ex_cb <= cb;
            op2ex_rmdec <= rm_dec;
            op2ex_rn <= rn;
            op2ex_pcnext <= pc_next;
            op2ex_pc <= pc;
            op2ex_rm <= rm;
            op2ex_rt <= rt;
        end
    end
endmodule