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
endpackage

import cpu_pkg::*;
class scoreboard;
    function automatic check(
        input logic [31:0] instruction
    );
        logic exp_regwrite1, exp_regwrite2;
        
    endfunction
endclass

module main_control_sim();
    import test_vec::*;
    logic clk;
    initial begin 
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    

    logic reg_write1, reg_write2;
    logic [31:0] instruction;
    main_control mcu(
        .reg_write1(reg_write1), 
        .reg_write2(reg_write2), 
        .instruction(instruction)
        );

    initial begin 
        for(int i = 0; i < count; i++) begin 
            instruction = test_instr[i];
            @(posedge clk);

        end
    end
endmodule
