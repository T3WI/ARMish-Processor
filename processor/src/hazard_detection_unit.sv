module hazard_detection_unit(
    output logic stall,
    input logic [3:0] ID_Rn,
    input logic [3:0] ID_Rm,
    input logic ID_usesRn,
    input logic ID_usesRm,
    input logic [3:0] OP2_Rd,
    input logic [3:0] EX_Rd,
    input logic [3:0] DM_Rd,
    input logic [3:0] W4D_Rd,
    input logic [3:0] WB_Rd,
    // mem read
    input logic OP2_memread,
    input logic EX_memread,
    input logic DM_memread,
    input logic W4D_memread,
    input logic WB_memread,
    // reg write
    input logic OP2_regwrite1,
    input logic EX_regwrite1,
    input logic DM_regwrite1,
    input logic W4D_regwrite1,
    input logic WB_regwrite1
    // branch
    // input logic branch

);  
    // WITHOUT FORWARDING
    logic rn_hazard, rm_hazard;
    logic loaduse_rn, loaduse_rm;
    logic datastall_rn, datastall_rm;
    // logic branchstall;
    assign loaduse_rn = (ID_Rn == OP2_Rd && OP2_memread) ||
                        (ID_Rn == EX_Rd && EX_memread) || 
                        (ID_Rn == DM_Rd && DM_memread) ||
                        (ID_Rn == W4D_Rd && W4D_memread) ||
                        (ID_Rn == WB_Rd && WB_memread);

    assign loaduse_rm = (ID_Rm == OP2_Rd && OP2_memread) ||
                        (ID_Rm == EX_Rd && EX_memread) || 
                        (ID_Rm == DM_Rd && DM_memread) ||
                        (ID_Rm == W4D_Rd && W4D_memread) ||
                        (ID_Rm == WB_Rd && WB_memread);

    assign datastall_rn = (ID_Rn == OP2_Rd && OP2_regwrite1) ||
                          (ID_Rn == EX_Rd && EX_regwrite1) || 
                          (ID_Rn == DM_Rd && DM_regwrite1) ||
                          (ID_Rn == W4D_Rd && W4D_regwrite1) ||
                          (ID_Rn == WB_Rd && WB_regwrite1);
    
    assign datastall_rm = (ID_Rm == OP2_Rd && OP2_regwrite1) ||
                          (ID_Rm == EX_Rd && EX_regwrite1) || 
                          (ID_Rm == DM_Rd && DM_regwrite1) ||
                          (ID_Rm == W4D_Rd && W4D_regwrite1) ||
                          (ID_Rm == WB_Rd && WB_regwrite1);

    // assign branchstall = 


    assign rn_hazard =  (ID_Rn != 0) && 
    (
        loaduse_rn || datastall_rn 
    );
    assign rm_hazard =  (ID_Rm != 0) && 
    (
        loaduse_rm || datastall_rm 
    );
    assign stall = rn_hazard || rm_hazard;
endmodule
    