`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 12:10:48 AM
// Design Name: 
// Module Name: cond_logic_block_sim
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
class scoreboard; 
    function automatic logic model(
        input cond_t cond, 
        input logic [3:0] nzcv
    );
        logic n, z, c, v;
        n = nzcv[3];
        z = nzcv[2];
        c = nzcv[1];
        v = nzcv[0];
        case(cond)
            EQ: model = z;
            NEQ: model = !z;
            CS: model = c;
            CC: model = !c;
            MI: model = n;
            PL: model = !n;
            VS: model = v;
            VC: model = !v;
            HI: model = c && !z;
            LS: model = !c || z;
            GE: model = n == v;
            LT: model = n != v;
            GT: model = !z && (n == v);
            LE: model = z || (n != v);
            AL: model = 1'b1;
            default: model = 1'b0;
        endcase
    endfunction 
    task automatic check(
        input logic cond_met,
        input cond_t cond, 
        input logic [3:0] nzcv
        );
        logic exp_cond_met = model(cond, nzcv);
        if(cond_met == exp_cond_met) begin 
            $display("[PASS] Expected: %b", exp_cond_met);
        end
        else begin 
            $display("[FAIL] Expected: %b | Actual: %b | COND: %s", exp_cond_met, cond_met, cond.name());
        end
    endtask
endclass

module cond_logic_block_sim;
    import cpu_pkg::*;
    logic clk;
    initial begin 
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    logic cond_met;
    logic [3:0] nzcv;
    cond_t cond;
    cond_logic_block clb(
        .cond_met(cond_met), 
        .nzcv(nzcv), 
        .cond(cond)
        );

    scoreboard sb;
    initial begin 
        sb = new();
        @(posedge clk);
        for(int i = 0; i < 16; i++) begin 
            cond = HALT;
            nzcv = i;
            $display("NZCV: %d", i);
            for(cond = cond.first(); ; cond = cond.next()) begin 
                @(posedge clk);
                sb.check(cond_met, cond, nzcv);
                if(cond == cond.last()) break;
                @(posedge clk);
                cond = cond.next();
            end
        end
        $finish;
    end
endmodule
