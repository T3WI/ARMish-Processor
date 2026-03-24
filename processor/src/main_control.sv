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
    output logic mem_read,      // NEW!
    output logic [1:0] byte_sel, // NEW!
    output logic cond_met,          
    output logic branch,     
    input logic [31:0] instruction,
    input logic [3:0] nzcv
    );
    
    logic rw1, rw2, mw, mr, m2r;
    assign i = instruction[21];
    assign s_or_u = instruction[20];
    assign instr_class = instr_t'(instruction[27:26]);
    assign opcode = operation_t'(instruction[25:22]);
    assign alu_en = 1'b1 & cond_met;           // TEMPORARY

    assign reg_write1 = rw1 & cond_met;
    assign reg_write2 = rw2 & cond_met;
    assign mem_write = mw & cond_met;
    assign mem_read = mr & cond_met;
    assign mem2reg = m2r & cond_met;
    assign branch = (instr_class == B) & cond_met;

    cond_logic_block clb(
        .cond_met(cond_met), 
        .cond(instruction[31:28]), 
        .nzcv(nzcv)
        );

    always_comb begin 
        rw1 = 0;
        rw2 = 0; 
        mw = 0;
        m2r = 0;                           // 0 by default (ALU out)
        mr = 0;
        byte_sel = 2'b00;
        case(instruction[27:26])
            B: 
            begin
                rw1 = 0;
                rw2 = 0; 
                mw = 0;
                mr = 0;
                m2r = 0;                           // 0 by default (ALU out)
                byte_sel = 2'b00;
            end
            D: 
            begin 
                m2r = 1;                            // mem2reg doesn't matter for str, and 1 will represent memory data going to the register
                if(instruction[25] == 1) begin          // STR         
                    rw1 = 0;
                    rw2 = 0;
                    mw = 1;
                    mr = 0;
                    // STW/STB2H/STB2L (option 1)
                    case(mem_op_t'(instruction[25:23])) 
                        STW: byte_sel = 2'b11;
                        STB2H: byte_sel = 2'b10;
                        STB2L: byte_sel = 2'b01;
                        default: byte_sel = 2'b00;
                    endcase
                end
                else begin                              // LDR
                    rw1 = 1;                     // The data coming out of data memory will be 16 bits, so only 
                    rw2 = 0;
                    mw = 0;                     // mem shouldn't be written during ldr
                    mr = 1;
                    // LDW/LDB2H/LDB2L
                    case(mem_op_t'(instruction[25:23])) 
                        LDW: byte_sel = 2'b11;
                        LDB2H: byte_sel = 2'b10;
                        LDB2L: byte_sel = 2'b01;
                        default: byte_sel = 2'b00;
                    endcase
                end 
            end
            RF: 
            begin 
                rw1 = 1;
                rw2 = 0;
                mw = 0;
                mr = 0;
                m2r = 0;
                byte_sel = 2'b00;
            end
            RX: 
            begin 
                rw1 = 1;
                if(operation_t'(instruction[25:22]) == MULX || operation_t'(instruction[25:22]) == DIVX) begin 
                    rw2 = 1;
                end
                else rw2 = 0;
                mw = 0;
                mr = 0;
                m2r = 0;
                byte_sel = 2'b00;
            end
            default:
            begin 
                rw1 = 0;
                rw2 = 0; 
                mw = 0;
                mr = 0;
                m2r = 0;   
                byte_sel = 2'b00;                      
            end
        endcase
    end

    
endmodule
