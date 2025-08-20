`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 09:39:08 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file(
    output logic [15:0] r_data1,
    output logic [15:0] r_data2,
    input logic [3:0] r_reg1,
    input logic [3:0] r_reg2,
    input logic [15:0] w_data1,
    input logic [15:0] w_data2,
    input logic [3:0] w_reg1,
    input logic [3:0] w_reg2,
    input logic reg_write
    );
endmodule
