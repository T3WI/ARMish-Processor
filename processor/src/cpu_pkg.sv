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
    typedef enum logic[3:0] {HALT, AL, LE, GT, LT, GE, LS, HI, VC, VS, PL, MI, CC, CS, NEQ, EQ} cond_t;
    typedef enum logic [1:0] {B, D, RF, RX} instr_t;
    typedef enum logic [3:0] {ADDX, SUBX, MULX, DIVX, ABSX, ADCX, SBCX, CMPX, NOTX, ANDX, ORRX, XORX, NOOP} operation_t;
    typedef enum logic [2:0] {LDW=3'b011, LDB2L=3'b000, LDB2H=3'b001, STW=3'b111, STB2L=3'b100, STB2H=3'b101} mem_op_t;
    typedef enum logic [1:0] {J=2'b00, JL=2'b01, JX=2'b10} branch_op_t; // SIM ONLY
    typedef struct packed {
        logic [3:0] cond;           // instruction[31:28] 
        logic [1:0] instr_type;     // instruction[27:26]
        logic [3:0] opcode;         // instruction[25:22]
        logic [1:0] instr_ctrl;     // instruction[21:20]
        logic [3:0] rn;             // instruction[19:16]
        logic [3:0] rdt;            // instruction[15:12]
        logic [11:0] op2;           // instruction[11:0]
    } instruction_bus;
    typedef struct {
        logic [15:0] rn;
        logic [15:0] rm;
        logic [15:0] rs;
        logic [15:0] rt;
    } r_data;
    typedef struct packed{
        logic reg_write1;
        logic reg_write2;
        logic mem_write;
        logic mem2reg; 
        logic i;
        logic s_or_u; 
        instr_t instr_class;
        operation_t opcode; 
        logic alu_en;
        logic mem_read; 
        logic [1:0] byte_sel;
        logic cond_met;
        logic branch; 
    } control_bus;
    typedef struct packed{
        logic valid;
        logic [7:0] data;
    } mem_loc_t;
    
endpackage
