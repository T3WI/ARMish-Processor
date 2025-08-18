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
    logic signed [15:0] offset;
    logic [15:0] pc_next;
    integer num_tests = 0;
    integer num_correct = 0;
    
    pc_adder p(.pc_next(pc_next), .pc(pc), .offset(offset));
    
    initial begin 
        // Test #1: Adding to a pc=0
        // $monitor("Time: %0t | pc = %0d | offset = %0d | pc_next = %0d", $time, pc, offset, pc_next);
        pc = 16'd0;
        offset = 16'sd0;
        while(offset < 16'sd512) begin
            num_tests++;
            offset = offset + 16'sd4;
            #1;
            if(pc + offset == pc_next)begin 
                num_correct++;
            end
            else begin 
                $display("Test failed: pc = %0d | offset = %0d | pc + offset = %0d | pc_next = %0d", pc, offset, pc + offset ,pc_next);
            end
            #10;
        end
        #20;
        
        // Test #2: Adding to a pc=512
        pc = 16'd512;
        offset = 16'sd0;

        #20;
        while(offset < 16'sd1024) begin 
            num_tests++;
            offset = offset + 16'sd4;
            #1;
            if(pc + offset == pc_next)begin 
                num_correct++;
            end
            else begin 
                $display("Test failed: pc = %0d | offset = %0d | pc + offset = %0d | pc_next = %0d", pc, offset, pc + offset ,pc_next);
            end
            #10;
        end
        

        // Test #3: Subtracting from pc=512
        #200;
        pc = 16'd512;
        offset = 16'sd0;
        #200;

        while(offset > -16'sd512) begin 
            num_tests++;
            offset = offset - 16'sd4;
            #1;
            if(pc + offset == pc_next)begin 
                num_correct++;
            end
            else begin 
                $display("Test failed: pc = %0d | offset = %0d | pc + offset = %0d | pc_next = %0d", pc, offset, pc + offset ,pc_next);
            end
            #10;
        end
        $display("Tests passed: %0d, Tests failed: %0d, Total Tests: %0d", num_correct, num_tests - num_correct, num_tests);
        $finish;
    end
    


    
endmodule
