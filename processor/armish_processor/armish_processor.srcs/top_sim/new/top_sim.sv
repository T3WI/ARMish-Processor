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

    // 50 MHz clock
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    bit[31:0] temp_mem[0:255];
    logic [31:0] w_instruction;
    logic [9:0] w_address;
    logic instrmem_we;
    
    task load_from_file();
        load_done = 1'b0;
        $readmemb("out.bin", temp_mem);
    endtask

    integer count;
    task count_instructions(output integer count);
        integer file;
        string token;
        count = 0;

        file = $fopen("out.bin", "r");
//        if (file == 0) $fatal("Failed to open file");

        // Read tokens one by one, ignoring whitespace/newlines
        while ($fscanf(file, "%s", token) == 1) begin
            count++;
        end

        $fclose(file);
        $display("Lines in file: %0d", count);
    endtask

    task load_instruction_mem();
        for(int i = 0; i < count; i++) begin
            w_instruction = temp_mem[i];
            w_address = i;
            @(posedge clk);
        end 
    endtask 

    task run_program();
        reset = 1'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;
        @(posedge clk);
        load_from_file();
        @(posedge clk);
        count_instructions(count);
        @(posedge clk);
        load_ready = 1'b1; 
        @(posedge clk); 
        instrmem_we = 1'b1;
        @(posedge clk);
        load_instruction_mem();
        instrmem_we = 1'b0;
        @(posedge clk);
        load_done = 1'b1;
        if(load_done) load_ready = 1'b0;
        @(posedge clk);
        while(!execute_done) begin 
            @(posedge clk);
        end
    endtask 
    
    top t(.done(done), .execute_done(execute_done), .instrmem_w_address(w_address), .instrmem_w_instruction(w_instruction), .clk(clk), .reset(reset), .load_ready(load_ready), .load_done(load_done), .instrmem_we(instrmem_we));
    
    // Test: Address with positive offset
    initial begin
        run_program();
        $finish;
    end 
    
endmodule
