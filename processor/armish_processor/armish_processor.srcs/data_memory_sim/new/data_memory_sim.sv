`timescale 1ns/1ps
import cpu_pkg::*;
class scoreboard;
    mem_loc_t exp_mem[0:255];
    logic [15:0] temp;

    task stw_mem();
        for(int i = 0; i < 256; i += 2) begin 
            temp = (16'h1234*i) % 65536;
            exp_mem[i].data = temp[15:8];
            exp_mem[i+1].data = temp[7:0];
            exp_mem[i].valid = 1;
            exp_mem[i+1].valid = 1;
        end
    endtask

    task stb2h_mem();
        for(int i = 0; i < 256; i++) begin 
            temp = (16'h1234*i) % 65536;
            exp_mem[i].data = temp[15:8];
            exp_mem[i].valid = 1;
        end
    endtask

    task stb2l_mem();
        for(int i = 0; i < 256; i++) begin 
            temp = (16'h1234*i) % 65536;
            exp_mem[i].data = temp[7:0];
            exp_mem[i].valid = 1;
        end
    endtask
     

    task check_mem(input mem_loc_t data_mem, input int i);
        if((data_mem.data == exp_mem[i].data) && (data_mem.valid == exp_mem[i].valid))begin 
            $display("[PASS] (%3d) Expected: %d", i, exp_mem[i].data);
        end
        else begin 
            $display("[FAIL] (%3d) Expected Data: %d | Actual Data: %d | Expected Valid: %b | Actual Valid: %b", i, exp_mem[i].data, data_mem.data, exp_mem[i].valid, data_mem.valid);
        end 
    endtask 

    task check_read(input logic [15:0] r_data, input int i, input logic [1:0] byte_sel);
        logic [15:0] exp_r_data;
        case(byte_sel)
            2'b11: exp_r_data = {exp_mem[i].data, exp_mem[i+1].data};
            2'b10: exp_r_data = {exp_mem[i].data, 8'b0};
            2'b01: exp_r_data = {8'b0, exp_mem[i].data};
            default: ; 
        endcase 
        if(r_data == exp_r_data) begin 
            $display("[PASS] (%3d) Expected: %16h", i, exp_r_data);
        end
        else begin 
            $display("[FAIL] (%3d) Expected: %4h | Actual: %4h", i, exp_r_data, r_data);
        end
    endtask 
endclass

module data_memory_sim;
    logic clk, reset;
    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end
    logic [15:0] w_data, r_data, addr;
    logic mem_write, mem_read;
    logic [1:0] byte_sel;
    data_memory dm(
        .w_data(w_data), 
        .r_data(r_data), 
        .addr(addr), 
        .mem_write(mem_write), 
        .mem_read(mem_read), 
        .byte_sel(byte_sel), 
        .clk(clk), 
        .reset(reset)
        );

    task reset_inputs();
        mem_write <= 0;
        mem_read <= 0;
        w_data <= 0;
        addr <= 0;
    endtask 

    task toggle_reset();
        reset <= 1;
        @(posedge clk);
        reset <= 0;
    endtask

    task test_str(input logic[1:0] sel);
        toggle_reset();
        @(posedge clk);
        reset_inputs();
        @(posedge clk);
        byte_sel <= sel;
        @(posedge clk);
        case(byte_sel)
            2'b11: $display("========== STW TEST ==========");
            2'b10: $display("========== STB2H TEST ==========");
            2'b01: $display("========== STB2L TEST ==========");
            default: $display("man why did it enter default");
        endcase
        mem_write <= 1;
        addr <= 0;
        if(sel == 2'b11) begin 
            for(int i = 0 ; i < 256; i+=2) begin 
                w_data <= (16'h1234*i) % 65536;
                addr <= i;
                @(posedge clk);
                @(posedge clk);
            end
        end
        else begin 
            for(int i = 0 ; i < 256; i++) begin 
                w_data <= (16'h1234*i) % 65536;
                addr <= i;
                @(posedge clk);
                @(posedge clk);
            end
        end
        @(posedge clk);
        reset_inputs();
        @(posedge clk);
        case(byte_sel)
            2'b11: sb.stw_mem();
            2'b10: sb.stb2h_mem();
            2'b01: sb.stb2l_mem();
            default: $display("man why did it enter default");
        endcase
        @(posedge clk);
        for(int i = 0; i < 256; i++) begin 
            sb.check_mem(dm.data_mem[i], i);
        end
    endtask 

    task test_ldr(input logic [1:0] sel);
        toggle_reset();
        @(posedge clk);
        reset_inputs();
        @(posedge clk);
        byte_sel <= sel;
        @(posedge clk);
        case(byte_sel)
            2'b11: $display("========== %2b LDW TEST ==========", byte_sel);
            2'b10: $display("========== %2b LDB2H TEST ==========", byte_sel);
            2'b01: $display("========== %2b LDB2L TEST ==========", byte_sel);
            default: $display("man why did it enter default");
        endcase
        mem_write <= 1;
        addr <= 0;
        @(posedge clk);
        if(sel == 2'b11) begin 
            for(int i = 0 ; i < 256; i+=2) begin 
                w_data <= (16'h1234*i) % 65536;
                addr <= i;
                @(posedge clk);
                @(posedge clk);
            end
        end
        else begin 
            for(int i = 0 ; i < 256; i++) begin 
                w_data <= (16'h1234*i) % 65536;
                addr <= i;
                @(posedge clk);
                @(posedge clk);
            end
        end
        @(posedge clk);
        reset_inputs();
        @(posedge clk);
        case(byte_sel)
            2'b11: sb.stw_mem();
            2'b10: sb.stb2h_mem();
            2'b01: sb.stb2l_mem();
            default: $display("man why did it enter default");
        endcase
        @(posedge clk);
        mem_read <= 1;
        @(posedge clk);
        for(int i = 0; i < 256; i++) begin
            addr <= i;
            @(posedge clk);
            @(posedge clk);
            sb.check_read(r_data, i, byte_sel);
            @(posedge clk);
        end
    endtask 

   

    scoreboard sb;

    initial begin 
        sb = new();
        @(posedge clk);
        test_str(2'b11);
        @(posedge clk);
        test_str(2'b10);
        @(posedge clk);
        test_str(2'b01);
        @(posedge clk);
        sb.stb2h_mem();
        @(posedge clk);
        test_ldr(2'b11);
        @(posedge clk);
        test_ldr(2'b10);
        @(posedge clk);
        test_ldr(2'b01);
        @(posedge clk);
        $finish;
        
    end
endmodule
