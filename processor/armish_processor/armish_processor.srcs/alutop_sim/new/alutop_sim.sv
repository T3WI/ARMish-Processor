`timescale 1ns / 1ps
// NOTE: TO USE THIS SIMULATOR, UNCOMMENT THE OUTPUT LABELED "_opcode", AND COMMENT OUT THE INTERNAL SIGNAL LABELED "_opcode" IN alu_top.sv
package alutop_pkg;
    typedef enum logic [1:0] {B, D, RF, RX} cltype_t;
    typedef enum logic [3:0] {ADDX, SUBX, MULX, DIVX, ABSX, ADCX, SBCX, CMPX, NOTX, ANDX, ORRX, XORX, NOOP} operation_t;
    typedef struct packed {
        logic [3:0] cond;
        cltype_t cltype;
        operation_t opcode;
        logic i_bit;
        logic s_bit;
        logic [3:0] rn;        
        logic [3:0] rd;
        logic [11:0] op2;
    } instr_rx;
    typedef struct packed{
        logic [3:0] cond;
        cltype_t cltype;
        operation_t opcode;
        logic i_bit;
        logic s_bit;
        logic [3:0] rn;        
        logic [3:0] rd;
        logic [2:0] r_mode;
        logic [4:0] unused;
        logic [3:0] rm;        
    } instr_rf;
    typedef struct packed {
        logic [3:0] cond;
        cltype_t cltype;
        operation_t opcode;
        logic i_bit;
        logic u_bit;
        logic [3:0] rn;         
        logic [3:0] rt;
        logic [11:0] offset;
    } instr_d;
    typedef struct packed {
        logic [3:0] cond;
        cltype_t cltype;
        operation_t opcode;
        logic r_bit;
        logic l_bit;
        logic [23:0] offset;
    } instr_b;
    localparam SET_SIZE = 256;
    logic signed [15:0] rn_set[0:SET_SIZE - 1];
    logic signed [15:0] rm_set[0:SET_SIZE - 1];
endpackage 

import alutop_pkg::*;
class scoreboard;
    function automatic check(
        input operation_t _opcode,
        input operation_t opcode, 
        input cltype_t [1:0] cltype, 
        input logic u);

        operation_t exp_opcode;
        case(cltype)
            RX: exp_opcode = opcode;
            RF: exp_opcode = NOOP;
            D:  exp_opcode = u ? ADDX : SUBX;
            B:  exp_opcode = NOOP;
        endcase 

        if(_opcode == exp_opcode) begin 
            $display("[PASS] Expected: %s", exp_opcode.name());
        end
        else begin 
            $display("[FAIL] Expected: %s | Actual: %s", exp_opcode.name(), _opcode.name());
        end

    endfunction 
endclass 


import alutop_pkg::*;
module alutop_sim();
    logic clk;
    initial begin 
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    logic [15:0] w_data1, w_data2;
    logic [3:0] nzcv;
    logic [15:0] rn, rm_dec;
    logic s, Cin, en;
    cltype_t instr_class;
    operation_t opcode, _opcode;
    logic u;
    
    

    logic [31:0] instruction_memory[0:255];
    task load_instructions_to_mem(input string file);
        $readmemb(file, instruction_memory);
    endtask 

    integer count;
    task count_instructions(input string file);
        integer file_id;
        string token;
        count = 0;

        file_id = $fopen(file, "r");
        while($fscanf(file_id, "%s", token) == 1) begin
            count++; 
        end

        $fclose(file_id);
        $display("Lines in file: %d", count);
    endtask 

    task generate_vectors();
        for(int i = 0; i < SET_SIZE; i++) begin 
            rn_set[i] = i;
            rm_set[i] = 255 - i;
        end
    endtask 

    task test_rx(scoreboard sb);
        for(int i = 0; i < count; i++) begin 
            rn = rn_set[i];
            rm_dec = rm_set[i];
            s = instruction_memory[i][20];
            Cin = 0;
            en = 1;
            instr_class = cltype_t'(instruction_memory[i][27:26]);
            opcode = operation_t'(instruction_memory[i][25:22]);
            u = 0;
            @(posedge clk);
            if(instr_class == RX)
                sb.check(_opcode, opcode, instr_class, u);
        end
    endtask 

    task test_d(scoreboard sb);
        for(int i = 0; i < count; i++) begin 
            rn = rn_set[i];
            rm_dec = rm_set[i];
            s = 0;
            Cin = 0;
            en = 1;
            instr_class = cltype_t'(instruction_memory[i][27:26]);
            opcode = operation_t'(instruction_memory[i][25:22]);
            u = instruction_memory[i][20];
            @(posedge clk);
            if(instr_class == D)
                sb.check(_opcode, opcode, instr_class, u);
        end
    endtask 
    
    task test_b(scoreboard sb);
        for(int i = 0; i < count; i++) begin 
            rn = rn_set[i];
            rm_dec = rm_set[i];
            s = 0;
            Cin = 0;
            en = 1;
            instr_class = cltype_t'(instruction_memory[i][27:26]);
            opcode = operation_t'(instruction_memory[i][25:22]);
            u = 0;
            @(posedge clk);
            if(instr_class == B)
                sb.check(_opcode, opcode, instr_class, u);
        end
    endtask

    alu_top at( ._opcode(_opcode),
                .w_data1(w_data1), 
                .w_data2(w_data2), 
                .nzcv(nzcv), 
                .rn(rn), 
                .rm_dec(rm_dec), 
                .s(s), 
                .Cin(Cin), 
                .en(en), 
                .instr_class(instr_class), 
                .opcode(opcode), 
                .u(u));


    task run_program_lite(input string file);
        scoreboard sb;
        load_instructions_to_mem(file);
        @(posedge clk);
        count_instructions(file);
        @(posedge clk);
        generate_vectors();
        @(posedge clk);
        $display("========== TEST RX ==========");
        test_rx(sb);
        @(posedge clk);
        $display("========== TEST D ==========");
        test_d(sb);
        @(posedge clk);
        $display("========== TEST B ==========");
        test_b(sb);
        @(posedge clk);
    endtask 


    initial begin : main 
        run_program_lite("out.bin");
        $finish;
    end
endmodule
