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
    input logic [15:0] r_address
);
    logic [31:0] instruction_memory [0:1023];
    
    initial begin 
        $readmemh("out.hex", instruction_memory);
    end

    // Asynchronous read
    assign instruction = instruction_memory[r_address >> 2];
endmodule
