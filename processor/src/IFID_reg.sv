module IFID_reg(
    // outputs
    output logic [31:0] ifid_instruction,
    output logic [15:0] ifid_pc_next,
    output logic [15:0] ifid_pc,

    // inputs
    input logic [31:0] instruction,
    input logic [15:0] pc_next,
    input logic [15:0] pc,
    // control
    input logic stall,

    // global signals
    input logic clk,
    input logic resetn
);
    always_ff@(posedge clk) begin 
        if(!resetn) begin 
            ifid_instruction <= 32'b0;
            ifid_pc_next <= 0;
            ifid_pc <= 0;
        end
        else if(stall) begin
            ifid_instruction <= ifid_instruction;
            ifid_pc_next <= ifid_pc_next;
            ifid_pc <= ifid_pc; 
        end
        else begin 
            ifid_instruction <= instruction;
            ifid_pc_next <= pc_next;
            ifid_pc <= pc;
        end
    end
endmodule