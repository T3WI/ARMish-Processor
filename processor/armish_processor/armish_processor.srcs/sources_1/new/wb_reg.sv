`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2025 01:48:43 AM
// Design Name: 
// Module Name: wb_reg
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


module wb_reg(
    output logic [15:0] wb_alu_data1,
    output logic [15:0] wb_alu_data2,
    output logic [3:0] wb_w_reg1,
    output logic [3:0] wb_w_reg2,
    output logic [15:0] wb_mem_data,
    output logic wb_mem_read,
    output logic wb_mem_write,
    output logic wb_mem2reg,
    output logic wb_reg_write1,
    output logic wb_reg_write2,

    input logic [15:0] alu_data1,
    input logic [15:0] alu_data2,
    input logic [3:0] w_reg1,
    input logic [3:0] w_reg2,
    input logic [15:0] mem_data,
    input logic mem2reg,
    input logic reg_write1,
    input logic reg_write2,

    input logic clk,
    input logic reset
    );
    always_ff @(posedge clk) begin 
        if(reset) begin 
            wb_alu_data1 <= 0;
            wb_alu_data2 <= 0;
            wb_w_reg1 <= 0;
            wb_w_reg2 <= 0;
            wb_mem_data <= 0;
            wb_mem2reg <= 0;
            wb_reg_write1 <= 0;
            wb_reg_write2 <= 0;
        end
        else begin 
            wb_alu_data1 <= alu_data1;
            wb_alu_data2 <= alu_data2;
            wb_w_reg1 <= w_reg1;
            wb_w_reg2 <= w_reg2;
            wb_mem_data <= mem_data;
            wb_mem2reg <= mem2reg;
            wb_reg_write1 <= reg_write1;
            wb_reg_write2 <= reg_write2;
        end
    end
endmodule
