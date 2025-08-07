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

def ror(val, r_bits, width):
    mask = (1 << width) - 1            # e.g., 0xFFFF for width=16
    r_bits %= width                    # in case r_bits >= width
    return ((val >> r_bits) | (val << (width - r_bits))) & mask

for test_num in range(65536):
    str_test_num = str(test_num)
    output = get_immediate_r(str_test_num)
    rot = output[0:4]
    imm8 = output[4:]
    
    int_rot = int(rot, 2)
    int_imm8 = int(imm8, 2)
    imm_test = ror(int_imm8, int_rot, 16)
    if(imm_test == test_num):
        print(f"{test_num}: PASSED")
    else:
        print(f"{test_num}: FAILED, imm_test: {imm_test}")