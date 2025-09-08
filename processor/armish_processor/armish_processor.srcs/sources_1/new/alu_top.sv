`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2025 11:22:56 PM
// Design Name: 
// Module Name: alu_top
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
typedef enum logic [1:0] {B, D, RF, RX} instr_t;
module alu_top(
    // output logic [3:0] _opcode,     // for debugging purposes in alutop_sim.sv
    output logic [15:0] w_data1,
    output logic [15:0] w_data2,
    output logic [3:0] nzcv,
    input logic [15:0] rn,
    input logic [15:0] rm_dec, 
    input logic s,
    input logic Cin,
    input logic en, 
    input logic [1:0] instr_class,
    input logic [3:0] opcode,
    input logic u
    );
    logic [3:0] _opcode;
    always_comb begin 
        case(instr_class)
            RX: _opcode = opcode;
            RF: _opcode = NOOP;
            D:  _opcode = u ? ADDX : SUBX;
            B:  _opcode = NOOP;                // output 0, branching handled elsewhere
            default: _opcode = ADDX;            // used for D and B?
        endcase
    end
    
    alu a(.w_data1(w_data1), .w_data2(w_data2), .nzcv(nzcv), .rn(rn), .rm(rm_dec), .opcode(_opcode), .en(en), .Cin(Cin), .s(s));
endmodule
