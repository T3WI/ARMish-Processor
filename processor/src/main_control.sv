`timescale 1ns / 1ps
import cpu_pkg::*;
module main_control(
    /* 
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
    */
    output control_bus cb,
    input instruction_bus ib,
    input logic [3:0] nzcv
    );
    
    logic rw1, rw2, mw, mr, m2r;
    assign cb.i = ib.instr_ctrl[1];
    assign cb.s_or_u = ib.instr_ctrl[0];
    assign cb.instr_class = instr_t'(ib.instr_type);
    assign cb.opcode = operation_t'(ib.opcode);
    assign cb.alu_en = 1'b1 & cb.cond_met;           // TEMPORARY

    assign cb.reg_write1 = rw1 & cb.cond_met;
    assign cb.reg_write2 = rw2 & cb.cond_met;
    assign cb.mem_write = mw & cb.cond_met;
    assign cb.mem_read = mr & cb.cond_met;
    assign cb.mem2reg = m2r & cb.cond_met;
    assign cb.branch = (cb.instr_class == B) & cb.cond_met;

    cond_logic_block clb(
        .cond_met(cb.cond_met), 
        .cond(ib.cond), 
        .nzcv(nzcv)
        );

    always_comb begin 
        rw1 = 0;
        rw2 = 0; 
        mw = 0;
        m2r = 0;                           // 0 by default (ALU out)
        mr = 0;
        cb.byte_sel = 2'b00;
        case(ib.instr_type)
            B: 
            begin
                rw1 = 0;
                rw2 = 0; 
                mw = 0;
                mr = 0;
                m2r = 0;                           // 0 by default (ALU out)
                cb.byte_sel = 2'b00;
            end
            D: 
            begin 
                m2r = 1;                            // mem2reg doesn't matter for str, and 1 will represent memory data going to the register
                if(ib.opcode[3] == 1) begin          // STR         
                    rw1 = 0;
                    rw2 = 0;
                    mw = 1;
                    mr = 0;
                    // STW/STB2H/STB2L (option 1)
                    case(mem_op_t'(ib.opcode[3:1])) 
                        STW: cb.byte_sel = 2'b11;
                        STB2H: cb.byte_sel = 2'b10;
                        STB2L: cb.byte_sel = 2'b01;
                        default: cb.byte_sel = 2'b00;
                    endcase
                end
                else begin                              // LDR
                    rw1 = 1;                     // The data coming out of data memory will be 16 bits, so only 
                    rw2 = 0;
                    mw = 0;                     // mem shouldn't be written during ldr
                    mr = 1;
                    // LDW/LDB2H/LDB2L
                    case(mem_op_t'(ib.opcode[3:1])) 
                        LDW: cb.byte_sel = 2'b11;
                        LDB2H: cb.byte_sel = 2'b10;
                        LDB2L: cb.byte_sel = 2'b01;
                        default: cb.byte_sel = 2'b00;
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
                cb.byte_sel = 2'b00;
            end
            RX: 
            begin 
                rw1 = 1;
                if(operation_t'(ib.opcode) == MULX || operation_t'(ib.opcode) == DIVX) begin 
                    rw2 = 1;
                end
                else rw2 = 0;
                mw = 0;
                mr = 0;
                m2r = 0;
                cb.byte_sel = 2'b00;
            end
            default:
            begin 
                rw1 = 0;
                rw2 = 0; 
                mw = 0;
                mr = 0;
                m2r = 0;   
                cb.byte_sel = 2'b00;                      
            end
        endcase
    end

    
endmodule
