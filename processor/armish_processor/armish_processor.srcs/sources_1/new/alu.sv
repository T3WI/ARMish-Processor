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
        


    function logic [16:0] addx(input logic [15:0] rn, input logic [15:0] rm, input logic Cin);
        return rn + rm + Cin;
    endfunction

    function logic [16:0] subx(input logic [15:0] rn, input logic [15:0] rm);
        return addx(rn, ~rm, 1);
    endfunction

    

    logic [16:0] temp;
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
                    temp = subx(rn, rm);
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
