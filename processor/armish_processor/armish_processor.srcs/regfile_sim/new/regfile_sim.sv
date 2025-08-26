`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 09:53:26 PM
// Design Name: 
// Module Name: regfile_sim
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

// data to play around with
package regfile_pkg;    
    logic [15:0] write_array[0:15] = '{16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, 16'h8888,
    16'h9999, 16'haaaa, 16'hbbbb, 16'hcccc, 16'hdddd, 16'heeee, 16'hffff, 16'h0000};
endpackage

// clock interface between scoreboard and sim
interface regfile_ifc(input logic clk);
endinterface

import regfile_pkg::*;
class regfile_scoreboard;
    logic [15:0] expected[0:15];
    virtual regfile_ifc vifc;

    // set scoreboard to connect with the testbench clock signal and initialize registers to 0;
    function new(virtual regfile_ifc _vifc);
        vifc = _vifc;
        foreach (expected[i])
            expected[i] = 16'h0000;
    endfunction

    // write to to the registers
    task write(input logic[3:0] w_addr, input logic [15:0] w_data);
        if(w_addr == 0)
            expected[w_addr] = 16'b0;
        else  
            expected[w_addr] = w_data;
    endtask

    // read from the registers
    function logic[15:0] read(input logic [3:0] r_addr);
        return expected[r_addr];
    endfunction
    
    // print out all the register values
    function logic[15:0] show_sb();
        for(int i = 0; i < 16; i++) begin 
            $display("Addr: %0d, Value: %h", i, read(i));
        end
    endfunction

    // check if the DUT matches the scoreboard
    task check(input logic [3:0] addr, input logic [15:0] dut_data);
        if (expected[addr] !== dut_data) begin
            $display("[FAIL] Addr: %0d | Expected: %h | Got: %h", addr, expected[addr], dut_data);
        end 
        else begin
            $display("[PASS] Addr: %0d | Data: %h", addr, dut_data);
        end
    endtask

    task check_zero(input logic [3:0] addr, input logic [15:0] dut_data);
        if(expected[0] !== dut_data) begin 
            $display("[FAIL] Addr: %0d | Expected: %h | Got: %h", addr, expected[0], dut_data);
        end
        else begin 
            $display("[PASS] Addr: %0d | Data: %h", addr, dut_data);
        end
    endtask 

    // load sb with test values
    task populate_sb();
        for(int i = 0; i < 16; i++) begin 
            write(i, write_array[i]);
            @(posedge vifc.clk);
        end
    endtask

endclass 

import regfile_pkg::*;
module regfile_sim(


    );
    logic clk;
    initial begin 
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    enum logic [3:0] {SCOREBOARD_SETUP, DUT_SETUP, TEST_11, TEST_121, TEST_122, TEST_123, TEST_124, TEST_125, TEST_126, TEST_127, TEST_128} testing_state; 
    
    logic [15:0] r_data1, r_data2, w_data1, w_data2;
    logic [3:0] r_reg1, r_reg2, w_reg1, w_reg2;
    logic reg_write1, reg_write2, reset;

    regfile_scoreboard sb;
    regfile_ifc rf_ifc(clk);

    task end_test_section();
        #40;
    endtask 

    // load register file with test values
    task populate_rf();
        reg_write1 = 1'b1;
        for(int i = 0; i < 16; i++) begin 
            w_reg1 = i;
            w_data1 = write_array[i];
            #20;
        end
    endtask

    task reset_sb_and_rf_to_test_vals();
        @(posedge clk);
        reg_write1 = 1'b0;
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        reg_write1 = 1'b1;
        @(posedge clk);
        sb.populate_sb();
        populate_rf();
    endtask

    // Checks read after write (read from reg1 after writing to reg1) for separate clock cycles on reg1
    task read_after_write_reg11(input logic [3:0] write_reg, input logic [15:0] write_data);
        reg_write1 = 1'b1;
        w_reg1 = write_reg;
        w_reg2 = 0;                         // example register to ensure bypass checks pass and not end up with XXXX
        w_data1 = write_data;
        sb.write(write_reg, write_data);
        @(posedge clk);
        r_reg1 = write_reg;
        @(posedge clk);
        sb.check(write_reg, r_data1);
    endtask 

    // Checks read after write (read from reg1 after writing to reg2) for separate clock cycles on reg1
    task read_after_write_reg12(input logic [3:0] write_reg, input logic [15:0] write_data, input logic [3:0] read_reg);
        reg_write2 = 1'b1;
        w_reg1 = 0;
        w_reg2 = write_reg;                         // example register to ensure bypass checks pass and not end up with XXXX
        w_data2 = write_data;
        sb.write(write_reg, write_data);
        @(posedge clk);
        r_reg1 = read_reg;
        @(posedge clk);
        sb.check(read_reg, r_data1);
        sb.check(write_reg, write_data);
    endtask 

    // Checks read after write (read from reg2 after writing to reg2) for separate clock cycles on reg2
    task read_after_write_reg22(input logic [3:0] write_reg, input logic [15:0] write_data);
        reg_write2 = 1'b1;
        w_reg1 = 0;                                 // example register to ensure bypass checks pass and not end up with XXXX
        w_reg2 = write_reg;                         
        w_data2 = write_data;
        sb.write(write_reg, write_data);
        @(posedge clk);
        r_reg2 = write_reg;
        @(posedge clk);
        sb.check(write_reg, r_data2);
    endtask 

    // Checks read after write (read from reg2 after writing to reg1) for separate clock cycles on reg1
    task read_after_write_reg21(input logic [3:0] write_reg, input logic [15:0] write_data, input logic [3:0] read_reg);
        reg_write1 = 1'b1;
        w_reg1 = write_reg;
        w_reg2 = 0;                         // example register to ensure bypass checks pass and not end up with XXXX
        w_data1 = write_data;
        sb.write(write_reg, write_data);
        @(posedge clk);
        r_reg2 = read_reg;
        @(posedge clk);
        sb.check(read_reg, r_data2);
        sb.check(write_reg, write_data);
    endtask 



    reg_file rf(.r_data1(r_data1), .r_data2(r_data2), .r_reg1(r_reg1), .r_reg2(r_reg2), .w_data1(w_data1), .w_data2(w_data2), .w_reg1(w_reg1), .w_reg2(w_reg2), .reg_write1(reg_write1), .reg_write2(reg_write2), .reset(reset), .clk(clk));

    initial begin
        // Setup scoreboard
        testing_state <= SCOREBOARD_SETUP;
        sb = new(rf_ifc);
        @(posedge clk);
        sb.populate_sb();
        @(posedge clk); 
        // Read out sb values
        sb.show_sb();
        end_test_section();
        // Test Default Setup 
        testing_state <= DUT_SETUP;
        reg_write1 = 1'b0;
        reg_write2 = 1'b0;
        end_test_section();
        // Test 1.1
        $display("%s", $sformatf("========== START TEST 1.1 =========="));
        testing_state <= TEST_11;
        @(posedge clk)
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        for(int i = 0; i < 4; i++) begin        // just good enough checking
            for(int j = 0; j < 4; j++) begin 
                r_reg1 = i;
                r_reg2 = j;
                @(posedge clk);
                sb.check_zero(i, r_data1);
                sb.check_zero(j, r_data2);
            end
        end
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.1 =========="));



        // Test 1.2.1
        $display("%s", $sformatf("========== START TEST 1.2.1 =========="));
        testing_state <= TEST_121;
        reg_write1 = 1'b1;
        reg_write2 = 1'b1;
        populate_rf();                          // populate reg file
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            read_after_write_reg11(i, write_array[15 - i]);
        end
        reset_sb_and_rf_to_test_vals();
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            read_after_write_reg22(i, write_array[15 - i]);
        end
        reset_sb_and_rf_to_test_vals();
        @(posedge clk);
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.2.1 =========="));

        // Test 1.2.2
        $display("%s", $sformatf("========== START TEST 1.2.2 =========="));
        testing_state <= TEST_122;
        reg_write1 = 1'b1;
        reg_write2 = 1'b1;
        sb.populate_sb();
        populate_rf();
        for(int i = 0; i < 8; i++) begin 
            for(int j = 0; j < 8; j++) begin 
                read_after_write_reg12(i, write_array[15 - i], j);
            end
        end
        @(posedge clk);
        for(int i = 0; i < 8; i++) begin    
            for(int j = 0; j < 8; j++) begin 
                read_after_write_reg21(i, write_array[15 - i], j);
            end
        end
        @(posedge clk);
        
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.2.2 =========="));
        // Test 1.2.3
        $display("%s", $sformatf("========== START TEST 1.2.3 =========="));
        testing_state <= TEST_123;
        reg_write1 = 1'b1;
        reg_write2 = 1'b1;
        reset_sb_and_rf_to_test_vals();
        w_reg1 = 0;
        for(int i = 0; i < 16; i++) begin 
            w_data1 = write_array[i];
            @(posedge clk);
            sb.check_zero(w_reg1, 0);
        end
        w_reg2 = 0;
        for(int i = 0; i < 16; i++) begin 
            w_data2 = write_array[i];
            @(posedge clk);
            sb.check_zero(w_reg2, 0);
        end
        $display("%s", $sformatf("========== END TEST 1.2.3 =========="));
        end_test_section();
        // Test 1.2.4
        $display("%s", $sformatf("========== START TEST 1.2.4 =========="));
        testing_state <= TEST_124;
        reg_write1 = 1'b1;
        reg_write2 = 1'b1;
        reset_sb_and_rf_to_test_vals();
        for(int i = 0; i < 16; i++) begin 
            w_reg1 = i;
            w_data1 = 16'h1234; 
            @(posedge clk);
        end
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            w_reg2 = i;
            w_data2 = 16'habcd;
            @(posedge clk);
        end
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.2.4 =========="));
        // Test 1.2.5
        $display("%s", $sformatf("========== START TEST 1.2.5 =========="));
        testing_state <= TEST_125;
        reg_write1 = 1'b1;
        reg_write2 = 1'b1;
        reset_sb_and_rf_to_test_vals();
        for(int i = 0; i < 8; i++) begin 
            for(int j = 0; j < 8; j++) begin
                if(i == j) begin                    // regfile prioritizes w_reg1's write
                    w_reg1 = i;
                    w_reg2 = j;
                    w_data1 = write_array[15 - i];
                    w_data2 = write_array[15 - j];
                    sb.write(i, write_array[15 - i]);
                    @(posedge clk);
                    r_reg1 = i;
                    r_reg2 = j;
                    #1;
                end
                else begin 
                    w_reg1 = i;
                    w_reg2 = j;
                    w_data1 = write_array[15 - i];
                    w_data2 = write_array[15 - j];
                    sb.write(i, write_array[15 - i]);
                    sb.write(j, write_array[15 - j]);
                    @(posedge clk);
                    r_reg1 = i;
                    r_reg2 = j;
                    #1;
                end 
                sb.check(r_reg1, r_data1);
                sb.check(r_reg2, r_data2);
            end
        end
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.2.5 =========="));
        // Test 1.2.6
        testing_state <= TEST_126;
        reg_write1 = 1'b1;
        reg_write2 = 1'b0;
        reset_sb_and_rf_to_test_vals();
        for(int i = 0; i < 16; i++) begin 
            r_reg1 = i;
            r_reg2 = 0;
            @(posedge clk);
        end
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            r_reg1 = 0;
            r_reg2 = i;
            @(posedge clk);
        end
        end_test_section();

    end
endmodule
