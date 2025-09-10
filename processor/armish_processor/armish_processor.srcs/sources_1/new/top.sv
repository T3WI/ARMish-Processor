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

    // Control Unit
    // main_control mcu(
    
    // );

    // Register File Signals
    logic [3:0]     r_reg1, r_reg2, r_reg3;
    logic [15:0]    r_data1, r_data2, r_data3;
    logic [3:0]     w_reg1, w_reg2;
    logic [15:0]    w_data1, w_data2;
    logic           reg_write1, reg_write2;

    // Register file input logic 
    assign r_reg1 = instruction[19:16];         // Rn
    assign r_reg2 = instruction[3:0];           // Rm
    assign r_reg3 = instruction[9:6];           // Rs
    assign w_reg1 = instruction[15:12];         // Rd1
    assign w_reg2 = instruction[11:8];              // Rd2
    reg_file rf(
        .r_data1(r_data1), 
        .r_data2(r_data2), 
        .r_data3(r_data3), 
        .r_reg1(r_reg1), 
        .r_reg2(r_reg2), 
        .r_reg3(r_reg3),
        .w_data1(w_data1),
        .w_data2(w_data2),
        .w_reg1(w_reg1),
        .w_reg2(w_reg2),
        .reg_write1(1'b1),                      // TEMPORARY 1'b1
        .reg_write2(1'b1),
        .clk(clk),
        .reset(reset)
        );
    
    // op2_decode Signals
    logic [15:0] rm_dec;
    logic [7:0] imm_m;
    logic [3:0] rot_m;
    logic [15:0] rm;
    logic i;        
    logic [1:0] shtype;
    logic r_shift;
    logic [3:0] shamt;
    logic [15:0] rs;

    assign imm_m = instruction[7:0];
    assign rot_m = instruction[11:8];
    assign rm = r_data2;
    assign i = instruction[21];                 // PUT INTO CONTROL UNIT
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

    // alu top signals
    logic [3:0] nzcv;
    logic [15:0] rn;
    logic s;                        // soru
    logic Cin;
    logic en; 
    logic [1:0] instr_class;
    logic [3:0] opcode;
    logic u;                        // soru

    assign s = instruction[20];     // also U for D instructions    // GOES INTO CONTROL UNIT
    assign en = 1'b1;               // temporary
    assign instr_class = instruction[27:26];                        // GOES INTO CONTROL UNIT
    assign opcode = instruction[25:22];                             // GOES INTO CONTROL UNIT
    assign u = instruction[20];     // also S for RX instructions   // GOES INTO CONTROL UNIT

    alu_top alt(
        .w_data1(w_data1), 
        .w_data2(w_data2),
        .nzcv(nzcv),
        .rn(r_data1),
        .rm_dec(rm_dec),
        .s(s),
        .Cin(nzcv[1]),
        .en(en),
        .instr_class(instr_class),
        .opcode(opcode),
        .u(u)
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
                    if(load_done) begin                 // testbench should raise load_done somehow 
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







