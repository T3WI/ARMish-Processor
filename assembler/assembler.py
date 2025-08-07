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

class Shtype(Enum):
    ROR = '00'
    ASR = '01'
    LSR = '10'
    LSL = '11'



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
            print(lc, ":", token, " len:", len(token))
            # Identify labels and store in symbol table
            if token[1] == ':':
                symbols[token[0]] = lc
                continue
            lc = lc + 4
print(symbols)
print('-' * 50)
print("FIRST PASS COMPLETE")
print('-' * 50)

def make_binary_readable(binary):
    """
        Makes a binary string more readable in the debug format of the output binary.
        0000000000000000 => 0000_0000_0000_0000
    """
    result = '_'.join(binary[i:i+4] for i in range(0, len(binary), 4))
    return result

def make_hex_readable(hex):
    """
        Makes a hex string more readable in the debug format of the output binary.
        0000000000000000 => 00_00_00_00_00_00_00_00
    """
    result = '_'.join(hex[i:i+2] for i in range(0, len(hex), 2))
    return result

def make_mc_readable(mc):
    """
        Makes the machine code more readable depending on the instruction being called.
    """
    instr_type = set_instr_type(mc[4:6])
    if instr_type == Instruction_Type.R:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10]
    elif instr_type == Instruction_Type.OP3:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10]
    elif instr_type == Instruction_Type.D:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10]
    elif instr_type == Instruction_Type.B:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10]

# right now just updates with pc and the instruction
def format_machine_code(machine_code, lc, line, output_mode=Formatter.PROD):
    if output_mode == Formatter.DEBUG:
        binary_lc = format(lc, '08b')
        hex_lc = format(lc, '02x')
        
        r_binary_lc = make_binary_readable(binary_lc)
        r_hex_lc = make_hex_readable(hex_lc)
        r_machine_code = make_mc_readable(machine_code)

        return f"{lc:>3} ({r_binary_lc}) ({r_hex_lc}):\t{r_machine_code}\t({line})\n"
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
    
def get_reg_number(reg):
    reg_as_number = int(reg[1:])
    bin_reg = format(reg_as_number, '04b')
    reg_string = f"{bin_reg}"
    return reg_string

def strip_leading_trailing_zeros(binary):
    stripped = binary.lstrip('0').rstrip('0')
    return stripped

def get_immediate_r(imm):

    # Convert to binary
    bin_imm = ''
    int_imm = 0                     # decimal value of immediate (format: int)
    if(imm[:2] == '0x'):            # Hex Input immediate
        int_imm = int(imm, 16)
    else:                           # Dec Input immediate
        int_imm = int(imm)    
    bin_imm = bin(int_imm)[2:]      # binary value of immediate (format: string)
    bin_imm = strip_leading_trailing_zeros(bin_imm)
    imm8 = bin_imm.zfill(8)
    bin_imm = bin_imm.zfill(16)        # Convert to 32b

    # find rot
    idx_rot = 0
    rot = ''
    shifted_imm = bin_imm
    
    enc_success = 0
    while idx_rot < 16:
        shifted_imm = bin_imm[-idx_rot:] + bin_imm[:-idx_rot]
        dec_imm = int(shifted_imm, 2)
        if(dec_imm == int_imm):
            rot = str(bin(idx_rot))[2:].zfill(4)
            enc_success = 1
            break
        idx_rot += 1

    if enc_success == 0:
        raise Exception("Immediate not encodable")
    op2 = rot + imm8
    return op2

# TODO: PARSE BITS 21:0
def parse_r(token):
    set_cpsr = 0
    cond_bits = ''
    I = '0'
    S = '0'
    r_n = ''
    r_d = ''
    r_m = ''
    op2 = ''
    ############################### PARSING OPCODE FIELD ###############################
    operation_bits = mneumonics[token[0]]
    ################################ PARSING COND FIELD ################################
    if token[1] == '.':
        if token[2] == 's':
            set_cpsr = 1
        # if I need more '.' flags, add more
    if token[1] == '-':
        cond_bits = cond[token[2]]


    if token[3] == '-':
        cond_bits = cond[token[4]]
    # if token[3][:1] == 'r':
    #     r_d = get_reg_number(token[3])

    ############################### PARSING OPERANDS ###################################
    token_length = len(token)
    match token_length:
        case 6:
            I = '0'
            S = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[5])
            op2 = '0'*12
        case 8:
            I = '0'
            S = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[5])
            shtype = Shtype.LSL.value
            shamt = '0'*5
            r_shift = '0'
            r_m = get_reg_number(token[7])
            op2 = shtype + shamt + r_shift + r_m
        case 9:
            I = '1'
            S = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[5])
            op2 = get_immediate_r(token[8])
            
            
        case _:
            I = 'X'
            S = 'X'
            op2 = 'X'*12
            r_d = 'XXXX'
            r_n = 'XXXX'
            # raise Exception("Invalid case")

    
    
    ############################# SITCHING MACHINE CODE ################################
    machine_code = cond_bits + operation_bits + I + S + r_n + r_d + op2
    return machine_code

# TODO: PARSE BITS 31:0
def parse_op3(token):
    set_cpsr = 0
    operation_bits = token[0]


    machine_code = operation_bits
    return machine_code

# TODO: PARSE BITS 21:0
def parse_d(token):
    ############################### PARSING OPCODE FIELD ###############################
    operation_bits = mneumonics[token[0]]
    ################################ PARSING COND FIELD ################################
    cond_bits = cond[token[2]]

    machine_code = cond_bits + operation_bits
    return machine_code

# TODO: PARSE BITS 21:0
def parse_b(token):
    ################################ PARSING OPCODE FIELD ################################
    operation_bits = mneumonics[token[0]]
    ################################ PARSING COND FIELD ################################
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
        # if len(token) == 15:
        #     print(line)
        print(machine_code)
    elif instr_type == Instruction_Type.OP3:
        machine_code =  parse_op3(token)
    elif instr_type == Instruction_Type.D:
        machine_code =  parse_d(token)
    elif instr_type == Instruction_Type.B:
        machine_code =  parse_b(token)
    else:
        raise Exception("Invalid Instruction Type")


    # CHANGE THE 4TH ARGUMENT TO CHANGE THE OUTPUT FORMAT OF THE BIN
    machine_code_f = format_machine_code(machine_code, lc, line, Formatter.DEBUG)                      # debug line
    # print(machine_code_f)
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