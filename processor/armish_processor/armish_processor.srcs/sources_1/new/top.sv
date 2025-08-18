`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 01:28:35 PM
// Design Name: 
// Module Name: top
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


module top(
    output logic [15:0] pc_next, 
    input clk,              // clock 
    input reset             // synchronous reset
    );
    logic [15:0] pc;
    logic [15:0] offset_nonbranching; 
    // Program counter: No branching
    assign offset_nonbranching = 16'd4;
    pc_adder no_branch_adder(.pc_next(pc_next), .pc(pc), .offset(offset_nonbranching));
    
    always_ff@(posedge clk) begin
        if(reset) begin 
            pc <= 16'd0;
        end
        else begin 
            pc <= pc_next;
        end
    end
    
endmodule










