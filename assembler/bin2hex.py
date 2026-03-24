def binary_to_hex(input_file, output_file):
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            for line_num, line in enumerate(infile, 1):
                # Clean up whitespace/newlines
                binary_str = line.strip()
                
                if not binary_str:
                    continue  # Skip empty lines
                
                try:
                    # Convert base 2 string to integer
                    value = int(binary_str, 2)
                    
                    # Format as 8-character hex (32-bit) with leading zeros
                    # '08x' means: 0-padded, 8 chars wide, lowercase hex
                    hex_val = f"{value:08x}"
                    
                    outfile.write(hex_val + '\n')
                except ValueError:
                    print(f"Warning: Skipping invalid binary data on line {line_num}: {binary_str}")
                    
        print(f"Success! Conversion complete. Output saved to: {output_file}")

    except FileNotFoundError:
        print("Error: The input file was not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Usage
binary_to_hex('out.bin', 'out.hex')