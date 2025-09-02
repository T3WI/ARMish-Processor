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

enum logic [63:0] {START, TEST_1_1_1, TEST_1_1_2, TEST_1_1_3_1, TEST_1_1_3_2, TEST_1_1_3_3, TEST_1_1_4, TEST_1_1_5, TEST_1_2_1, TEST_1_2_2, TEST_1_2_3, TEST_1_2_4, TEST_1_3, TEST_1_4_1, TEST_1_4_2, TEST_1_4_3_1, TEST_1_4_3_2, TEST_1_4_3_3, TEST_1_4_4, TEST_1_4_5, TEST_1_5, TEST_1_6, TEST_1_7, TEST_1_8, TEST_1_9} tests_r;
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
    logic [15:0] mul_data1[0:19] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 12345, 23456, 10101, 20202};
    logic [15:0] mul_data2[0:19] = {0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -12345, -23456, -10101, -20202};
endpackage

import alu_pkg::*;
class alu_sb;
    function automatic check_nzcv(
            input logic [3:0] nzcv, 
            input logic [15:0] data1, 
            input logic [15:0] data2, 
            input logic [3:0] opcode,
            input logic Cin=1'b0);
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
            ADCX: 
            begin
                logic [16:0] sum = data1 + data2 + Cin; 
                result[3] = sum[15];
                result[2] = (sum[15:0] == 0);
                result[1] = sum[16];
                result[0] = ~(data1[15] ^ data2[15]) & (sum[15] ^ data1[15]);
            end
            SBCX: 
            begin 
                logic [16:0] diff = data1 - data2 - (1 - Cin);
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

    function automatic check_addx(
            input logic signed [15:0] dut_data1, 
            input logic signed [15:0] dut_data2, 
            input logic signed[15:0] exp_data1, 
            input logic signed[15:0] exp_data2);

        shortint sum = exp_data1 + exp_data2;
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end
    endfunction

    function automatic check_subx(
        input logic signed [15:0] dut_data1, 
        input logic signed [15:0] dut_data2, 
        input logic signed[15:0] exp_data1, 
        input logic signed[15:0] exp_data2, 
        input int i);

        shortint sum = exp_data1 - exp_data2;
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end
    endfunction

    function automatic check_mulx(
        input logic signed [15:0] dut_data1, 
        input logic signed [15:0] dut_data2, 
        input logic signed [15:0] exp_data1, 
        input logic signed [15:0] exp_data2);
        logic signed [31:0] exp_prod, act_prod;
        
        exp_prod = exp_data1*exp_data2;
        act_prod = $signed({$unsigned(dut_data1), $unsigned(dut_data2)});
        if(act_prod == exp_prod) begin 
            $display("[PASS] Expected: %0d", exp_prod);
        end
        else begin 
            $display("[FAIL] Expected: %0d | Actual: %0d", exp_prod, act_prod);
        end
    endfunction 

    function automatic check_divx(
        input logic signed [15:0] dut_data1,
        input logic signed [15:0] dut_data2,
        input logic signed [15:0] exp_data1,
        input logic signed [15:0] exp_data2);
        logic signed [31:0] exp_div, act_div;
        if(exp_data2 == 0) begin 
            exp_div =32'hFFFF_FFFF;
        end
        else begin 
            exp_div[31:16] = exp_data1 / exp_data2;
            exp_div[15:0] = exp_data1 % exp_data2;
        end

        if(dut_data1 == exp_div[31:16] && dut_data2 == exp_div[15:0])begin 
            $display("[PASS] Expected Quotient: %h, Expected Remainder: %h", exp_div[31:16], exp_div[15:0]);
        end
        else begin
            $display("[FAIL] Expected Quotient: %h, Expected Remainder: %h | Actual Quotient: %h, Actual Remainder: %h", exp_div[31:16], exp_div[15:0], dut_data1, dut_data2);
        end
    endfunction 

    function automatic check_absx(
        input logic signed [15:0] dut_data1,
        input logic signed [15:0] exp_data1);
        logic [15:0] exp_result;
        if(exp_data1 < 0) begin 
            exp_result = -1*exp_data1;
        end
        else begin 
            exp_result = exp_data1;
        end

        if(dut_data1 == exp_result) begin 
            $display("[PASS] Expected: %0d", exp_result);
        end
        else begin 
            $display("[FAIL] Expected: %0d | Actual: %0d", exp_result, dut_data1);
        end
    endfunction

    function automatic check_adcx(
        input logic signed [15:0] dut_data1,
        input logic signed [15:0] dut_data2,
        input logic signed [15:0] exp_data1,
        input logic signed [15:0] exp_data2,
        input logic Cin
    );
        shortint sum = exp_data1 + exp_data2 + Cin;
        if(sum[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", sum);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", sum, dut_data1);
        end

    endfunction 

    function automatic check_sbcx(
        input logic signed [15:0] dut_data1,
        input logic signed [15:0] dut_data2,
        input logic signed [15:0] exp_data1,
        input logic signed [15:0] exp_data2,
        input logic Cin
    );
        shortint diff = exp_data1 - exp_data2 - (1 - Cin);
        if(diff[15:0] == dut_data1 && dut_data2 == 0) begin 
            $display("[PASS] Expected: %4d", diff);
        end
        else begin 
            $display("[FAIL] Expected: %4d | Actual: %4d", diff, dut_data1);
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
        forever #500 clk = ~clk;
    end


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

    task test_header();
        string start_msg;
        tests_r <= tests_r.next();
        @(posedge clk);       
        start_msg = $sformatf("========== START OF %s ==========", tests_r.name());
        start_msg = replace_underscores(start_msg);
        $display("%s", start_msg);
    endtask

    task test_footer();
        string end_msg;
        end_msg = $sformatf("========== END OF %s ==========", tests_r.name());
        end_msg = replace_underscores(end_msg);
        $display("%s", end_msg);
    endtask 
   
    

    task run_addx_subx_test(
        input alu_sb sb, 
        input logic [15:0] data1[0:15], 
        input logic [15:0] data2[0:15]);
        test_header();
        
        @(posedge clk);
        opcode <= ADDX;
        Cin <= 1'b0;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin
            rn = data1[i];
            rm = data2[i]; 
            @(posedge clk);
            sb.check_addx(w_data1, w_data2, data1[i], data2[i]);
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

        test_footer();
    endtask
    
    task run_mulx_divx_test(
        input alu_sb sb, 
        input logic [15:0] data1[0:19],
        input logic [15:0] data2[0:19]);
        test_header();
        @(posedge clk);
        opcode <= MULX;
        Cin <= 1'b0;
        s <= 1'b0;
        @(posedge clk);
        for(int i = 0; i < 20; i++) begin 
            for(int j = 0; j < 20; j++) begin 
                rn = data1[i];
                rm = data2[j];
                @(posedge clk);
                sb.check_mulx(w_data1, w_data2, data1[i], data2[j]);
            end
        end
        @(posedge clk);
        opcode <= DIVX;
        @(posedge clk);
        for(int i = 0; i < 20; i++) begin 
            for(int j = 0; j < 20; j++) begin 
                rn = data1[i];
                rm = data2[j];
                @(posedge clk);
                sb.check_divx(w_data1, w_data2, data1[i], data2[j]);
            end
        end
        @(posedge clk);
        test_footer();
    endtask 

    task run_absx_test(
        input alu_sb sb,
        input logic [15:0] data1[0:15]
    );
        test_header();
        @(posedge clk);
        opcode <= ABSX;
        Cin <= 1'b0;
        s <= 1'b0;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            rn = data1[i];
            @(posedge clk);
            sb.check_absx(w_data1, data1[i]);
        end
        @(posedge clk);
        test_footer();
    endtask 

    task run_adcx_sbcx_test(
        input alu_sb sb, 
        input logic [15:0] data1[0:15], 
        input logic [15:0] data2[0:15]);
        test_header();
        
        @(posedge clk);
        opcode <= ADCX;
        Cin <= 1'b1;
        s <= 1'b1;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin
            rn = data1[i];
            rm = data2[i]; 
            @(posedge clk);
            sb.check_adcx(w_data1, w_data2, data1[i], data2[i], Cin);
            sb.check_nzcv(nzcv, data1[i], data2[i], opcode, Cin);
        end
        @(posedge clk);
        opcode <= SBCX;
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin
            rn = data1[i];
            rm = data2[i]; 
            @(posedge clk);
            sb.check_sbcx(w_data1, w_data2, data1[i], data2[i], Cin);
            sb.check_nzcv(nzcv, data1[i], data2[i], opcode, Cin);
        end
        @(posedge clk);

        test_footer();
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
        run_mulx_divx_test(sb, mul_data1, mul_data1);
        @(posedge clk);
        run_mulx_divx_test(sb, mul_data2, mul_data2);
        @(posedge clk);
        run_mulx_divx_test(sb, mul_data1, mul_data2);
        @(posedge clk);
        run_mulx_divx_test(sb, mul_data2, mul_data1);
        @(posedge clk);
        run_absx_test(sb, z_data1);
        @(posedge clk);
        run_adcx_sbcx_test(sb, data_arith_1, data_arith_2);
        @(posedge clk);
        run_adcx_sbcx_test(sb, c_data1, c_data2);
        @(posedge clk);
        run_adcx_sbcx_test(sb, v_data1, v_data2);
        @(posedge clk);
        run_adcx_sbcx_test(sb, v_data3, v_data4);
        @(posedge clk);
        run_adcx_sbcx_test(sb, v_data1, v_data4);
        @(posedge clk);
        run_adcx_sbcx_test(sb, z_data1, z_data2);
        @(posedge clk);
        run_adcx_sbcx_test(sb, n_data1, n_data2);
        @(posedge clk);
        $finish; 

    end
endmodule
