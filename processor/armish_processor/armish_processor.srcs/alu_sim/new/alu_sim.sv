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

enum logic [31:0] {TEST_111, TEST_112, TEST_1131, TEST_1132, TEST_1133, TEST_114, TEST_115, TEST_12, TEST_13, TEST_14, TEST_151, TEST_152, TEST_1531, TEST_1532, TEST_1533, TEST_154, TEST_155, TEST_16, TEST_17, TEST_18, TEST_19, TEST_110} tests_r;
package alu_pkg;
    shortint data_arith_1[0:15] = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30};
    shortint data_arith_2[0:15] = {12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57};
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
    function automatic check_111_addx(input logic signed [15:0] dut_data1, input logic signed [15:0] dut_data2, input int i);
        shortint sum = data_arith_1[i] + data_arith_2[i];
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end
    endfunction

    function automatic check_111_subx(input logic signed [15:0] dut_data1, input logic signed [15:0] dut_data2, input int i);
        shortint sum = data_arith_1[i] - data_arith_2[i];
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end
    endfunction
    
    function automatic check_112_addx(input logic [3:0] nzcv, input int i);
        logic unsigned [16:0] sum = {1'b0, 16'd32750} + {1'b0, c_data1[i]};
        if(sum[16] == nzcv[1]) begin 
            $display("[PASS] Expected: %d", sum[16]);
        end
        else begin 
            $display("[FAIL] Expected: %d | Actual: %d", sum[16], nzcv[1]);
        end
    endfunction

    function automatic check_112_subx(input logic [3:0] nzcv, input int i);
        logic c = (c_data2[9] >= c_data2[i]) ? 1 : 0;
        if(c == nzcv[1]) begin 
            $display("[PASS] Expected: %b", c);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", c, nzcv[1]);
        end
    endfunction

    function automatic check_1131_addx(input logic [3:0] nzcv, input int i);
        logic [16:0] sum = v_data1[i] + v_data2[i];
        logic v = (sum[15] ^ v_data1[i][15]) & ~(v_data1[i][15] & v_data2[i][15]);
        if(nzcv[0] == v) begin 
            $display("[PASS] Expected: %b", v);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", v, nzcv[0]);
        end
    endfunction 

    function automatic check_1131_subx(input logic [3:0] nzcv, input int i);
        logic [16:0] diff = v_data1[i] - v_data2[i];
        logic v = (diff[15] ^ v_data1[i][15]) & (v_data1[i][15] ^ v_data2[i][15]); 
        if(nzcv[0] == v) begin 
            $display("[PASS] Expected: %b", v);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", v, nzcv[0]);
        end
    endfunction 

    function automatic check_1132_addx(input logic [3:0] nzcv, input int i);
        logic [16:0] sum = v_data3[i] + v_data4[i];
        logic v = (sum[15] ^ v_data3[i][15]) & ~(v_data3[i][15] ^ v_data4[i][15]);
        if(nzcv[0] == v) begin 
            $display("[PASS] Expected: %b", v);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", v, nzcv[0]);
        end
    endfunction

    function automatic check_1132_subx(input logic [3:0] nzcv, input int i);
        logic [16:0] diff = v_data3[i] - v_data4[i];
        logic v = (diff[15] ^ v_data3[i][15]) & (v_data3[i][15] ^ v_data4[i][15]);
        if(nzcv[0] == v) begin 
            $display("[PASS] Expected: %b", v);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", v, nzcv[0]);
        end
    endfunction

    function automatic check_1133_addx(input logic [3:0] nzcv, input int i);
        logic signed [16:0] sum = v_data1[i] + v_data4[i];
        logic v = (sum[15] ^ v_data1[i][15]) & ~(v_data1[i][15] ^ v_data4[i][15]);
        if(nzcv[0] == v) begin 
            $display("[PASS] Expected: %b", v);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", v, nzcv[0]);
        end
    endfunction
    
    function automatic check_1133_subx(input logic [3:0] nzcv, input int i);
        logic signed [16:0] diff = v_data1[i] - v_data4[i];
        logic v = (diff[15] ^ v_data1[i][15]) & (v_data1[i][15] ^ v_data4[i][15]);
        if(nzcv[0] == v) 
        begin 
            $display("[PASS] Expected: %b", v);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", v, nzcv[0]);
        end
    endfunction 

    function automatic check_114_addx(input logic [3:0] nzcv, input int i);
        logic signed [16:0] sum = z_data1[i] + z_data2[i];
        logic z = (sum[15:0] == 0);
        if(nzcv[2] == z) begin 
            $display("[PASS] Expected: %b", z);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", z, nzcv[2]);
        end
    endfunction

    function automatic check_114_subx(input logic [3:0] nzcv, input int i);
        logic signed [16:0] diff = z_data1[i] - z_data2[i];
        logic z = (diff[15:0] == 0);
        if(nzcv[2] == z) begin 
            $display("[PASS] Expected: %b", z);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", z, nzcv[2]);
        end
    endfunction

    function automatic check_115_addx(input logic [3:0] nzcv, input int i);
        logic signed [16:0] sum = n_data1[i] + n_data2[i];
        logic n = (sum[15] == 1);
        if(nzcv[3] == n) begin 
            $display("[PASS] Expected: %b", n);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", n, nzcv[3]);
        end
    endfunction

    function automatic check_115_subx(input logic [3:0] nzcv, input int i);
        logic signed [16:0] diff = n_data1[i] - n_data2[i];
        logic n = (diff[15] == 1);
        if(nzcv[3] == n) begin 
            $display("[PASS] Expected: %b", n);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b", n, nzcv[3]);
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
    
    initial begin
        sb = new();
        en <= 1'b1;
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.1.1 =========="));
        tests_r <= TEST_111;
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            rn = data_arith_1[i];
            rm = data_arith_2[i];
            @(posedge clk);
            sb.check_111_addx(w_data1, w_data2, i);
        end
        @(posedge clk);
        opcode <= SUBX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            rn = data_arith_1[i];
            rm = data_arith_2[i];
            @(posedge clk);
            sb.check_111_subx(w_data1, w_data2, i);
        end
        @(posedge clk);
        $display("%s", $sformatf("========== END OF TEST 1.1.1 =========="));
        $display("%s", $sformatf("========== START OF TEST 1.1.2 =========="));
        tests_r <= TEST_112;
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            rn = 32750;
            rm = c_data1[i];
            @(posedge clk);
            
            sb.check_112_addx(nzcv, i);
        end
         @(posedge clk);
         opcode <= SUBX;
         @(posedge clk);
         for(int i = 0; i < 16; i++) begin 
             rn = c_data2[9];
             rm = c_data2[i];
             @(posedge clk);
             sb.check_112_subx(nzcv, i);
         end
         @(posedge clk);
         $display("%s", $sformatf("========== END OF TEST 1.1.2 =========="));
         $display("%s", $sformatf("========== START OF TEST 1.1.3.1 =========="));
         tests_r <= TEST_1131;
         @(posedge clk);
         opcode <= ADDX;
         Cin <= 1'b0;
         s <= 1'b1;
         @(posedge clk);
         for(int i = 0; i < 16; i++) begin 
            rn = v_data1[i];
            rm = v_data2[i];
            @(posedge clk);
            sb.check_1131_addx(nzcv, i);
         end
         @(posedge clk);
         opcode <= SUBX; 
         for(int i = 0; i < 16; i++) begin 
            rn = v_data1[i];
            rm = v_data2[i];
            @(posedge clk);
            sb.check_1131_subx(nzcv, i);
         end
         @(posedge clk);
         $display("%s", $sformatf("========== END OF TEST 1.1.3.1 =========="));
         $display("%s", $sformatf("========== START OF TEST 1.1.3.2 =========="));
         tests_r <= TEST_1132; 
         @(posedge clk); 
         opcode <= ADDX;
         Cin <= 1'b0;
         s <= 1'b1;
         @(posedge clk); 
         for(int i = 0; i < 16; i++) begin 
            rn = v_data3[i];
            rm = v_data4[i];
            @(posedge clk);
            sb.check_1132_addx(nzcv, i);
         end
        @(posedge clk);
        opcode <= SUBX; 
        for(int i = 0; i < 16; i++) begin 
            rn = v_data3[i];
            rm = v_data3[i];
            @(posedge clk);
            sb.check_1132_subx(nzcv, i);
        end
        @(posedge clk);
        $display("%s", $sformatf("========== END OF TEST 1.1.3.2 =========="));
        $display("%s", $sformatf("========== START OF TEST 1.1.3.3 =========="));
        tests_r <= TEST_1133;
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++)begin 
            rn = v_data1[i];
            rm = v_data4[i];
            @(posedge clk);
            sb.check_1133_addx(nzcv, i);
        end
        @(posedge clk);
        opcode <= SUBX;
        for(int i = 0; i < 16; i++) begin 
            rn = v_data1[i];
            rm = v_data4[i];
            @(posedge clk);
            sb.check_1133_subx(nzcv, i);
        end
        @(posedge clk);
        $display("%s", $sformatf("========== END OF TEST 1.1.3.3 =========="));
        $display("%s", $sformatf("========== START OF TEST 1.1.4 =========="));
        tests_r <= TEST_114;
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            rn = z_data1[i];
            rm = z_data2[i];
            @(posedge clk);
            sb.check_114_addx(nzcv, i);
        end
        @(posedge clk); 
        opcode <= SUBX;
        for(int i = 0; i < 16; i++) begin 
            rn = z_data1[i];
            rm = z_data2[i];
            @(posedge clk);
            sb.check_114_subx(nzcv, i);
        end
        $display("%s", $sformatf("========== END OF TEST 1.1.4 =========="));
        $display("%s", $sformatf("========== START OF TEST 1.1.5 =========="));
        @(posedge clk);
        tests_r <= TEST_115;
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            rn = n_data1[i];
            rm = n_data2[i];
            @(posedge clk);
            sb.check_115_addx(nzcv, i);
        end
        @(posedge clk);
        opcode <= SUBX;
        for(int i = 0; i < 16; i++) begin 
            rn = n_data1[i];
            rm = n_data2[i];
            @(posedge clk);
            sb.check_115_subx(nzcv, i);
        end
        $display("%s", $sformatf("========== END OF TEST 1.1.5 =========="));
        $finish; 
    end
endmodule
