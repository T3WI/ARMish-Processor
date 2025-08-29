`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2025 05:38:34 PM
// Design Name: 
// Module Name: shifter
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


module shifter(
    output logic [15:0] shifted_rm,
    input logic [15:0] rm,
    input logic [15:0] imm,
    input logic [3:0] rs,
    input logic [3:0] shamt,
    input logic [1:0] shtype,
    input logic r_shift,
    input logic i
    );
    enum logic [1:0] {ROR=2'd0, ASR=2'd1, LSR=2'd2, LSL=2'd3} shtype_t;
    
    function automatic logic [15:0] shift(
        input logic [15:0] operand, 
        input logic [2:0] shtype, 
        input logic [3:0] shift_amount);
        case(shtype)
            ROR:       // ROR
            begin 
                shift = (operand >> shift_amount) | (operand << (16 - shift_amount));        
            end
            ASR:       // ASR 
            begin 
                shift = operand >>> shift_amount;
            end
            LSR:       // LSR
            begin 
                shift = operand >> shift_amount;
            end
            LSL:       // LSL
            begin 
                shift = operand << shift_amount;
            end 
            default: shift = 0;
        endcase
    endfunction

    logic [15:0] value, shifted_value;
    logic [3:0] shift_amount;
    assign value = i ? imm : rm;
    assign shift_amount = r_shift ? rs : shamt;
    assign shifted_value = shift(value, shtype, shift_amount);
    assign shifted_rm = i ? value : shifted_value;
endmodule
