`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 12:56:30 PM
// Design Name: 
// Module Name: pc_adder_sim
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


module pc_adder_sim(

    );
    logic [15:0] pc;
    logic [15:0] offset;
    logic [15:0] pc_next;
    
    pc_adder p(.pc_next(pc_next), .pc(pc), .offset(offset));
    
    initial begin 
        $monitor("Time: %0t | pc = %0d | offset = %0d | pc_next = %0d", $time, pc, offset, pc_next);
        pc = 16'd0;
        offset = 16'd0;
        while(offset < 16'd1024)
        begin
            offset = offset + 16'd4;
            #10;
        end
    end
    
//    initial begin
//    $monitor("Time: %0t | pc = %0d | offset = %0d | pc_next = %0d", $time, pc, offset, pc_next);
//    pc = 16'b0; offset = 16'b0;
//    #10;
//    pc = 16'b0; offset = 16'b1;
//    #10;
//    pc = 16'b1; offset = 16'b0;
//    #10;
//    pc = 16'b1; offset = 16'b1;
//    #10;
//    $finish;
//    end
    
endmodule
