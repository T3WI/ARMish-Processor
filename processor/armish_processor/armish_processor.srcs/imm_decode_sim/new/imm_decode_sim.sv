`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 02:29:31 PM
// Design Name: 
// Module Name: imm_decode_sim
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


module imm_decode_sim;
    logic           clk;
    logic [7:0]     imm8;
    logic [3:0]     rot;
    logic [15:0]    imm;
    

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk; 
    end


    integer count;
    task count_instructions(output integer count);
        integer file;
        string token;
        count = 0;

        file = $fopen("out.bin", "r");


        // Read tokens one by one, ignoring whitespace/newlines
        while ($fscanf(file, "%s", token) == 1) begin
            count++;
        end

        $fclose(file);
        $display("Lines in file: %0d", count);
    endtask

    logic [31:0]    temp_mem[];
    task load_from_file();
        temp_mem = new[count];
        $readmemb("out.bin", temp_mem);
    endtask 

    logic [31:0]    imm_mem[]; 
    int file, i;
    integer num;
    task load_expected_immediates();
        file = $fopen("immediates.txt", "\r");
        i = 0;
        imm_mem = new[count];
        while(!$feof(file) && i < count) begin 
            if($fscanf(file, "%d\n", num) == 1) begin 
                imm_mem[i] = num;
                i++;
            end
        end
        $fclose(file);
    endtask

    logic [11:0] rot_and_imm8[]; 
    task extract_rot_and_imm8();
        rot_and_imm8 = new[count];
        for(int i = 0; i < count; i++) begin 
            rot_and_imm8[i] = temp_mem[i][11:0];
            @(posedge clk);
            $display("Rotation: %4b | Imm8: %8b", rot_and_imm8[i][11:8], rot_and_imm8[i][7:0]);
        end
    endtask 
    
    imm_decode id(.imm(imm), .imm8(imm8), .rot(rot));
    initial begin 
        count_instructions(count);
        @(posedge clk);
        load_from_file();
        @(posedge clk);
        load_expected_immediates();
        @(posedge clk);   
        extract_rot_and_imm8();
        @(posedge clk);
        for(int i = 0; i < count; i++) begin 
            rot = rot_and_imm8[i][11:8];
            imm8 = rot_and_imm8[i][7:0];
            @(posedge clk);
            if(imm != imm_mem[i]) begin 
                $display("[FAIL] : Expected Imm: %5d | Actual Imm: %5d", imm_mem[i], imm);
            end
            else begin 
                $display("[PASS] : Expected Imm: %5d", imm_mem[i]);
            end
        end
        $finish;
    end
endmodule
