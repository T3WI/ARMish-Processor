`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 12:39:13 AM
// Design Name: 
// Module Name: alu
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
typedef enum logic [3:0] {ADDX, SUBX, MULX, DIVX, ABSX, ADCX, SBCX, CMPX, NOTX, ANDX, ORRX, XORX} operation_t;

module alu(
    output logic [15:0] w_data1,
    output logic [15:0] w_data2,
    output logic [3:0] nzcv,
    
    input logic [15:0] rn,
    input logic [15:0] rm,  
    
    input operation_t opcode,

    input logic en,
    input logic Cin,
    input logic s
    );
        


    function logic [16:0] addx(input logic signed [15:0] rn, input logic signed [15:0] rm, input logic Cin);
        return rn + rm + Cin;
    endfunction

    function logic [16:0] subx(input logic signed [15:0] rn, input logic signed [15:0] rm, input logic Cin);
        return addx(rn, ~rm, Cin);
    endfunction

    function logic [31:0] mulx(input logic signed [15:0] rn, input logic signed [15:0] rm);
        return rn * rm;
    endfunction

    function logic [31:0] divx(input logic signed [15:0] rn, input logic signed [15:0] rm);
        logic signed [15:0] quotient;
        logic signed [15:0] remainder;
        logic [31:0] result;
        if(rm == 0) begin 
            return 32'hFFFF_FFFF;
        end 
        else begin 
            quotient = rn / rm;
            remainder = rn % rm;
            result[31:16] = quotient;
            result[15:0] = remainder;
            return result;
        end
    endfunction

    function logic [15:0] absx(input logic signed [15:0] rn);
        return (rn[15]) ? -rn : rn;
    endfunction 
    

    logic [16:0] temp;
    logic [31:0] big_temp;
    always_comb begin 
        w_data1 = 16'b0;
        w_data2 = 16'b0;
        nzcv = 4'b0;
        temp = 17'd0;
        if(~en) begin
            w_data1 = 16'b0;
            w_data2 = 16'b0;
            nzcv = 4'b0; 
        end
        else begin 
            case(opcode)
                ADDX: 
                begin 
                    temp = addx(rn, rm, 0);
                    w_data1 = temp[15:0];
                    w_data2 = 16'd0;
                    if(s) begin 
                        nzcv[3] = temp[15];
                        nzcv[2] = (w_data1 == 0);
                        nzcv[1] = temp[16];
                        nzcv[0] = (temp[15] ^ rn[15]) & (~(rn[15] ^ rm[15]));
                    end
                end
                SUBX:
                begin
                    temp = subx(rn, rm, 1);
                    w_data1 = temp[15:0];
                    w_data2 = 16'd0;
                    if(s) begin 
                        nzcv[3] = temp[15];
                        nzcv[2] = (w_data1 == 0);
                        nzcv[1] = temp[16];
                        nzcv[0] = (rn[15] ^ rm[15]) & (temp[15] ^ rn[15]); 
                    end
                end 
                MULX:
                begin
                    big_temp = mulx(rn, rm); 
                    w_data1 = big_temp[31:16];
                    w_data2 = big_temp[15:0];
                end
                DIVX: 
                begin
                    big_temp = divx(rn, rm);
                    w_data1 = big_temp[31:16];
                    w_data2 = big_temp[15:0]; 
                end
                ABSX:
                begin 
                    w_data1 = absx(rn);
                    w_data2 = 16'd0;
                end
                ADCX: 
                begin 
                    temp = addx(rn, rm, Cin);
                    w_data1 = temp[15:0];
                    w_data2 = 16'd0;
                    if(s) begin 
                        nzcv[3] = temp[15];
                        nzcv[2] = (w_data1 == 0);
                        nzcv[1] = temp[16];
                        nzcv[0] = (temp[15] ^ rn[15]) & (~(rn[15] ^ rm[15]));
                    end
                end
                SBCX: 
                begin 
                    temp = subx(rn, rm, Cin);
                    w_data1 = temp[15:0];
                    w_data2 = 16'd0;
                    if(s) begin 
                        nzcv[3] = temp[15];
                        nzcv[2] = (w_data1 == 0);
                        nzcv[1] = temp[16];
                        nzcv[0] = (rn[15] ^ rm[15]) & (temp[15] ^ rn[15]); 
                    end
                end
                default:
                begin
                    w_data1 = 16'd0;
                    w_data2 = 16'd0;
                    nzcv = 4'd0;
                    temp = 17'd0;
                end
            endcase
        end
        
    end
endmodule
