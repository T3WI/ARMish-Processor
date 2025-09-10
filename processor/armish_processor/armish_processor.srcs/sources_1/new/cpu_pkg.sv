`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 10:27:59 PM
// Design Name: 
// Module Name: cpu_pkg
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


package cpu_pkg;
    typedef enum logic[1:0] {IDLE=2'd0, LOAD_INSTR=2'd1, EXECUTE_PROGRAM=2'd2, FINISH=2'd3} program_state;
    typedef enum logic[3:0] {HALT, AL, LE, GT, LT, GE, LS, HI, VC,  VS, PL, MI, CC, CS, NEQ, EQ} cond_t;
    typedef enum logic [1:0] {B, D, RF, RX} instr_t;
    typedef enum logic [3:0] {ADDX, SUBX, MULX, DIVX, ABSX, ADCX, SBCX, CMPX, NOTX, ANDX, ORRX, XORX, NOOP} operation_t;
endpackage
