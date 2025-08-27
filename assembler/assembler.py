import sys 
import csv
import re
from enum import Enum

INSTRUCTION_SIZE = 4            # instruction size in bytes
PIPELINE_CORRECTION = 4

class Formatter(Enum):
    PROD = 0
    DEBUG = 1

class Instruction_Type(Enum):
    RX = 0
    RF = 1
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
    "absx": "110100",
    "adcx": "110101",
    "sbcx": "110110",
    "cmpx": "110111",
    "notx": "111000",
    "andx": "111001",
    "orrx": "111010",
    "xorx": "111011",


    "ldw": "010000",
    "ldb2l": "010001",
    "ldb2h": "010010",
    "stw": "010011",
    "stb2l": "010100",
    "stb2h": "010101",

    "bx": "0010",
    "b": "0000",
    "bl": "0001"

    




}

symbols = {

}

cond = {
    "halt":"0000",
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

def make_binary_readable(binary: str):
    """
        Makes a binary string more readable in the debug format of the output binary.
        0000000000000000 => 0000_0000_0000_0000
    """
    result = '_'.join(binary[i:i+4] for i in range(0, len(binary), 4))
    return result

def make_hex_readable(hex: str):
    """
        Makes a hex string more readable in the debug format of the output binary.
        0000000000000000 => 00_00_00_00_00_00_00_00
    """
    result = '_'.join(hex[i:i+2] for i in range(0, len(hex), 2))
    return result

def make_mc_readable(mc : str):
    """
        Makes the machine code more readable depending on the instruction being called.
    """
    instr_type = set_instr_type(mc[4:6])
    if instr_type == Instruction_Type.RX:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10] + "_" + mc[10:12] + "_" + mc[12:16] + "_" + mc[16:20] + "_" +  mc[20:33]
    elif instr_type == Instruction_Type.RF:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10] 
    elif instr_type == Instruction_Type.D:
        return mc[0:4] + "_" + mc[4:6] + "_" + mc[6:10] + "_" + mc[10:12] + "_" + mc[12:16] + "_" + mc[16:20] + "_" +  mc[20:33]
    elif instr_type == Instruction_Type.B:
        return mc[0:4] + "_" + mc[4:8] + "_" + mc[8:33]

# right now just updates with pc and the instruction
def format_machine_code(machine_code: str, lc, line: str, output_mode=Formatter.PROD):
    """
        Formats the out.bin depending on whether or not the debug format or the production format is desired. The debug format makes the hex and bin values in out.bin more readable
    """
    if output_mode == Formatter.DEBUG:
        binary_lc = format(lc, '016b')
        hex_lc = format(lc, '04x')
        
        r_binary_lc = make_binary_readable(binary_lc)
        r_hex_lc = make_hex_readable(hex_lc)
        r_machine_code = make_mc_readable(machine_code)

        return f"{lc:>4} ({r_binary_lc}) ({r_hex_lc}):\t{r_machine_code}\t({line})\n"
    else:
        binary_lc = format(lc, '016b')
        return f"{machine_code}\n"
    
def set_instr_type(mneumonic_code: str):
    """
        Given 10 the first 10 bits parsed from the instruction, determines the instruction type
    """
    if mneumonic_code[:2] == "11":
        return Instruction_Type.RX
    elif mneumonic_code[:2] == "10":
        return Instruction_Type.RF
    elif mneumonic_code[:2] == "01":
        return Instruction_Type.D 
    elif mneumonic_code[:2] == "00":
        return Instruction_Type.B 
    else:
        raise Exception("Invalid Type")
    
def get_reg_number(reg: str):
    """
        Given a string that represents a register (e.g. r1, r2, r3), output the number of the register in binary. If it is the name of a special register (lr, pc), output the input reg
    """
    reg_string = ''
    if reg == "lr":
        reg_as_number = 14
    elif reg == "pc":
        reg_as_number = 15
    else:
        reg_as_number = int(reg[1:])
    bin_reg = format(reg_as_number, '04b')
    reg_string = f"{bin_reg}"
    return reg_string

def strip_leading_trailing_zeros(binary: str):
    """
        Removes leading zeros and trailing zeros from a binary number. used for calculating immediates
    """
    stripped = binary.lstrip('0').rstrip('0')
    return stripped

def get_immediate(imm: str):
    """
        Calculates immediates for instructions that use immediates. 
    """
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

    if(len(imm8) != 8):
        raise Exception("Immediate not encodable")

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
    if(len(op2) != 12):
        print(f"Immediate Inputted: {imm}\n op2 Encoded: {op2}\n rot: {rot}\n imm8: {imm8}")
        raise Exception("Immediate encoding error!")
    return op2

def convert_string_shtype_to_enum(str_shtype: str) -> Shtype:
    str_shtype.lower()
    match str_shtype:
        case 'ror':
            return Shtype.ROR 
        case 'asr':
            return Shtype.ASR 
        case 'lsr':
            return Shtype.LSR 
        case 'lsl':
            return Shtype.LSL
        
def num_string_to_binary_string(num_str: str) -> str:
    return bin(int(str))[2:]

# TODO: PARSE BITS 21:0
def parse_rx(token):
    """
        Parses an R-type instruction that has been tokenized into different components, and outputs the machine code representation of the instruction
    """
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
    if token[1] == '-':
        cond_bits = cond[token[2]]
    elif token[3] == '-':
        cond_bits = cond[token[4]]
    else:
        raise Exception("No valid condition flags")


    ############################### PARSING OPERANDS ###################################
    token_length = len(token)
    match token_length:
        case 6:
            I = '0'
            S = '0'
            if(token[0] == 'cmpx'):
                S = '1'
                r_d = get_reg_number('r0')
                r_n = get_reg_number(token[3])
                r_m = get_reg_number(token[5])
                op2 = ('0'*8) + r_m
            else:
                r_d = get_reg_number(token[3]) 
                r_n = get_reg_number(token[5])
                op2 = '0'*12
        case 7:
            I = '1'
            S = '1'
            r_d = get_reg_number('r0')
            r_n = get_reg_number(token[3])
            op2 = get_immediate(token[6])
        case 8:
            I = '0'
            S = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[5])
            shtype = Shtype.ROR.value
            shamt = '0'*5
            r_shift = '0'
            r_m = get_reg_number(token[7])
            op2 = shtype + shamt + r_shift + r_m
        case 9:
            I = '1'
            S = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[5])
            op2 = get_immediate(token[8])
        case 10:
            I = '0'
            S = '1'
            r_d = get_reg_number(token[5])
            r_n = get_reg_number(token[7])
            r_m = get_reg_number(token[9])
            shtype = Shtype.ROR.value 
            shamt = '0'*5
            r_shift = '0'
            op2 = shtype + shamt + r_shift + r_m 
        case 11:
            I = '0'
            S = '0'
            if token[1] == '.':
                if token[2] == 's':
                    S = '1'
                    r_d = get_reg_number(token[5])
                    r_n = get_reg_number(token[7])
                    op2 = get_immediate(token[10])
            else:
                r_d = get_reg_number(token[3])
                r_n = get_reg_number(token[5])
                r_m = get_reg_number(token[7])
                
                shtype = convert_string_shtype_to_enum(token[9]).value
                r_s = get_reg_number(token[10])
                r_shift = '1'
                op2 = shtype + r_s + '0' + r_shift + r_m
        case 12:
            I = '0'
            S = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[5])
            shtype = convert_string_shtype_to_enum(token[9]).value
            shamt = format(int(token[11]), "05b")
            r_shift = '0'                  
            r_m = get_reg_number(token[7])
            op2 = shtype + shamt + r_shift + r_m
        case 13:
            I = '0'
            S = '1'
            r_d = get_reg_number(token[5])
            r_n = get_reg_number(token[7])
            shtype = convert_string_shtype_to_enum(token[11]).value 
            r_s = get_reg_number(token[12])
            r_shift = '1'
            r_m = get_reg_number(token[9])
            op2 = shtype + r_s + '0' + r_shift + r_m
        case 14:
            I = '0'
            S = '1'
            r_d = get_reg_number(token[5])
            r_n = get_reg_number(token[7])
            shtype = convert_string_shtype_to_enum(token[11]).value
            shamt = format(int(token[13]), "05b")
            r_shift = '0'
            r_m = get_reg_number(token[9])
            op2 = shtype + shamt + r_shift + r_m
        case _:
            raise Exception("Invalid instruction. Check for syntax errors.")

    
    
    ############################# SITCHING MACHINE CODE ################################
    machine_code = cond_bits + operation_bits + I + S + r_n + r_d + op2
    return machine_code

# TODO: PARSE BITS 31:0
def parse_rf(token):
    """
        Parses an RF-type instruction that has been tokenized into different components, and outputs the machine code representation of the instruction
    """
    operation_bits = token[0]


    machine_code = operation_bits
    return machine_code

# TODO: PARSE BITS 21:0
def parse_d(token):
    """
        Parses a D-type instruction that has been tokenized into different components, and outputs the machine code representation of the instruction
    """
    cond_bits = ''
    U = ''
    I = ''
    S = ''
    r_n = ''
    r_d = ''
    r_m = ''
    offset = ''
    ############################### PARSING OPCODE FIELD ###############################
    operation_bits = mneumonics[token[0]]
    ################################ PARSING COND FIELD ################################
    if token[1] == '-':
        cond_bits = cond[token[2]]
    elif token[3] == '-':
        cond_bits = cond[token[4]]
    else:
        raise Exception("No valid condition flags")
    
    token_length = len(token)
    match token_length:
        case 10:
            U = '1'
            I = '0'
            r_n = get_reg_number(token[6])
            r_d = get_reg_number(token[3])
            shtype = Shtype.ROR.value
            shamt = '0'*5
            r_shift = '0'
            r_m = get_reg_number(token[8])
            offset = shtype + shamt + r_shift + r_m
        case 11:
            if token[8] == '-':
                U = '0'
                I = '0'
                shtype = Shtype.ROR.value 
                shamt = '0'*5
                r_shift = '0'
                r_m = get_reg_number(token[9])
                offset = shtype + shamt + r_shift + r_m
            elif token[8] == '#':
                U = '1'
                I = '1'
                offset = get_immediate(token[9])
            else:
                raise Exception("Innvalid offset. Check for syntax errors.")
            r_n = get_reg_number(token[6])
            r_d = get_reg_number(token[3])
        case 12:
            U = '0'
            I = '1'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[6])
            offset = get_immediate(token[10])
        case 13:
            U = '1'
            I = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[6])
            shtype = convert_string_shtype_to_enum(token[10]).value 
            r_s = get_reg_number(token[11])
            r_shift = '1'
            r_m = get_reg_number(token[8])
            offset = shtype + r_s + '0' + r_shift + r_m
        case 14:
            U = '1'
            I = '0'
            r_d = get_reg_number(token[3])
            r_n = get_reg_number(token[6])
            shtype = convert_string_shtype_to_enum(token[10]).value
            shamt = format(int(token[12]), "05b")
            r_shift = '0'
            r_m = get_reg_number(token[8])
            offset = shtype + shamt + r_shift + r_m
        case _:
            raise Exception("Invalid instruction. Check for syntax errors.")

    machine_code = cond_bits + operation_bits + I + U + r_n + r_d + offset
    return machine_code

def conv_to_2s(value, bits):
    if value < 0:
        value = (1 << bits) + value
    return format(value, f'0{bits}b')

def find_branching_offset(label_address : int, lc : int):
    offset_int = (label_address - (lc + PIPELINE_CORRECTION)) // INSTRUCTION_SIZE
    offset = conv_to_2s(offset_int, 24)
    return offset

def parse_b(token, lc):
    """
        Parses an B-type instruction that has been tokenized into different components, and outputs the machine code representation of the instruction
    """
    cond_bits = ''
    r_b = ''
    R = ''
    L = ''
    offset = ''
    ############################### PARSING OPCODE FIELD ###############################
    operation_bits = mneumonics[token[0]]
    ################################ PARSING COND FIELD ################################
    if token[1] == '-':
        cond_bits = cond[token[2]]
    elif token[3] == '-':
        cond_bits = cond[token[4]]
    else:
        raise Exception("No valid condition flags")
    
    match token[0]:
        case 'bx':
            R = '1'
            L = '0'
            r_b = get_reg_number(token[3])
            offset = '0'*20 + r_b
        case 'b':
            R = '0'
            L = '0'
            label_address = symbols[token[3]]
            offset = find_branching_offset(label_address, lc)
            
            

        case "bl":
            R = '0'
            L = '1'
            label_address = symbols[token[3]]
            offset = find_branching_offset(label_address, lc)
        case _:
            R = 'X'
            L = 'X'
            offset = 'X'*24

    machine_code = cond_bits + operation_bits + offset
    return machine_code

def check_mc_validity(token, line, mc: str):
    if len(mc) != 32:
        print(f"Line: {line}\n Tokenized: {token}\n Token Length: {len(token)}\n Machine Code: {mc}\n Length: {len(mc)}")
        raise Exception("Incorrect machine code length!")
    
def second_pass(token, lc, line):
    """
        Executes the second pass of the assembler. Each instruction line of the program is parsed and replaced with the instruction binary representation.
    """
    dot_flag = 0
    dash_flag = 0
    set_cpsr_true = 0
    cond_field = ""
    instr_type = ""
    r_n = ""
    r_d = ""
    
    mneumonic_code = mneumonics[token[0]]
    instr_type = set_instr_type(mneumonic_code)
    if instr_type == Instruction_Type.RX:
        machine_code = parse_rx(token)
        check_mc_validity(token, line, machine_code)
        # if len(token) == 10:
        #     print(line)
        # print(f"{machine_code:<32} : {line:<40} : len: {len(token)}")
    elif instr_type == Instruction_Type.RF:
        machine_code =  parse_rf(token)
        # check_mc_validity(machine_code)
        # if len(token) == 10:
        #     print(line)
        # print(f"{machine_code:<32} : {line:<40} : len: {len(token)}")
    elif instr_type == Instruction_Type.D:
        machine_code =  parse_d(token)
        check_mc_validity(machine_code)
        # if len(token) == 15:
        #     print(line)
        # print(f"{machine_code:<32} : {line:<40} : len: {len(token)}")
    elif instr_type == Instruction_Type.B:
        machine_code =  parse_b(token, lc)
        # check_mc_validity(machine_code)
        # if len(token) == 15:
        #     print(line)
        # print(f"{machine_code:<32} : {line:<40} : len: {len(token)}")
    else:
        raise Exception("Invalid Instruction Type")


    # CHANGE THE 4TH ARGUMENT TO CHANGE THE OUTPUT FORMAT OF THE BIN
    machine_code_f = format_machine_code(machine_code, lc, line, Formatter.PROD)                      # debug line
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
                instr_bin = second_pass(token, lc, line.strip())
                ###     


                f.write(instr_bin)
                lc = lc + 4

print('-' * 50)
print("SECOND PASS COMPLETE")
print('-' * 50)