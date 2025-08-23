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
    input logic reg_write,
    input logic clk,
    input logic reset
    );

    logic [15:0] register_file[0:15];

    // Write logic
    always_ff @(posedge clk) begin
        if(reset) begin 
            for(int i = 0; i < 16; i++) begin 
                register_file[i] <= 16'b0;
            end
        end
        else if(reg_write == 1) begin 
            if(w_reg1 != 0) begin 
                register_file[w_reg1] <= w_data1;
            end
            if(w_reg2 != 0 && w_reg2 != w_reg1) begin           // if w_reg1 and w_reg2 are the same (writing to the same register), don't execute the second write 
                register_file[w_reg2] <= w_data2;
            end
        end 
    end

    // Read logic with RAW bypass logic
    assign r_data1 = (r_reg1 == 0) ? 16'b0 :            
    ((r_reg1 == w_reg1) && reg_write) ? w_data1 : 
    ((r_reg1 == w_reg2) && reg_write) ? w_data2 : 
    register_file[r_reg1];

    assign r_data2 = (r_reg2 == 0) ? 16'b0 : 
    ((r_reg2 == w_reg1) && reg_write) ? w_data1 : 
    ((r_reg2 == w_reg2) && reg_write) ? w_data2 : 
    register_file[r_reg2];
endmodule
