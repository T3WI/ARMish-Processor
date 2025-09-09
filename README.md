# ARMish Processor
This project seeks to explore a subset of the ARM instruction set, and create an ARM-inspired processor. The goal is to design a custom instruction set inspired by the ARM architecture, create an assembler for the instruction set, implement the architecture in hardware with an RTL model, and verify the correctness of the processor. This architecture is an educational project inspired by ARM-style RISC design using the ARM7TDMI-S data sheet as a reference. It is not ARM-compatible and does not use proprietary ARM encoding or IP. 

The assembler was implemented in Python, and the RTL model with verification testbenches were implemented using SystemVerilog.

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
- [ ] Control Unit
- [ ] Memory Access Module
- [ ] Data Memory
- [ ] Branching Unit
- [ ] Pipelining and Hazard Control
- [ ] FPU
- [ ] Other Features

# Verification

# Performance
