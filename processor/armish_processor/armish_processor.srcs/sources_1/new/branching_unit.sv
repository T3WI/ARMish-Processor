`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2025 11:41:12 PM
// Design Name: 
// Module Name: branching_unit
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


module branching_unit(
    output logic [15:0] lr,
    output logic [15:0] out_pc,
    input logic [15:0] pc_next,
    input logic [15:0] pc,
    input logic [9:0] instr_offset,
    input logic [15:0] rb, 
    input logic r,
    input logic branch
    );
    assign lr = pc_next;
    
    logic [15:0] pc_source;
    assign pc_source = r ? rb : instr_offset;
    assign new_pc = pc + pc_source; 
    assign out_pc = branch ? new_pc : pc_next;
endmodule
