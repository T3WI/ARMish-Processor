`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 12:36:30 PM
// Design Name: 
// Module Name: pc_adder
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


module pc_adder(
    output logic [15:0] pc_next,
    input logic [15:0] pc,
    input logic signed[15:0] offset
    );
    
    logic signed [16:0] sum;
    assign sum = $signed(pc) + offset;      // ensure that signed addition is used to prevent any unexpected addition mistakes
    assign pc_next = sum[15:0];             // take the magnitude bits to be the address
endmodule


