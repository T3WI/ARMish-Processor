`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2025 05:04:04 PM
// Design Name: 
// Module Name: op2dec_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

typedef struct packed{
    logic [31:0] instr;
    logic [3:0] cond;
    logic [1:0] instr_type;
    logic [3:0] opcode;
    logic i;
    logic s;
    logic rn;
    logic rd;
    logic [11:0] op2;
}instr_bus_rx_t;

typedef struct packed{
    logic [3:0] rot;
    logic [7:0] imm8;
}op2_imm;

typedef struct packed{
    logic [1:0] shtype;
    logic [3:0] shamt;
    logic r_shift;
    logic [15:0] rm;            // in an actual instruction, this should be 4 bits. For testing, directly use 16 bit data values from rm_set
}op2_reg_shamt;

typedef struct packed{
    logic [1:0] shtype;
    logic [15:0] rs;            // same as rm reasoning
    logic r_shift;
    logic [15:0] rm;            // in an actual instruction, this should be 4 bits. For testing, directly use 16 bit data values from rm_set
}op2_reg_rs;


package op2dec_pkg;
    logic [15:0] rm_set[0:15] = {0, 2, 4, 6, 8, 10, 12, 14, 16, 10000, 12000, 14000, 16000, 18000, 20000, 23456};
    logic [15:0] rs_set[0:15] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
endpackage

class op2dec_sb;
    enum logic [1:0] {ROR=2'd0, ASR=2'd1, LSR=2'd2, LSL=2'd3} shtype_t;
    function logic [15:0] ror(input logic [15:0] imm, input logic [3:0] shift_amount);
        ror = (imm >> shift_amount) | (imm << (16 - shift_amount)); 
    endfunction 

    function logic [15:0] asr(input logic [15:0] imm, input logic [3:0] shift_amount);
        asr = imm >>> shift_amount;
    endfunction 

    function logic [15:0] lsr(input logic [15:0] imm, input logic [3:0] shift_amount);
        lsr = imm >> shift_amount;
    endfunction 

    function logic [15:0] lsl(input logic [15:0] imm, input logic [3:0] shift_amount);
        lsl = imm << shift_amount;
    endfunction 

     function check_op2_imm(
        input logic [15:0] rm_dec, 
        input logic [7:0] imm_m, 
        input logic [3:0] rot_m);
        // TODO
        logic [15:0] exp_rm = ror(imm_m, rot_m);
        if(rm_dec == exp_rm) begin
            $display("[PASS] Expected: %d", exp_rm); 
        end
        else begin 
            $display("[FAIL] Expected: %16d | Actual: %16d", exp_rm, rm_dec);
        end
    endfunction

    // sb.check_op2_reg_shamt(rm_dec, rm, i, shtype, r_shift, shamt);
    function automatic check_op2_reg(
        input logic [15:0] rm_dec,
        input logic [15:0] rm,
        input logic [1:0] shtype,
        input logic r_shift,
        input logic rs,
        input logic [3:0] shamt
    );
        logic [15:0] shift_value, exp_rm;
        if(r_shift) begin 
            shift_value = rs;
        end
        else begin
            shift_value = shamt;
        end
        case(shtype)
            ROR: exp_rm = ror(rm, shift_value);
            ASR: exp_rm = asr(rm, shift_value);
            LSR: exp_rm = lsr(rm, shift_value);
            LSL: exp_rm = lsl(rm, shift_value);
            default: exp_rm = 16'd0;
        endcase
        if(rm_dec == exp_rm) begin 
            $display("[PASS] Expected: %16d", exp_rm);
        end
        else begin 
            $display("[FAIL] Expected: %16d | Actual: %16d", exp_rm, rm_dec);
        end 
    endfunction
endclass

import op2dec_pkg::*;
module op2dec_sim();
    enum logic [10:0] {START, TEST_1_1, TEST_1_2_1, TEST_1_2_2_1, TEST_1_2_2_2, TEST_1_2_2_3, TEST_1_2_2_4, TEST_1_2_3_1, TEST_1_2_3_2, TEST_1_2_3_3, TEST_1_2_3_4} tests; 

    logic clk;
    initial begin
        clk =1'b0;
        forever #10 clk = ~clk;
    end
    
    logic [15:0] rm_dec, rm, rs;
    logic [7:0] imm_m;
    logic [3:0] rot_m, shamt;
    logic [1:0] shtype;
    logic i, r_shift;

    logic [31:0] instr_mem [0:255];
    task load_from_file(input string file);
        $readmemb(file, instr_mem);
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
        $display("Lines in file: %0d", count);
    endtask 

    instr_bus_rx_t instructions[0:255];
    task load_from_mem();
        for(int j = 0; j < count; j++) begin
            instructions[j].instr = instr_mem[j]; 
            instructions[j].cond = instr_mem[j][31:28];
            instructions[j].instr_type = instr_mem[j][27:26];
            instructions[j].opcode = instr_mem[j][25:22];
            instructions[j].i = instr_mem[j][21];
            instructions[j].s = instr_mem[j][20];
            instructions[j].rn = instr_mem[j][19:16];
            instructions[j].rd = instr_mem[j][15:12];
            instructions[j].op2 = instr_mem[j][11:0];
        end
    endtask 

    op2_imm op2_imm_mem[0:255];
    task load_op2_imm();
        for(int j = 0; j < count; j++) begin 
            op2_imm_mem[j].rot = instructions[j].op2[11:8];
            op2_imm_mem[j].imm8 = instructions[j].op2[7:0];
        end
    endtask 

    
    op2_reg_shamt op2_reg_shamt_mem[0:255];
    task load_op2_reg_shamt();
        for(int j = 0; j < count; j++) begin 
            op2_reg_shamt_mem[j].shtype = instructions[j].op2[11:10];
            op2_reg_shamt_mem[j].shamt = instructions[j].op2[9:6];
            op2_reg_shamt_mem[j].r_shift = instructions[j].op2[5];
            op2_reg_shamt_mem[j].rm = rm_set[j];
        end
    endtask 

    task clear_memories();
        for(int j = 0; j < 256; j++) begin 
            instructions[j] = 0;
            op2_imm_mem [j] = 0;
        end
    endtask 

    op2dec_sb sb;

    function automatic string replace_underscores(input string s);
        string result = "";
        for(int j = 0; j < s.len(); j++) begin 
            if(s[j] == "_") begin 
                result = {result, "."};
            end
            else begin 
                result = {result, s[j]};
            end
        end
        return result;
    endfunction

    task test_header();
        string start_msg;
        tests <= tests.next();
        @(posedge clk);
        start_msg = $sformatf("========== START OF %s ==========", tests.name());
        start_msg = replace_underscores(start_msg);
        $display("%s", start_msg);
    endtask 

    task test_footer();
        string end_msg;
        end_msg = $sformatf("========== END OF %s ==========", tests.name());
        end_msg = replace_underscores(end_msg);
        $display("%s", end_msg);
    endtask 

    task test_11();
        test_header();
        @(posedge clk);
        load_from_file("op2dec_rm_immediate.bin");
        @(posedge clk);
        count_instructions("op2dec_rm_immediate.bin");
        @(posedge clk);
        load_from_mem();
        @(posedge clk);
        load_op2_imm();
        @(posedge clk);
        for(int j = 0; j < count; j++) begin 
            imm_m = op2_imm_mem[j].imm8;
            rot_m = op2_imm_mem[j].rot;
            rm = rm_set[j];
            i = instructions[j].i;
            shtype = op2_imm_mem[j][11:10];     // uses the same op2, but takes meaningless bits
            r_shift = op2_imm_mem[j][4];        // meaningless
            rs = rs_set[j];                     // meaningless
            shamt = op2_imm_mem[j][9:6];        // meaningless
            @(posedge clk);
            sb.check_op2_imm(rm_dec, imm_m, rot_m);
        end
        @(posedge clk);
        clear_memories();
        @(posedge clk);
        test_footer();
    endtask 

    task test_121();
        test_header();
        @(posedge clk);
        load_from_file("op2dec_rm.bin");
        @(posedge clk);
        count_instructions("op2dec_rm.bin");
        @(posedge clk);
        load_from_mem();
        @(posedge clk);
        load_op2_reg_shamt();
        @(posedge clk);
        for(int j = 0; j < count; j++) begin 
            imm_m = op2_reg_shamt_mem[j][11:8];     // meaningless
            rot_m = op2_reg_shamt_mem[j][7:0];
            rm = rm_set[j];
            i = instructions[j].i;
            shtype = op2_reg_shamt_mem[j].shtype;
            r_shift = op2_reg_shamt_mem[j].r_shift;
            rs = rs_set[j];
            shamt = op2_reg_shamt_mem[j].shamt;
            @(posedge clk);
            sb.check_op2_reg(rm_dec, rm, shtype, r_shift, rs, shamt);
        end
        @(posedge clk);
        clear_memories();
        @(posedge clk);
        test_footer();
    endtask

    op2_decode od(.rm_dec(rm_dec), .rm(rm), .rs(rs), .imm_m(imm_m), .shamt(shamt), .rot_m(rot_m), .shtype(shtype), .i(i), .r_shift(r_shift));

    initial begin 
        tests <= START;
        @(posedge clk);
        test_11();
        @(posedge clk);
        test_121();
        @(posedge clk);
        $finish;
    end
endmodule
