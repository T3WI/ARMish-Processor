`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 01:37:50 PM
// Design Name: 
// Module Name: instr_mem_sim
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


module instr_mem_sim();

    bit clk;
    
    
    logic [31:0] instruction;
    logic [15:0] r_address;

    logic [31:0] w_instruction;
    logic [9:0] w_address;
    logic w_e;
    
    instr_mem im(.instruction(instruction), .r_address(r_address), .w_instruction(w_instruction), .w_address(w_address), .w_e(w_e));

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    bit[31:0]temp_mem[0:255];
    task load_from_file();
        $readmemb("out.bin", temp_mem);
    endtask
    
    integer count;
    task count_instructions(output integer count);
        integer file;
        string token;
        count = 0;

        file = $fopen("out.bin", "r");
        if (file == 0) $fatal("Failed to open file");

        // Read tokens one by one, ignoring whitespace/newlines
        while ($fscanf(file, "%s", token) == 1) begin
            count++;
        end

        $fclose(file);
        $display("Lines in file: %0d", count);
    endtask

    // TODO: Write instruction to instruction memory serially until all of temp_mem is read 
    task load_instruction_mem();
        w_e = 1'b1;
        for(int i = 0; i < count; i++) begin
            w_instruction = temp_mem[i];
            w_address = i;
            #10;
        end 
        w_e = 1'b0;
    endtask 

    task read_instruction_mem_seq();
        for(int i = 0; i < count; i++) begin 
            r_address = i;
            #10;
        end
    endtask 
    
    task read_instruction_mem_even();
        r_address = 0;
        #10;
        r_address = 2;
        #10;
        r_address = 4;
        #10;
    endtask 
    
    task read_instruction_mem_odd();
        r_address = 1;
        #10;
        r_address = 3;
        #10;
        r_address = 5;
        #10;
    endtask 

    // MAIN SIMULATION
    initial begin
        // WRITE TEST
        load_from_file();
        #10;  
        count_instructions(count);
        #10;
        load_instruction_mem();
        #10;       
        // READ TEST
        read_instruction_mem_seq();
        #10;
        read_instruction_mem_even();
        #10;
        read_instruction_mem_odd();
        #10;
    end 
endmodule
