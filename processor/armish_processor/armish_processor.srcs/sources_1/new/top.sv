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
    enum logic[1:0] {IDLE=2'd0, LOAD_INSTR=2'd1, EXECUTE_PROGRAM=2'd2, FINISH=2'd3} curr_state, next_state;


    // Program Counter Signals
    logic [15:0] pc;
    logic [15:0] offset_nonbranching; 
    logic [15:0] pc_next;
    assign offset_nonbranching = 16'd4;
    
    // Instruction Memory Signals
    logic [31:0] instruction;

    // Register File Signals
    logic [15:0] r_data1, r_data2;
    
    pc_adder no_branch_adder(.pc_next(pc_next), .pc(pc), .offset(offset_nonbranching));
    instr_mem im(.instruction(instruction), .r_address(pc), .w_instruction(instrmem_w_instruction), .w_address(instrmem_w_address), .w_e(instrmem_we), .clk(clk));
    
    
    
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
                        if(instruction[31:28] == 4'd0) begin 
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







