from dpp_jump_compiler import compile
from os import sys

if len(sys.argv) < 3:
    print("Usage: {} <input_file_name> <output_file_name>".format(sys.argv[0]))
    exit(-1)
    
with open(sys.argv[1], 'r') as f:
    output_file_name = sys.argv[2]
    file_extensions_to_remove = ['.h', '.cpp', '.hpp']

    # remove the file extension
    for file_extension in file_extensions_to_remove:
        if output_file_name.endswith(file_extension):
            output_file_name = output_file_name.split[0:len(output_file_name) - len(file_extension)]
    
    compile(sys.argv[1], output_file_name)