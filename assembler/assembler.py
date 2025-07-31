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

lc = 0
with open(assembly_file, 'r') as file:
    for line in file:
        # empty line
        if line.strip() == "":
            continue 
        else: 
            # Split by commas and whitespace
            tokens = re.findall(r'\w+|[^\s\w]', line)
            print("Tokens:", tokens)
