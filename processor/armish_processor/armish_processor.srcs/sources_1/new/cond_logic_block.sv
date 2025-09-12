`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2025 11:31:27 PM
// Design Name: 
// Module Name: cond_logic_block
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

import cpu_pkg::*;
module cond_logic_block(
    output logic cond_met,
    input logic [3:0] nzcv,
    input cond_t cond
    );
    logic n, z, c, v;
    always_comb begin 
        n = nzcv[3];
        z = nzcv[2];
        c = nzcv[1];
        v = nzcv[0];
        case(cond) 
            AL:     cond_met = 1'b1;
            LE:     cond_met = z || (n != v);
            GT:     cond_met = !z && (n == v);
            LT:     cond_met = n != v;
            GE:     cond_met = n == v;
            LS:     cond_met = !c || z;
            HI:     cond_met = c && !z;
            VC:     cond_met = !v;
            VS:     cond_met = v;
            PL:     cond_met = !n;
            MI:     cond_met = n;
            CC:     cond_met = !c;
            CS:     cond_met = c;
            NEQ:    cond_met = !z;
            EQ:     cond_met = z;
            default: cond_met = 1'b0;
        endcase
    end
endmodule
