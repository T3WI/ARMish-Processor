`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 12:39:13 AM
// Design Name: 
// Module Name: alu
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


module alu(
    output logic [15:0] w_data1,
    output logic [15:0] w_data2,
    output logic [15:0] nzcv,
    
    input logic [15:0] r_n,
    input logic [15:0] r_m, 
    input logic [15:0] r_s, 
    
    input logic [3:0] opcode,
    input logic en,
    input logic Cin,
    input logic s, 
    input logic rem
    );
endmodule
