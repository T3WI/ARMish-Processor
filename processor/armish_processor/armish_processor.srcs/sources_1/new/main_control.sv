`timescale 1ns / 1ps
import cpu_pkg::*;
module main_control(
    output logic reg_write1,        
    output logic reg_write2,        
    output logic mem_write,        
    output logic mem2reg,
    output logic i,                 
    output logic s_or_u,            
    output instr_t instr_class,     
    output operation_t opcode,      
    output logic alu_en,                
    input logic [31:0] instruction
    );
    
    assign i = instruction[21];
    assign s_or_u = instruction[20];
    assign instr_class = instr_t'(instruction[27:26]);
    assign opcode = operation_t'(instruction[25:22]);
    assign alu_en = 1'b1;           // TEMPORARY

    always_comb begin 
        reg_write1 = 0;
        reg_write2 = 0; 
        mem_write = 0;
        mem2reg = 0;                           // 0 by default (ALU out)
        case(instruction[27:26])
            B: 
            begin
                reg_write1 = 0;
                reg_write2 = 0; 
                mem_write = 0;
                mem2reg = 0;                           // 0 by default (ALU out)
            end
            D: 
            begin 
                mem2reg = 1;                            // mem2reg doesn't matter for str, and 1 will represent memory data going to the register
                if(instruction[25] == 1) begin          // STR         
                    reg_write1 = 0;
                    reg_write2 = 0;
                    mem_write = 1;
                end
                else begin                              // LDR
                    reg_write1 = 1;                     // The data coming out of data memory will be 16 bits, so only 
                    reg_write2 = 0;
                    mem_write = 0;                     // mem shouldn't be written during ldr
                end 
            end
            RF: 
            begin 
                reg_write1 = 1;
                reg_write2 = 0;
                mem_write = 0;
                mem2reg = 0;
            end
            RX: 
            begin 
                reg_write1 = 1;
                if(operation_t'(instruction[25:22]) == MULX || operation_t'(instruction[25:22]) == DIVX) begin 
                    reg_write2 = 1;
                end
                else reg_write2 = 0;
                mem_write = 0;
                mem2reg = 0;
            end
            default:
            begin 
                reg_write1 = 0;
                reg_write2 = 0; 
                mem_write = 0;
                mem2reg = 0;                          
            end
        endcase
    end
endmodule
