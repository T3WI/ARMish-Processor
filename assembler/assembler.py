import sys 
import csv
import re


if len(sys.argv) < 2:
    print("Usage: python assembler.py <filename.s>")
    sys.exit(1)

assembly_file = sys.argv[1]

mneumonics = {
    "add": "0000",
    "sub": "0001"
}

symbols = {

}

xorf = {
    "x": "11",
    "f": "10",
    "d": "01",
    "b": "00"
}

cond = {
    "al": "0001" 
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

# right now just updates with pc and the instruction, need to remove line and output binary form of instruction
def second_pass(token, lc, line):
    return str(lc) + ":" + line 

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
                instr_bin = second_pass(token, lc, line)
                ###     


                f.write(instr_bin)
                lc = lc + 4

print('-' * 50)
print("SECOND PASS COMPLETE")
print('-' * 50)