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
    output logic [31:0] debug_instruction,
    output control_bus debug_cb,            // debug signal for ID
    output logic [15:0] debug_data1,
    output logic [15:0] debug_memdata1,
    input logic CLK,              // clock 
    input logic RESETN             // synchronous reset
    );

    //--------------------------------------------------------------------------
    // INSTRUCTION FETCH
    logic [15:0] pc_next, pc;
    localparam OFFSET_NONBRANCHING = 16'd4;

    logic stall;
    logic update_pc;
    assign update_pc = ~stall;    // TEMPORARY
    logic [15:0] exdm_outpc;

    pc_adder pca(
        .pc_next(pc_next),       
        .pc(pc),
        .offset(OFFSET_NONBRANCHING),
        .update_pc(update_pc)
    );

    always_ff@(posedge CLK) begin 
        if(!RESETN) begin 
            pc <= 16'b0;
        end
        else if(exdm_cb.branch) begin 
            pc <= exdm_outpc;
        end
        else begin 
            pc <= pc_next;
        end
    end

    logic [31:0] instruction;
    instr_mem im(
        .instruction(instruction),
        .r_address(pc)
    );

    logic [31:0] ifid_instruction;
    logic [15:0] ifid_pcnext, ifid_pc;
    IFID_reg ifid(
        .ifid_instruction(ifid_instruction),
        .ifid_pc_next(ifid_pcnext),
        .ifid_pc(ifid_pc),
        .instruction(instruction),
        .stall(stall),
        .pc_next(pc_next),
        .pc(pc),
        .clk(CLK),
        .resetn(RESETN)
    );
    
    //--------------------------------------------------------------------------
    // INSTRUCTION DECODE - TODO: hazard stuff
    // Signals from later stages
    logic [3:0] nzcv, prev_nzcv;
    logic [15:0] exdm_lr;

    always_ff @(posedge CLK) begin 
        if(!RESETN) begin 
            prev_nzcv <= 4'b0;
        end
        else begin 
            prev_nzcv <= nzcv;
        end
    end

    // Signals for this stage
    instruction_bus ib;
    assign ib = instruction_bus'(ifid_instruction);
    r_data rdata;
    // WB signals
    logic [15:0] dmwb_aludata1, dmwb_aludata2;
    logic [15:0] dmwb_memdata;
    instruction_bus dmwb_ib;
    control_bus dmwb_cb;

    logic [15:0] w_data1;
    assign w_data1 = dmwb_cb.mem2reg ? dmwb_memdata : dmwb_aludata1;

    reg_file rf(
        .r_data1(rdata.rn),
        .r_data2(rdata.rm),
        .r_data3(rdata.rs),
        .r_data4(rdata.rt),
        .r_reg1(ib.rn),
        .r_reg2(ib.op2[3:0]),
        .r_reg3(ib.op2[9:6]),
        .r_reg4(ib.rdt),
        .w_data1(w_data1),    // need to modify so that it takes in alu data or dm data
        .w_data2(dmwb_aludata2),
        .w_data3(ifid_pc),
        .w_data4(exdm_lr),
        .w_reg1(dmwb_ib.rdt),
        .w_reg2(dmwb_ib.op2[11:8]),
        .reg_write1(dmwb_cb.reg_write1),
        .reg_write2(dmwb_cb.reg_write2),
        .l(),
        .clk(CLK),
        .reset(RESETN)
    );

    control_bus cb;
    main_control mcu(
        .cb(cb),
        .ib(ib),
        .stall(stall),
        .nzcv(nzcv)
    );

    hazard_detection_unit hdu(
        .stall(stall),
        .ID_Rn(ib.rn),
        .ID_Rm(ib.op2[3:0]),
        .ID_usesRn(cb.uses_rn),
        .ID_usesRm(cb.uses_rm),
        .OP2_Rd(idop2_ib.rdt),
        .EX_Rd(op2ex_ib.rdt),
        .DM_Rd(exdm_ib.rdt),
        .WB_Rd(dmwb_ib.rdt),
        .OP2_regwrite1(idop2_cb.reg_write1),
        .EX_regwrite1(op2ex_cb.reg_write1),
        .DM_regwrite1(exdm_cb.reg_write1),
        .WB_regwrite1(dmwb_cb.reg_write1)
    );

    logic [15:0] idop2_Rn, idop2_Rm, idop2_Rs, idop2_Rt;
    instruction_bus idop2_ib;
    control_bus idop2_cb;
    logic [15:0] idop2_pcnext, idop2_pc;
    IDOP2_reg idop2(
        .idop2_ib(idop2_ib),
        .idop2_r_data1(idop2_Rn),
        .idop2_r_data2(idop2_Rm),
        .idop2_r_data3(idop2_Rs),
        .idop2_r_data4(idop2_Rt),
        .idop2_cb(idop2_cb),
        .idop2_pcnext(idop2_pcnext),
        .idop2_pc(idop2_pc),
        .ib(ib),
        .r_data1(rdata.rn),
        .r_data2(rdata.rm),
        .r_data3(rdata.rs),
        .r_data4(rdata.rt),
        .cb(cb),
        .pc_next(ifid_pcnext),
        .pc(ifid_pc),
        .clk(CLK),
        .resetn(RESETN)
    );
    //--------------------------------------------------------------------------
    // OP2 DECODE
    

    logic [15:0] rm_dec;
    op2_decode op2d(
        .rm_dec(rm_dec),
        .imm_m(idop2_ib.op2[7:0]),
        .rot_m(idop2_ib.op2[11:8]),
        .rm(idop2_Rm),
        .i(idop2_cb.i),
        .shtype(idop2_ib.op2[11:10]),
        .r_shift(idop2_ib.op2[4]),
        .shamt(idop2_ib.op2[9:6]),
        .rs(idop2_Rs)
    );

    instruction_bus op2ex_ib;
    control_bus op2ex_cb;
    logic [15:0] op2ex_Rmdec, op2ex_Rn; 
    logic [15:0] op2ex_Rm, op2ex_Rt;
    logic [15:0] op2ex_pc, op2ex_pcnext;
    OP2EX_reg op2ex(
        .op2ex_ib(op2ex_ib),
        .op2ex_cb(op2ex_cb),
        .op2ex_rmdec(op2ex_Rmdec),
        .op2ex_rn(op2ex_Rn),
        .op2ex_pcnext(op2ex_pcnext),
        .op2ex_pc(op2ex_pc),
        .op2ex_rm(op2ex_Rm),
        .op2ex_rt(op2ex_Rt),
        .ib(idop2_ib),
        .cb(idop2_cb),
        .rm_dec(rm_dec),
        .rn(idop2_Rn),
        .pc_next(idop2_pcnext),
        .pc(idop2_pc),
        .rm(idop2_Rm),
        .rt(idop2_Rt),
        .clk(CLK),
        .resetn(RESETN)
    );
    //--------------------------------------------------------------------------
    // EXECUTE
    logic [15:0] alu_data1, alu_data2;
    alu_top alt(
        .w_data1(alu_data1),
        .w_data2(alu_data2),
        .nzcv(nzcv),
        .rn(op2ex_Rn),
        .rm_dec(op2ex_Rmdec),
        .s(op2ex_cb.s_or_u),
        .Cin(prev_nzcv[1]),
        .en(op2ex_cb.alu_en),
        .instr_class(op2ex_cb.instr_class),
        .opcode(op2ex_cb.opcode),
        .u(op2ex_cb.s_or_u)
    );

    logic [15:0] lr;
    logic [15:0] out_pc;
    logic signed [15:0] offset_branching;
    branching_unit bu(
        .lr(lr),
        .out_pc(out_pc),
        .pc_next(op2ex_pcnext),
        .pc(op2ex_pc),
        .instr_offset(op2ex_ib.op2[9:0]),
        .rb(op2ex_Rm),
        .r(op2ex_ib.opcode[3]),
        .branch(op2ex_cb.branch)
    );

    logic [15:0] exdm_aludata1, exdm_aludata2;
    logic [15:0] exdm_Rt;
    instruction_bus exdm_ib;
    control_bus exdm_cb;
    EXDM_reg exdm(
        .exdm_aludata1(exdm_aludata1),
        .exdm_aludata2(exdm_aludata2),
        .exdm_outpc(exdm_outpc),
        .exdm_ib(exdm_ib),
        .exdm_cb(exdm_cb),
        .exdm_rt(exdm_Rt),
        .exdm_lr(exdm_lr),
        .ib(op2ex_ib),
        .cb(op2ex_cb),
        .alu_data1(alu_data1),
        .alu_data2(alu_data2),
        .out_pc(out_pc),
        .rt(op2ex_Rt),
        .lr(lr),
        .clk(CLK),
        .resetn(RESETN)
    );
    //--------------------------------------------------------------------------
    // DATA MEMORY
    
    logic [15:0] mem_data;
    data_memory dm(
        .r_data(mem_data),
        .w_data(exdm_Rt),
        .addr(exdm_aludata1),
        .mem_write(exdm_cb.mem_write),
        .mem_read(exdm_cb.mem_read),
        .byte_sel(exdm_cb.byte_sel),
        .clk(CLK),
        .reset(1'b1)    // permanently set to 1, so the memory won't get replaced during reset
    );
    // WAIT FOR DM
    instruction_bus w4d_ib; 
    control_bus w4d_cb;
    logic [15:0] w4d_aludata1, w4d_aludata2;
    WAIT4DM_reg w4d(
        .w4d_ib(w4d_ib),
        .w4d_cb(w4d_cb),
        .w4d_aludata1(w4d_aludata1),
        .w4d_aludata2(w4d_aludata2),
        .ib(exdm_ib),
        .cb(exdm_cb),
        .alu_data1(exdm_aludata1),
        .alu_data2(exdm_aludata2),
        .clk(CLK),
        .resetn(RESETN)
    );

    // TODO: signals for aludata1, aludata2, cb, and ib enter DM, but it takes
    // 2 cycles to take out mem_data from data memory. 
    DMWB_reg dmwb(
        .dmwb_ib(dmwb_ib),
        .dmwb_cb(dmwb_cb),
        .dmwb_aludata1(dmwb_aludata1),
        .dmwb_aludata2(dmwb_aludata2),
        .dmwb_memdata(dmwb_memdata),
        .ib(w4d_ib),
        .cb(w4d_cb),
        .alu_data1(w4d_aludata1),
        .alu_data2(w4d_aludata2),
        .mem_data(mem_data),
        .clk(CLK),
        .resetn(RESETN)
    );
    //--------------------------------------------------------------------------
    // DEBUG SIGNALS
    assign debug_instruction = ifid_instruction;
    assign debug_data1 = exdm_aludata1;
    assign debug_memdata1 = dmwb_memdata;
    assign debug_cb = dmwb_cb;
    
endmodule