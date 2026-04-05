module hazard_detection_unit(
    output logic stall,
    input logic [3:0] ID_Rn,
    input logic [3:0] ID_Rm,
    input logic ID_usesRn,
    input logic ID_usesRm,
    input logic [3:0] OP2_Rd,
    input logic [3:0] EX_Rd,
    input logic [3:0] DM_Rd,
    input logic [3:0] WB_Rd,
    input logic OP2_regwrite1,
    input logic EX_regwrite1,
    input logic DM_regwrite1,
    input logic WB_regwrite1

);
    logic rn_hazard, rm_hazard;
    assign rn_hazard = ID_usesRn && (ID_Rn != 0) && (
                        (ID_Rn == OP2_Rd && OP2_regwrite1) ||
                        (ID_Rn == EX_Rd && EX_regwrite1) ||
                        (ID_Rn == DM_Rd && DM_regwrite1) ||
                        (ID_Rn == WB_Rd && WB_regwrite1)
    );
    assign rm_hazard = ID_usesRm && (ID_Rm != 0) && (
                        (ID_Rm == OP2_Rd && OP2_regwrite1) ||
                        (ID_Rm == EX_Rd && EX_regwrite1) ||
                        (ID_Rm == DM_Rd && DM_regwrite1) ||
                        (ID_Rm == WB_Rd && WB_regwrite1)
    );
    assign stall = rn_hazard || rm_hazard;
endmodule
    