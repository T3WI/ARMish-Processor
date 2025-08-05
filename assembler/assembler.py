import sys 
import csv
import re
from enum import Enum

class Formatter(Enum):
    PROD = 0
    DEBUG = 1

class Instruction_Type(Enum):
    R = 0
    OP3 = 1
    D = 2
    B = 3

if len(sys.argv) < 2:
    print("Usage: python assembler.py <filename.s>")
    sys.exit(1)

assembly_file = sys.argv[1]

mneumonics = {
    "addx": "110000",
    "subx": "110001",
    "mulx": "110010",
    "divx": "110011",
    "notx": "110100",
    "andx": "110101",
    "orrx": "110110",
    "convx": "110111",
    "addf": "111000",
    "subf": "111001",
    "mulf": "111010",
    "divf": "111011",
    "cmpf": "111100",
    "cnvf": "111101",
    "sqrf": "111110",
    "recf": "111111",

    "vmac": "100000",
    "vadd": "100001",
    "vsub": "100010",
    "vsel": "100011",

    "ldw": "010000",
    "ldb2l": "010001",
    "ldb2h": "010010",
    "stw": "010011",
    "stb2l": "010100",
    "stb2h": "010101",

    "bx": "001000",
    "b": "000000",
    "bl": "000100"

    




}

symbols = {

}

cond = {
    "al": "0001",
    "le": "0010",
    "gt": "0011",
    "lt": "0100",
    "ge": "0101",
    "ls": "0110",
    "hi": "0111",
    "vc": "1000",
    "vs": "1001",
    "pl": "1010",
    "mi": "1011",
    "cc": "1100",
    "cs": "1101",
    "neq": "1110",
    "eq": "1111",
}

# instead add "s" at the end on whether or not to alter code and parse the pnemonic. e.g. When getting to the mneumonic, look through the pneumonic until an "s" is reached
# alter_code = {
#     "s": "1",
#     "n": "0"
# }

### FIRST PASS
print('-' * 50)
print("FIRST PASS")
print('-' * 50)
lc = 0
with open(assembly_file, 'r') as file:
    for line in file:
        # empty line
        if line.strip() == "":
            continue 
        else: 
            # Split by commas and whitespace
            token = re.findall(r'\w+|[^\s\w]', line)
            print(lc, ":", token)
            # Identify labels and store in symbol table
            if token[1] == ':':
                symbols[token[0]] = lc
                continue
            lc = lc + 4
print(symbols)
print('-' * 50)
print("FIRST PASS COMPLETE")
print('-' * 50)

# right now just updates with pc and the instruction
def format_machine_code(machine_code, lc, line, output_mode=Formatter.PROD):
    if output_mode == Formatter.DEBUG:
        binary_lc = format(lc, '08b')
        hex_lc = format(lc, '08x')
        return f"{lc:>3} ({binary_lc}) ({hex_lc}):\t{machine_code}\t({line})\n"
    else:
        binary_lc = format(lc, '08b')
        return f"{binary_lc} :\t{machine_code}\n"
    
def set_instr_type(mneumonic_code):
    if mneumonic_code[:2] == "11":
        return Instruction_Type.R
    elif mneumonic_code[:2] == "10":
        return Instruction_Type.OP3
    elif mneumonic_code[:2] == "01":
        return Instruction_Type.D 
    elif mneumonic_code[:2] == "00":
        return Instruction_Type.B 
    else:
        raise Exception("Invalid Type")
    
# TODO: PARSE BITS 21:0
def parse_r(token):
    set_cpsr = 0
    cond_bits = ""
    r_d = ""
    operation_bits = mneumonics[token[0]]


    if token[1] == '.':
        if token[2] == 's':
            set_cpsr = 1
        # if I need more . flags, add more
    if token[1] == '-':
        cond_bits = cond[token[2]]


    if token[3] == '-':
        cond_bits = cond[token[4]]
    if token[3][:1] == 'r':
        r_d = token[3][:-1]

    
    machine_code = cond_bits + operation_bits
    return machine_code

# TODO: PARSE BITS 21:0
def parse_op3(token):
    set_cpsr = 0
    operation_bits = token[0]


    machine_code = operation_bits
    return machine_code

# TODO: PARSE BITS 31:0
def parse_d(token):
    operation_bits = mneumonics[token[0]]
    cond_bits = cond[token[2]]

    machine_code = cond_bits + operation_bits
    return machine_code

# TODO: PARSE BITS 31:0
def parse_b(token):
    operation_bits = mneumonics[token[0]]
    cond_bits = cond[token[2]]

    machine_code = cond_bits + operation_bits
    return machine_code


def second_pass(token, lc, line):
    dot_flag = 0
    dash_flag = 0
    set_cpsr_true = 0
    cond_field = ""
    instr_type = ""
    r_n = ""
    r_d = ""

    mneumonic_code = mneumonics[token[0]]
    instr_type = set_instr_type(mneumonic_code)
    if instr_type == Instruction_Type.R:
        machine_code = parse_r(token)
    elif instr_type == Instruction_Type.OP3:
        machine_code =  parse_op3(token)
    elif instr_type == Instruction_Type.D:
        machine_code =  parse_d(token)
    elif instr_type == Instruction_Type.B:
        machine_code =  parse_b(token)


    # CHANGE THE 4TH ARGUMENT TO CHANGE THE OUTPUT FORMAT OF THE BIN
    machine_code_f = format_machine_code(machine_code, lc, line, Formatter.DEBUG)                      # debug line
    return machine_code_f

### SECOND PASS
print('-' * 50)
print("SECOND PASS")
print('-' * 50)
lc = 0
with open("out.bin", "w") as f:
    with open(assembly_file, 'r') as file:
        for line in file:
            # empty line
            if line.strip() == "":
                continue 
            else: 
                # Split by commas and whitespace
                token = re.findall(r'\w+|[^\s\w]', line)
                if token[1] == ':':                         # label case
                    continue
            

                ###
                # TODO: SECOND PASS
                instr_bin = second_pass(token, lc, line.strip())
                ###     


                f.write(instr_bin)
                lc = lc + 4

print('-' * 50)
print("SECOND PASS COMPLETE")
print('-' * 50)