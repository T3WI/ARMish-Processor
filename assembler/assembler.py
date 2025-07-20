import sys 
import csv

if len(sys.argv) < 2:
    print("Usage: python assembler.py <filename.s>")
    sys.exit(1)

filename = sys.argv[1]

with open(filename, 'r') as file:
    for line in file:
        print(line.strip())
