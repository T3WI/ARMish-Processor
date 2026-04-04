import cpu_pkg::*;
typedef struct {
    instr_t instr_type;
    union {
        operation_t operation;
        mem_op_t memop;
        branch_op_t branchop;
    } op_t;
} sim_instruction;
module tb_top();
    logic clk, resetn;
    initial begin 
        clk = 1'b0;
        resetn = 1'b0;
        @(posedge clk);
        @(posedge clk);
        resetn = 1'b1;
    end
    always #10 clk = ~clk;

    logic [31:0] debug_instruction;
    sim_instruction sim_debug_instruction;
    always @(*) begin 
        sim_debug_instruction.instr_type = instr_t'(debug_instruction[27:26]);
        if(sim_debug_instruction.instr_type == RX) begin 
            sim_debug_instruction.op_t.operation = operation_t'(debug_instruction[25:22]);
        end
        else if(sim_debug_instruction.instr_type == D) begin 
            sim_debug_instruction.op_t.memop = mem_op_t'(debug_instruction[25:23]);
        end
        else if(sim_debug_instruction.instr_type == B) begin 
            sim_debug_instruction.op_t.branchop = branch_op_t'(debug_instruction[25:24]);
        end
        else begin 
            $display("INVALID INSTRUCTION!");
        end
    end
    top t(
        .debug_instruction(debug_instruction),
        .CLK(clk),
        .RESETN(resetn)
    );

    initial begin 
        repeat (3) @(posedge clk);
        for(int i = 0; i < 50; i++) begin
            case(sim_debug_instruction.instr_type)
                RX: $display("Instruction %d: %s", i, sim_debug_instruction.op_t.operation.name());
                D:  $display("Instruction %d: %s", i, sim_debug_instruction.op_t.memop.name());
                B:  $display("Instruction %d: %s", i, sim_debug_instruction.op_t.branchop.name());

            endcase
            @(posedge clk);
        end
        @(posedge clk);
        $finish;
    end

endmodule