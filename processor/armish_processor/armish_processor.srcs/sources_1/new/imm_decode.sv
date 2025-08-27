`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 12:43:08 AM
// Design Name: 
// Module Name: imm_decode
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


module imm_decode(
    output logic [15:0] imm,
    input logic [7:0] imm8,
    input logic [3:0] rot
    );
    logic [15:0] ext_imm8, rs_imm8, ls_imm8;

    assign ext_imm8 = {8'b0, imm8};
    assign rs_imm8 = ext_imm8 >> rot;
    assign ls_imm8 = ext_imm8 << (16 - rot);
    assign imm = rs_imm8 | ls_imm8;
endmodule
