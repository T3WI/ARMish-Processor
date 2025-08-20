`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2025 12:21:13 PM
// Design Name: 
// Module Name: instr_mem
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


module instr_mem(
    output logic [31:0] instruction,
    input logic [15:0] r_address,

    input logic [31:0] w_instruction,
    input logic [9:0] w_address,
    input logic w_e 
    );

    bit [31:0] instruction_memory[0:1023];
    
    always_comb begin 
        // load memory serially into instruction memory
        if(w_e) begin 
            instruction_memory[w_address] = w_instruction;
            instruction = 32'b0;
        end
        // read instruction memory to output the instruction at pc
        else begin 
            instruction = instruction_memory[r_address];
        end
    end
    
endmodule
