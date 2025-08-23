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
class regfile_scoreboard;
    logic [15:0] expected[0:15];

    function new();
        foreach (expected[i])
            expected[i] = 16'h0000;
    endfunction

    task write(input logic[3:0] w_addr, input logic [15:0] w_data);
        if(w_addr == 0)
            expected[w_addr] = 16'b0;
        else  
            expected[w_addr] = w_data;
    endtask

    function logic[15:0] read(input logic [3:0] r_addr);
        return expected[r_addr];
    endfunction

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

endclass 


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
    logic reg_write, reset;

    regfile_scoreboard sb;
    logic [15:0] write_array[0:15];

    task end_test_section();
        #40;
    endtask 

    task populate_rf();
        reg_write = 1'b1;
        for(int i = 0; i < 16; i++) begin 
            w_reg1 = i;
            w_data1 = write_array[i];
            #20;
        end
    endtask

    // Checks write and read on the first read register 1 output
    task write_and_read_reg1(input logic [3:0] write_reg, input logic [15:0] write_data);
        reg_write = 1'b1;
        w_reg1 = write_reg;
        w_reg2 = 0;                         // example register to ensure bypass checks pass and not end up with XXXX
        w_data1 = write_data;
        sb.write(write_reg, write_data);
        @(posedge clk);
        r_reg1 = write_reg;
        @(posedge clk);
        sb.check(write_reg, r_data1);
    endtask 

    assign write_array = '{16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, 16'h8888,
    16'h9999, 16'haaaa, 16'hbbbb, 16'hcccc, 16'hdddd, 16'heeee, 16'hffff, 16'h0000};

    reg_file rf(.r_data1(r_data1), .r_data2(r_data2), .r_reg1(r_reg1), .r_reg2(r_reg2), .w_data1(w_data1), .w_data2(w_data2), .w_reg1(w_reg1), .w_reg2(w_reg2), .reg_write(reg_write), .reset(reset), .clk(clk));

    initial begin
        // Setup scoreboard
        testing_state <= SCOREBOARD_SETUP;
        sb = new();
        
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            sb.write(i, write_array[i]);
            @(posedge clk);
        end
        @(posedge clk); 
        for(int i = 0; i < 16; i++) begin 
            $display("Address: %0d, Data: %4h", i, sb.read(i));
            @(posedge clk);
        end
        end_test_section();
        // Test Default Setup 
        testing_state <= DUT_SETUP;
        reg_write = 1'b0;
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
        reg_write = 1'b1;
        populate_rf();                          // populate reg file
        #20;
        for(int i = 0; i < 16; i++) begin 
            write_and_read_reg1(i, write_array[15 - i]);
        end
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.2.1 =========="));

        // Test 1.2.2
        $display("%s", $sformatf("========== START TEST 1.2.2 =========="));
        testing_state <= TEST_122;
        reg_write = 1'b1;
        populate_rf();
        end_test_section();
        $display("%s", $sformatf("========== END TEST 1.2.2 =========="));
        // Test 1.2.3
        testing_state <= TEST_123;
        end_test_section();
        // Test 1.2.4
        testing_state <= TEST_124;
        end_test_section();
        // Test 1.2.5
        testing_state <= TEST_125;
        end_test_section();
        // Test 1.2.6
        testing_state <= TEST_126;
        end_test_section();
        // Test 1.2.7
        testing_state <= TEST_127;
        end_test_section();
        // Test 1.2.8
        testing_state <= TEST_128;
        end_test_section();

    end
endmodule
