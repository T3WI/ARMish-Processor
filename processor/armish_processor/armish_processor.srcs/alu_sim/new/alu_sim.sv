`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2025 03:18:29 PM
// Design Name: 
// Module Name: alu_sim
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

enum logic [31:0] {START, TEST_1_1_1, TEST_1_1_2, TEST_1_1_3_1, TEST_1_1_3_2, TEST_1_1_3_3, TEST_1_1_4, TEST_1_1_5, TEST_1_2, TEST_1_3, TEST_1_4, TEST_1_5_1, TEST_1_5_2, TEST_1_5_3_1, TEST_1_5_3_2, TEST_1_5_3_3, TEST_1_5_4, TEST_1_5_5, TEST_1_6, TEST_1_7, TEST_1_8, TEST_1_9, TEST_1_1_0} tests_r;
package alu_pkg;
    logic [15:0] data_arith_1[0:15] = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30};
    logic [15:0] data_arith_2[0:15] = {12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57};
    logic [15:0] c_data1[0:15] = {16'h0000, 16'h0005, 16'h000a, 16'h000f, 16'h0014, 16'h0019, 16'h001e, 16'h0023, 16'hffe0, 16'hffe5, 16'hffea, 16'hffee, 16'hfff0, 16'hfff5, 16'hfffa, 16'hfffe};
    logic [15:0] c_data2[0:15] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    logic [15:0] v_data1[0:15] = {10, 20, 30, 40, 50, 60, 70, 80, 10000, 10000, 10000, 10000, 30000, 31000, 32000, 32500};
    logic [15:0] v_data2[0:15] = {500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 22766, 22767, 22768, 22769, 22770, 25000, 27500, 30000};
    logic [15:0] v_data3[0:15] = {-10, -20, -30, -40, -50, -60, -70, 80, -10000, -10000, -10000, -10000, -30000, -31000, -32000, -32500};
    logic [15:0] v_data4[0:15] = {-500, -1000, -1500, -2000, -2500, -3000, -3500, -4000, -22767, -22768, -22769, -22770, -22771, -25000, -27500, -30000};
    logic [15:0] z_data1[0:15] = {-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7};
    logic [15:0] z_data2[0:15] = {8, 7, 6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, -5, -6, -7};
    logic [15:0] n_data1[0:15] = {-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7};
    logic [15:0] n_data2[0:15] = {8, 7, 4, 3, -9, -10, -2, -1, 0, 1, 2, -6, -7, -2, -3, -7};

endpackage

import alu_pkg::*;
class alu_sb;
    function automatic check_nzcv(input logic [3:0] nzcv, input logic [15:0] data1, input logic [15:0] data2, input logic [3:0] opcode);
        logic [3:0] result = 4'd0;
        
        case(opcode)
            ADDX: 
            begin
                logic [16:0] sum = data1 + data2; 
                result[3] = sum[15];
                result[2] = (sum[15:0] == 0);
                result[1] = sum[16];
                result[0] = ~(data1[15] ^ data2[15]) & (sum[15] ^ data1[15]);
            end
            SUBX: 
            begin 
                logic [16:0] diff = data1 - data2;
                result[3] = diff[15];
                result[2] = (diff[15:0] == 0);
                result[1] = (data1 >= data2);
                result[0] = (data1[15] ^ data2[15]) & (diff[15] ^ data1[15]);
            end
            default: 
                result = 4'd0;
        endcase
            if(nzcv == result) begin
                $display("[PASS] Expected NZCV: %4b", result); 
            end
            else begin 
                $display("[FAIL] Expected NZCV : %4b | Actual NZCV: %4b", result, nzcv);
            end
    endfunction 

    function automatic check_addx(input logic signed [15:0] dut_data1, input logic signed [15:0] dut_data2, input logic signed[15:0] exp_data1, input logic signed[15:0] exp_data2, input int i);
        shortint sum = exp_data1 + exp_data2;
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end
    endfunction

    function automatic check_subx(input logic signed [15:0] dut_data1, input logic signed [15:0] dut_data2, input logic signed[15:0] exp_data1, input logic signed[15:0] exp_data2, input int i);
        shortint sum = exp_data1 - exp_data2;
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end
    endfunction
endclass

import alu_pkg::*;
module alu_sim();
    logic [15:0] w_data1, w_data2, rn, rm;
    logic [3:0] nzcv;
    operation_t opcode;
    logic en, Cin, s, clk;

    alu a(.w_data1(w_data1), .w_data2(w_data2), .nzcv(nzcv), .rn(rn), .rm(rm), .opcode(opcode), .en(en), .Cin(Cin), .s(s));

    alu_sb sb;

    initial begin 
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    shortint test_int1, test_int2;

    // enum logic [31:0] {TEST_111=1, TEST_112, TEST_1131, TEST_1132, TEST_1133, TEST_114, TEST_115, TEST_12, TEST_13, TEST_14, TEST_151, TEST_152, TEST_1531, TEST_1532, TEST_1533, TEST_154, TEST_155, TEST_16, TEST_17, TEST_18, TEST_19, TEST_110} tests_r;

    function automatic string replace_underscores(input string s);
        string result = "";
        for(int i = 0; i < s.len(); i++) begin 
            if(s[i] == "_") begin 
                result = {result, "."};
            end
            else begin
                result = {result, s[i]};
            end            
        end
        return result;
    endfunction
   

    task run_addx_subx_test(input alu_sb sb, 
        input logic [15:0] data1[0:15], 
        input logic [15:0] data2[0:15]);
        string start_msg, end_msg;
        tests_r <= tests_r.next();
        @(posedge clk);       
        start_msg = $sformatf("========== START OF %s ==========", tests_r.name());
        start_msg = replace_underscores(start_msg);
        $display("%s", start_msg);
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin
            rn = data1[i];
            rm = data2[i]; 
            @(posedge clk);
            sb.check_addx(w_data1, w_data2, data1[i], data2[i], i);
            sb.check_nzcv(nzcv, data1[i], data2[i], opcode);
        end
        @(posedge clk);
        opcode <= SUBX;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin
            rn = data1[i];
            rm = data2[i]; 
            @(posedge clk);
            sb.check_subx(w_data1, w_data2, data1[i], data2[i], i);
            sb.check_nzcv(nzcv, data1[i], data2[i], opcode);
        end
        @(posedge clk);
        end_msg = $sformatf("========== END OF %s ==========", tests_r.name());
        end_msg = replace_underscores(end_msg);
        $display("%s", end_msg);
    endtask
    
    
    initial begin
        sb = new();
        en <= 1'b1;
        tests_r <= tests_r.first();
        @(posedge clk);
        run_addx_subx_test(sb, data_arith_1, data_arith_2);
        @(posedge clk);
        run_addx_subx_test(sb, c_data1, c_data2);
        @(posedge clk);
        run_addx_subx_test(sb, v_data1, v_data2);
        @(posedge clk);
        run_addx_subx_test(sb, v_data3, v_data4);
        @(posedge clk);
        run_addx_subx_test(sb, v_data1, v_data4);
        @(posedge clk);
        run_addx_subx_test(sb, z_data1, z_data2);
        @(posedge clk);
        run_addx_subx_test(sb, n_data1, n_data2);
        @(posedge clk);
        $finish; 
    end
endmodule
