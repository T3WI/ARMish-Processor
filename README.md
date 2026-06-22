# ARMish Processor
This project explores a custom implementation of a subset of the ARMv4 instruction set. The instruction set architecture  is designed with a custom assembler to make it capable to write programs based on the instruction set. The architecture is implemented in hardware as a custom RTL model, whose functionality is verified. 

The assembler is implemented in Python, and the RTL model is implemented using SystemVerilog, using an Arty-S7 25 as a target hardware to use as an example.

This architecture is an educational project inspired by ARM-style RISC design using the ARM7TDMI-S data sheet as a reference. It is not ARM-compatible and does not use proprietary ARM encoding or IP. 
![oops](images/datapath_nonpipelined.pg)

# Instructions
1. In the assembler folder, run: ```python assembler.py file_name.s```. For example files, run ```python assembler.py .\asm_test_files\test_file.s```.
2. Move ```out.bin``` from the assembler folder to the same simulator location as ```proceesor/armish_processor/armish_processor.sim/top_sim.sv```.
3. Run simulation.

# Progress
- [x] ISA Design
- [x] Assembler
- [x] Instruction Memory
- [x] Program Counter Adder
- [x] Register FIle
- [x] Immediate Decoder
- [x] Shifter
- [x] op2dec
- [x] ALU + ALUTop
- [x] Main Control Unit
- [x] Data Memory
- [x] Branching Unit

# Known Issues
- After a LDR instruction trying to read what was loaded will not use the correct value due to the lack of stalling hardware. For now, calling addx-al r0, r0, #0 or something similar after the ldr instruction will make it work.
- Calling a branching operation will first execute the instruction in the address following the branching instruction and execute it before branching to the correct instruction. This is because this processer currently uses a 2-stage pipeline, meaning flushing wouldn't prevent data from being overwritten. The fix for this in the future is the full pipelined implementation with flushing.

# Future Work
- Pipelining with Hazard Control
- FPU
