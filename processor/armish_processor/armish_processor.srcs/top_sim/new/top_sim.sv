`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 02:05:50 PM
// Design Name: 
// Module Name: top_sim
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

module top_sim();
    bit clk;
    bit reset;
    bit done;
    bit load_ready;
    bit load_done;
    bit execute_done;

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    bit[31:0]temp_mem[0:255];
    
    task load_from_file();
        $readmemb("out.bin", temp_mem);
    endtask

    // TODO: Write instruction to instruction memory serially until all of temp_mem is read 
    task load_instruction_mem();
    begin
        #10; 
    end
    endtask 
    
    top t(.done(done), .load_done(load_done), .execute_done(execute_done), .clk(clk), .reset(reset), .load_ready(load_ready));
    
    // Test: Address with positive offset
    initial begin
        reset = 1'b1;
        #10;
        reset = 1'b0;
        #10;
        load_from_file();
        load_ready = 1'b1; 
        #50;  
        load_instruction_mem();
        if(load_done) load_ready = 1'b0;

        
    end 
    
endmodule
