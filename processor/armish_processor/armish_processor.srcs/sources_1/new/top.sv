`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2025 01:28:35 PM
// Design Name: 
// Module Name: top
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
module top(
    output logic done,
    output logic execute_done,
    input logic [9:0] instrmem_w_address,
    input logic [31:0] instrmem_w_instruction,
    input logic instrmem_we,
    input logic clk,              // clock 
    input logic reset,             // synchronous reset
    input logic load_ready,
    input logic load_done
    );
    program_state curr_state;
    

    // Program Counter Signals
    logic [15:0] pc;
    logic [15:0] offset_nonbranching; 
    logic [15:0] pc_next;
    assign offset_nonbranching = 16'd4;

    pc_adder no_branch_adder(
        .pc_next(pc_next), 
        .pc(pc), 
        .offset(offset_nonbranching)
        );
    
    // Instruction Memory Signals
    logic [31:0] instruction;
    instr_mem im(
        .instruction(instruction), 
        .r_address(pc), 
        .w_instruction(instrmem_w_instruction), 
        .w_address(instrmem_w_address), 
        .w_e(instrmem_we), 
        .clk(clk)
        );
    //****************************************************************************************************************//
    // Control Unit Signals
    logic reg_write1, reg_write2, mem_write, mem_read, mem2reg;
    logic [1:0] byte_sel;
    logic i, s_or_u, alu_en, cond_met;       
    instr_t instr_class;
    operation_t opcode; 
    logic [3:0] nzcv, prev_nzcv;
    // Register File Signals
    logic [3:0]     r_reg1, r_reg2, r_reg3, r_reg4;
    logic [15:0]    r_data1, r_data2, r_data3, r_data4;
    logic [3:0]     w_reg1, w_reg2;
    logic [15:0]    w_data1, w_data2;
    logic[15:0]     alu_data1, alu_data2;
    // op2_decode Signals
    logic [15:0] rm_dec;
    logic [7:0] imm_m;
    logic [3:0] rot_m;
    logic [15:0] rm;
    logic [1:0] shtype;
    logic r_shift;
    logic [3:0] shamt;
    logic [15:0] rs;
    // alu top signals
    logic [15:0] rn;
    logic Cin; 
    // data memory signals
    logic [15:0] mem_data;

    // WB Signals
    logic [15:0] wb_alu_data1, wb_alu_data2;
    logic [3:0] wb_w_reg1, wb_w_reg2;
    logic [15:0] wb_mem_data;
    logic wb_mem2reg, wb_reg_write1, wb_reg_write2;




    // nzcv flag update
    always_ff @(posedge clk) begin 
        if(reset) begin 
            prev_nzcv <= 0;
        end
        else begin 
            prev_nzcv <= nzcv;
        end
    end
    

    main_control mcu(
        .reg_write1(reg_write1),
        .reg_write2(reg_write2),
        .mem_write(mem_write),          
        .mem2reg(mem2reg),              // unused until data mem is implemented
        .i(i),
        .s_or_u(s_or_u),
        .instr_class(instr_class),
        .opcode(opcode),
        .alu_en(alu_en),
        .mem_read(mem_read),
        .byte_sel(byte_sel),
        .cond_met(cond_met),
        .instruction(instruction),
        .nzcv(prev_nzcv)
    ); 

    // Register file input logic 
    assign r_reg1 = instruction[19:16];         // Rn
    assign r_reg2 = instruction[3:0];           // Rm
    assign r_reg3 = instruction[9:6];           // Rs
    assign r_reg4 = instruction[15:12];
    assign w_reg1 = instruction[15:12];         // Rd1
    assign w_reg2 = instruction[11:8];              // Rd2

    assign w_data1 = wb_mem2reg ? mem_data : wb_alu_data1;      // change to wb_mem_data later?
    assign w_data2 = wb_alu_data2;
    reg_file rf(
        .r_data1(r_data1), 
        .r_data2(r_data2), 
        .r_data3(r_data3), 
        .r_data4(r_data4),
        .r_reg1(r_reg1), 
        .r_reg2(r_reg2), 
        .r_reg3(r_reg3),
        .r_reg4(r_reg4),
        .w_data1(w_data1),
        .w_data2(w_data2),
        .w_reg1(wb_w_reg1),
        .w_reg2(wb_w_reg2),
        .reg_write1(wb_reg_write1),                      
        .reg_write2(wb_reg_write2),
        .clk(clk),
        .reset(reset)
        );


    // op2dec
    assign imm_m = instruction[7:0];
    assign rot_m = instruction[11:8];
    assign rm = r_data2;

    assign shtype = instruction[11:10];
    assign r_shift = instruction[4];
    assign shamt = instruction[9:6];
    assign rs = r_data3;

    op2_decode o2d(
        .rm_dec(rm_dec),
        .imm_m(imm_m),
        .rot_m(rot_m),
        .rm(rm),
        .i(i),
        .shtype(shtype),
        .r_shift(r_shift),
        .shamt(shamt),
        .rs(rs)
    );

    alu_top alt(
        .w_data1(alu_data1), 
        .w_data2(alu_data2),
        .nzcv(nzcv),
        .rn(r_data1),
        .rm_dec(rm_dec),
        .s(s_or_u),
        .Cin(nzcv[1]),
        .en(alu_en),
        .instr_class(instr_class),
        .opcode(opcode),
        .u(s_or_u)
    );

    
    data_memory dm(
        .r_data(mem_data),              
        .w_data(r_data4),                          
        .addr(alu_data1),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .byte_sel(byte_sel),
        .clk(clk),
        .reset(reset)
    );

    
    wb_reg wb(
        .wb_alu_data1(wb_alu_data1),    //
        .wb_alu_data2(wb_alu_data2),    //
        .wb_w_reg1(wb_w_reg1),          //
        .wb_w_reg2(wb_w_reg2),          //
        .wb_mem_data(wb_mem_data),      //
        .wb_mem2reg(wb_mem2reg),        //
        .wb_reg_write1(wb_reg_write1),  //
        .wb_reg_write2(wb_reg_write2),  //

        .alu_data1(alu_data1),
        .alu_data2(alu_data2),
        .w_reg1(w_reg1),
        .w_reg2(w_reg2),
        .mem_data(mem_data),
        .mem2reg(mem2reg),
        .reg_write1(reg_write1),
        .reg_write2(reg_write2),

        .clk(clk),
        .reset(reset)
    );

    
    always_ff@(posedge clk) begin 
        if(reset) begin 
            curr_state <= IDLE;
            execute_done <= 1'b0;
            done <= 1'b1;
        end
        else begin 
            case(curr_state)
                IDLE: begin 
                    done <= 1'b1;
                    if(load_ready) begin 
                        curr_state <= LOAD_INSTR;
                    end
                    else begin 
                        curr_state <= IDLE;
                    end
                end
                LOAD_INSTR: begin 
                    done <= 1'b0;
                    if(load_done) begin                 
                        curr_state <= EXECUTE_PROGRAM;
                        pc <= 16'b0;
                    end
                    else begin 
                        curr_state <= LOAD_INSTR;   
                    end
                end
                EXECUTE_PROGRAM: begin 
                    done <= 1'b0;
                    if(execute_done) begin 
                        curr_state <= IDLE;
                    end 
                    else begin 
                        if(cond_t'(instruction[31:28]) == HALT) begin // STOP PROGRAM
                            execute_done <= 1'b1;
                        end
                        curr_state <= EXECUTE_PROGRAM;
                        pc <= pc_next;
                    end
                end
                default: begin
                    done <= 1'b1;
                    curr_state <= IDLE; 
                end
            endcase
        end
    end
endmodule







