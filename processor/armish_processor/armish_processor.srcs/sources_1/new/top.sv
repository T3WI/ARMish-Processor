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
    output logic load_done,
    output logic execute_done,
    input logic clk,              // clock 
    input logic reset,             // synchronous reset
    input logic load_ready
    );
    enum logic[1:0] {IDLE=2'd0, LOAD_INSTR=2'd1, EXECUTE_PROGRAM=2'd2, FINISH=2'd3} curr_state, next_state;

    // FSM Control
    logic w_e;

    // CPU signals
    logic [15:0] pc;
    logic [15:0] offset_nonbranching; 
    logic [15:0] pc_next;

    // Program counter: No branching
    assign offset_nonbranching = 16'd4;
    pc_adder no_branch_adder(.pc_next(pc_next), .pc(pc), .offset(offset_nonbranching));
    
    always_ff@(posedge clk) begin 
        if(reset) begin 
            curr_state <= IDLE;
            load_done <= 1'b0;
            execute_done <= 1'b0;
            done <= 1'b1;
        end
        else begin 
            case(curr_state)
                IDLE: begin 
                    done <= 1'b1;
                    if(load_ready) begin 
                        curr_state <= LOAD_INSTR;
                        w_e <= 1'b1;
                    end
                    else begin 
                        curr_state <= IDLE;
                    end
                end
                LOAD_INSTR: begin 
                    done <= 1'b0;
                    if(load_done) begin                 // testbench should raise load_done somehow 
                        curr_state <= EXECUTE_PROGRAM;
                        w_e <= 1'b0;
                    end
                    else begin 
                        curr_state <= LOAD_INSTR;
                        load_done <= 1'b1;          // FOR TESTING FSM
                    end
                end
                EXECUTE_PROGRAM: begin 
                    done <= 1'b0;
                    if(execute_done) begin 
                        curr_state <= IDLE;
                    end 
                    else begin 
                        curr_state <= EXECUTE_PROGRAM;
                        execute_done <= 1'b1;       // FOR TESTING FSM
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










