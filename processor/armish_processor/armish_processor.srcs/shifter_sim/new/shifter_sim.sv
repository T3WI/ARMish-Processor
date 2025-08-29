`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2025 05:39:24 PM
// Design Name: 
// Module Name: shifter_sim
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
package shifter_pkg;
    logic [15:0] rm_data [0:15] = '{16'h1234, 16'h5678, 16'h9abc, 16'hdef0, 16'hfedc, 16'hba98, 16'h7654, 16'h3210, 16'habcd, 16'hef01, 16'h2345, 16'h6789, 16'h0123, 16'h4567, 16'h89ab, 16'hcdef};
    logic [15:0] imm_data [0:15] = '{16'hffff, 16'heeee, 16'hdddd, 16'hcccc, 16'hbbbb, 16'haaaa, 16'h9999, 16'h8888, 16'h7777, 16'h6666, 16'h5555, 16'h4444, 16'h3333, 16'h2222, 16'h1111, 16'h0000};
    logic [3:0] shift_rs [0:15] = '{4'd0, 4'd2, 4'd4, 4'd6, 4'd8, 4'd10, 4'd12, 4'd14, 4'd1, 4'd3, 4'd5, 4'd7, 4'd9, 4'd11, 4'd13, 4'd15};
    logic [3:0] shift_shamt [0:15] = '{4'd14, 4'd12, 4'd10, 4'd8, 4'd6, 4'd4, 4'd2, 4'd0, 4'd15, 4'd13, 4'd11, 4'd9, 4'd7, 4'd5, 4'd3, 4'd1};
    enum logic [1:0] {ROR=2'd0, ASR=2'd1, LSR=2'd2, LSL=2'd3} shtype;
endpackage 

import shifter_pkg::*;
class shifter_scoreboard;
    logic [15:0] expected;

    function void check_case_imm(input logic [15:0] actual_rm, input integer i);
        if(actual_rm !== imm_data[i]) begin 
            $display("[FAIL] Expected: %4h | Actual: %4h", imm_data[i], actual_rm);
        end
        else begin 
            $display("[PASS] Expected: %4h", actual_rm);
        end
    endfunction 

    function void check_case_rs(input logic [1:0] shtype, input logic [15:0] actual_rm, input integer j);
        logic [15:0] shifted_rm;
        case(shtype)
            ROR: shifted_rm = (rm_data[j] >> shift_rs[j]) | (rm_data[j] << (16 - shift_rs[j]));
            ASR: shifted_rm = rm_data[j] >>> shift_rs[j];
            LSR: shifted_rm = rm_data[j] >> shift_rs[j];
            LSL: shifted_rm = rm_data[j] << shift_rs[j];
            default: shifted_rm = 16'b0;
        endcase
        
        if(actual_rm !== shifted_rm) begin 
            $display("[FAIL] Expected: %4h | Actual: %4h", shifted_rm, actual_rm);
        end
        else begin
            $display("[PASS] Expected: %4h", shifted_rm); 
        end
    endfunction 

    function void check_case_shamt(input logic [1:0] shtype, input logic [15:0] actual_rm, input integer j);
        logic [15:0] shifted_rm; 
        case(shtype)
            ROR: shifted_rm = (rm_data[j] >> shift_shamt[j]) | (rm_data[j] << (16 - shift_shamt[j]));
            ASR: shifted_rm = rm_data[j] >>> shift_shamt[j];
            LSR: shifted_rm = rm_data[j] >> shift_shamt[j];
            LSL: shifted_rm = rm_data[j] << shift_shamt[j];
        endcase 
        if(actual_rm !== shifted_rm) begin 
            $display("[FAIL] Expected: %4h | Actual: %4h", shifted_rm, actual_rm);
        end
        else begin 
            $display("[PASS] Expected: %4h", shifted_rm);
        end
    endfunction 
endclass 

import shifter_pkg::*;
module shifter_sim(

    );
    logic clk;
    initial begin 
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    enum logic [3:0] {TEST_111= 4'd0, TEST_1121= 4'd1, TEST_1122= 4'd2, TEST_121= 4'd3, TEST_1221= 4'd4, TEST_1222= 4'd5, TEST_131= 4'd6, TEST_1321= 4'd7, TEST_1322= 4'd8, TEST_141= 4'd9, TEST_1421= 4'd10, TEST_1422= 4'd11} tests;
    logic [15:0] shifted_rm, rm, imm, rs, shamt;
    
    logic r_shift, i;
    shifter s(.shifted_rm(shifted_rm), .rm(rm), .imm(imm), .rs(rs), .shamt(shamt), .shtype(shtype), .r_shift(r_shift), .i(i));

    shifter_scoreboard sb;
    initial begin 
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.1.1 =========="));
        tests <= TEST_111;
        shtype <= ROR;
        i <= 1;
        r_shift <= 1'b0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            r_shift <= ~r_shift;
            @(posedge clk);
            sb.check_case_imm(shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.1.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.1.2.1 =========="));
        tests <= TEST_1121;
        i <= 0;
        r_shift <= 1;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_rs(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.1.2.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.1.2.2 =========="));
        tests <= TEST_1122;
        i <= 0;
        r_shift <= 0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_shamt(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.1.2.2"));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.2.1 =========="));
        tests <= TEST_121;
        shtype <= ASR;
        i <= 1;
        r_shift <= 1'b0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            r_shift <= ~r_shift;
            @(posedge clk);
            sb.check_case_imm(shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.2.1 =========="));
         @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.2.2.1 =========="));
        tests <= TEST_1221;
        i <= 0;
        r_shift <= 1;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_rs(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.2.2.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.2.2.2 =========="));
        tests <= TEST_1222;
        i <= 0;
        r_shift <= 0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_shamt(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.2.2.2"));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.3.1 =========="));
        tests <= TEST_131;
        shtype <= LSR;
        i <= 1;
        r_shift <= 1'b0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            r_shift <= ~r_shift;
            @(posedge clk);
            sb.check_case_imm(shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.3.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.3.2.1 =========="));
        tests <= TEST_1321;
        i <= 0;
        r_shift <= 1;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_rs(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.3.2.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.3.2.2 =========="));
        tests <= TEST_1322;
        i <= 0;
        r_shift <= 0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_shamt(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.3.2.2"));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.4.1 =========="));
        tests <= TEST_141;
        shtype <= LSL;
        i <= 1;
        r_shift <= 1'b0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            r_shift <= ~r_shift;
            @(posedge clk);
            sb.check_case_imm(shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.4.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.4.2.1 =========="));
        tests <= TEST_1421;
        i <= 0;
        r_shift <= 1;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_rs(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.4.2.1 =========="));
        @(posedge clk);
        $display("%s", $sformatf("========== START OF TEST 1.4.2.2 =========="));
        tests <= TEST_1422;
        i <= 0;
        r_shift <= 0;
        @(posedge clk);
        for(int j = 0; j < 16; j++) begin 
            rm <= rm_data[j];
            imm <= imm_data[j];
            rs <= shift_rs[j];
            shamt <= shift_shamt[j];
            @(posedge clk);
            sb.check_case_shamt(shtype, shifted_rm, j);
        end
        $display("%s", $sformatf("========== END OF TEST 1.4.2.2"));
        $finish;
    end
endmodule
