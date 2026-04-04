`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 12:36:30 PM
// Design Name: 
// Module Name: pc_adder
// Project Name: ARMish Processor
// Target Devices: Nexys Video
// Tool Versions: 
// Description: PC Adder for ARMish Processor
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module pc_adder(
    output logic [15:0] pc_next,        // next value of PC
    input logic [15:0] pc,              // current value of PC
    input logic signed[15:0] offset,
    input logic update_pc
    );
    
    logic signed [16:0] sum;
    assign sum = $signed(pc) + offset;      // ensure that signed addition is used to prevent any unexpected addition mistakes
    assign pc_next = update_pc ? sum[15:0] : pc;             // take the magnitude bits to be the address
endmodule


