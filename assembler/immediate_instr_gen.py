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

    # if(len(imm8) != 8):
    #     raise Exception("Immediate not encodable")

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
    # if(len(op2) != 12):
    #     print(f"Immediate Inputted: {imm}\n op2 Encoded: {op2}\n rot: {rot}\n imm8: {imm8}")
    #     raise Exception("Immediate encoding error!")
    return op2

num_lines = 32768  # change this to however many lines you want
output_file = "test_immediates.s"
imm_file = "immediates.txt"
with open(output_file, "w") as f:
    with open(imm_file, "w") as imm_f:
        for i in range(0, num_lines):
            op2 = get_immediate(str(i))
            if len(op2) != 12:
                continue 
            f.write(f"addx-al r1, r0, #{i}\n")
            imm_f.write(f"{i}\n")