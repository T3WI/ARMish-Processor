`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2025 11:41:47 PM
// Design Name: 
// Module Name: branching_unit_sim
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
package stim;
    logic [9:0] instr_offset_stim[0:15];
    logic [15:0] rb_stim[0:15];
endpackage

import stim::*;
class scoreboard;
    task check_test1(input logic [15:0] lr, input logic [15:0] out_pc, input logic [15:0] pc);
        logic [15:0] exp_lr, exp_out_pc;
        exp_lr =  pc + 4;
        exp_out_pc = pc + 4;
        if(lr == exp_lr && out_pc == exp_out_pc) $display("[PASS] Expected LR: %h | Expected Next PC: %h", exp_lr, exp_out_pc); 
        else $display("[FAIL] Expected LR: %h | Expected Out PC: %h | Actual LR: %h | Actual Out PC: %h", exp_lr, exp_out_pc, lr, out_pc); 
    endtask 

    task check_test2(input logic [15:0] lr, input logic [15:0] out_pc, input logic [15:0] pc, input int i);
        logic [15:0] exp_lr, exp_out_pc;
        exp_lr = pc + 4;
        exp_out_pc = pc + (rb_stim[i] << 2);
        if(lr == exp_lr && out_pc == exp_out_pc) $display("[PASS] Expected LR: %h | Expected Next PC: %h", exp_lr, exp_out_pc); 
        else $display("[FAIL] Expected LR: %h | Expected Out PC: %h | Actual LR: %h | Actual Out PC: %h", exp_lr, exp_out_pc, lr, out_pc); 
    endtask

    task check_test3(input logic [15:0] lr, input logic [15:0] out_pc, input logic [15:0] pc, input int i);
        logic [15:0] exp_lr, exp_out_pc;
        exp_lr = pc + 4;
        exp_out_pc = pc + (instr_offset_stim[i] << 2);
        if(lr == exp_lr && out_pc == exp_out_pc) $display("[PASS] Expected LR: %h | Expected Next PC: %h", exp_lr, exp_out_pc); 
        else $display("[FAIL] Expected LR: %h | Expected Out PC: %h | Actual LR: %h | Actual Out PC: %h", exp_lr, exp_out_pc, lr, out_pc); 
    endtask
endclass

import stim::*;
module branching_unit_sim;
    logic clk;
    initial begin 
        clk = 1'b1;
        forever #10 clk = ~clk; 
    end

    logic [15:0] lr, out_pc, pc, pc_next, rb;
    logic [9:0] instr_offset;
    logic r, branch;
    branching_unit bu(.lr(lr), .out_pc(out_pc), .pc_next(pc_next), .pc(pc), .instr_offset(instr_offset), .rb(rb), .r(r), .branch(branch));

    assign pc_next = pc + 4;
    task initialize_instr_offset();
        for(int i = 0; i < 16; i++) begin 
            instr_offset_stim[i] = 4*i;
        end
    endtask

    task initialize_rb();
        for(int i = 0; i < 16; i++) begin
            rb_stim[i] = 8*i;
        end
    endtask 

    task test1();
        $display("========== TEST 1 ==========");
        branch = 0;
        pc = -4;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            pc = pc + 4;
            rb = rb_stim[i];
            instr_offset = instr_offset_stim[i];
            @(posedge clk);
            sb.check_test1(lr, out_pc, pc);
        end
    endtask 

    task test2();
        $display("========== TEST 2 ==========");
        branch = 1;
        r = 1;
        pc = -4;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            pc = pc + 4;
            rb = rb_stim[i];
            instr_offset = instr_offset_stim[i];
            @(posedge clk);
            sb.check_test2(lr, out_pc, pc, i);
        end
    endtask 

    task test3();
        $display("========== TEST 3 ==========");
        branch = 1;
        r = 0;
        pc = -4;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            pc = pc + 4;
            rb = rb_stim[i];
            instr_offset = instr_offset_stim[i];
            @(posedge clk);
            sb.check_test3(lr, out_pc, pc, i);
        end
    endtask 

    scoreboard sb;
    initial begin 
        pc = 0;
        sb = new();
        initialize_instr_offset();
        initialize_rb();
        @(posedge clk);
        r = 0; 
        branch = 0;
        @(posedge clk);
        test1();
        @(posedge clk);
        test2();
        @(posedge clk);
        test3();
        $finish;
    end
endmodule
