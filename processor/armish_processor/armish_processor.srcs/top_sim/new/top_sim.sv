`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 02:05:50 PM
// Design Name: 
// Module Name: top_sim
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


module top_sim(

    );
    logic [15:0] out;
    logic reset;
    
    reg clk;
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    top t(.pc_next(out), .clk(clk), .reset(reset));
    
    initial begin
        reset = 1'b1;
        #10;
        reset = 1'b0;
    end 
    
endmodule
