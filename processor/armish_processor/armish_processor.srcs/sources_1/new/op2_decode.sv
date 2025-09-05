`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2025 01:55:41 AM
// Design Name: 
// Module Name: op2_decode
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


module op2_decode(
    output logic [15:0] rm_dec,

    input logic [7:0] imm_m,
    input logic [3:0] rot_m,
    input logic [15:0] rm,
    
    input logic i,
    input logic [1:0] shtype,
    input logic r_shift,
    
    input logic [3:0] shamt,
    input logic [15:0] rs
    );

    logic [15:0] dec_imm_m, dec_imm_s;

    imm_decode idm(.imm(dec_imm_m), .imm8(imm_m), .rot(rot_m));
    shifter sf(.shifted_rm(rm_dec), .rm(rm), .imm(dec_imm_m), .rs(rs), .shamt(shamt), .shtype(shtype), .r_shift(r_shift), .i(i));
endmodule
