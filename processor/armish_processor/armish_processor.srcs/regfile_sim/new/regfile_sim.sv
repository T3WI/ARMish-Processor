`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 09:53:26 PM
// Design Name: 
// Module Name: regfile_sim
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


module regfile_sim(


    );
    logic [15:0] r_data1, r_data2, w_data1, w_data2;
    logic [3:0] r_reg1, r_reg2, w_reg1, w_reg2;
    logic reg_write;

    

    // Sim Implementation
    logic [15:0] sim_rf[16];

    reg_file rf(.r_data1(r_data1), .r_data2(r_data2), .r_reg1(r_reg1), .r_reg2(r_reg2), .w_data1(w_data1), .w_data2(w_data2), .w_reg1(w_reg1), .w_reg2(w_reg2), .reg_write(reg_write));
endmodule
