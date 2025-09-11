`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 11:00:03 PM
// Design Name: 
// Module Name: main_control_sim
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
package test_vec;
    integer count;
    task count_instr(input string file);
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

    logic [31:0] test_instr[0:255];
    task load_instr(input string file);
        $readmemb(file, test_instr);
    endtask 

    localparam num_control_sigs = 4;
    // ADDX, MULX, DIVX, LDW, LDB2L, LDB2H, STW, STB2L, STB2H, BX
    const int test_opcodes[0:9] = '{
        6'b110000,      // ADDX
        6'b110010,      // MULX
        6'b110011,      // DIVX
        6'b010110,      // LDW
        6'b010000,      // LDB2L
        6'b010010,      // LDB2H
        6'b011110,      // STW
        6'b011000,      // STB2L
        6'b011010,      // STB2H
        6'b001000       // BX
        }; 
    localparam num_opcodes = 10;

    // reg_write1, reg_write2, mem_write, mem2reg, 
    logic [3:0] expected_control_sig[0:9] = '{
        4'b1000,         // ADDX
        4'b1100,         // MULX
        4'b1100,         // DIVX
        4'b1001,         // LDW
        4'b1001,         // LDB2L
        4'b1001,         // LDB2H
        4'b0011,         // STW
        4'b0011,         // STB2L
        4'b0011,         // STB2H
        4'b0000          // BX
    };

    logic [num_control_sigs-1:0] control_sigs[0:num_opcodes];
endpackage

import test_vec::*;
class scoreboard;
    
    function automatic check(
        input logic [31:0] instruction,
        input logic reg_write1,
        input logic reg_write2,
        input logic mem_write,
        input logic mem2reg
    );  
        logic [3:0] act_control = {reg_write1, reg_write2, mem_write, mem2reg};
        logic [3:0] exp_control;
        case(instruction[27:22]) 
            test_opcodes[0]:  // ADDX
            begin 
                exp_control = expected_control_sig[0];
            end
            test_opcodes[1]:  // MULX
            begin 
                exp_control = expected_control_sig[1];
            end
            test_opcodes[2]:  // DIVX
            begin 
                exp_control = expected_control_sig[2];
            end
            test_opcodes[3]:  // LDW
            begin 
                exp_control = expected_control_sig[3];
            end
            test_opcodes[4]:  // LDB2L
            begin 
                exp_control = expected_control_sig[4];
            end
            test_opcodes[5]:  // LDB2H
            begin 
                exp_control = expected_control_sig[5];
            end
            test_opcodes[6]:  // STW
            begin 
                exp_control = expected_control_sig[6];
            end
            test_opcodes[7]:  // STB2L
            begin 
                exp_control = expected_control_sig[7];
            end
            test_opcodes[8]:  // STB2H
            begin 
                exp_control = expected_control_sig[8];
            end
            test_opcodes[9]:  // BX
            begin 
                exp_control = expected_control_sig[9];
            end
            default:        
            begin  
                $display("[ERROR] INVALID CODE");
                exp_control = 4'b1111;
            end
        endcase
        if(act_control == exp_control) begin 
            $display("[PASS] Expected Control: %4b", exp_control);
        end
        else begin 
            $display("[FAIL] Expected Control: %4b | Actual Control: %4b | Instr: %6b", exp_control, act_control, instruction[27:22]);
        end
    endfunction
endclass

module main_control_sim();
    import test_vec::*;
    import cpu_pkg::*;
    logic clk;
    initial begin 
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    

    logic reg_write1, reg_write2, mem_write, mem2reg, i, s_or_u;
    instr_t instr_class;
    operation_t opcode;
    logic alu_en;
    logic [31:0] instruction;
    main_control mcu(
        .reg_write1(reg_write1), 
        .reg_write2(reg_write2), 
        .mem_write(mem_write),
        .mem2reg(mem2reg),
        .i(i),
        .s_or_u(s_or_u),
        .instr_class(instr_class),
        .opcode(opcode),
        .alu_en(alu_en),
        .instruction(instruction)
        );
    scoreboard sb;
    initial begin 
        sb = new();
        count_instr("out.bin");
        @(posedge clk);
        load_instr("out.bin");
        @(posedge clk);
        for(int i = 0; i < count; i++) begin 
            instruction = test_instr[i];
            @(posedge clk);
            sb.check(instruction, reg_write1, reg_write2, mem_write, mem2reg);
        end
    end
endmodule
