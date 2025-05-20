import os
import re
import sys


def extract_functions(file_path):
    pattern = r"^[^\S\n]*\w+[\*\&]?\s+[\*\&]?\s*([a-zA-Z]\w+)\s*\("

    header_files = [
        f
        for f in os.listdir(file_path)
        if os.path.isfile(os.path.join(file_path, f)) and ".h" in f
    ]

    matches = []
    for header_file in header_files:
        header_file_path = os.path.join(file_path, header_file)
        with open(header_file_path, "r", errors="ignore") as file:
            for line in file:
                line = line.strip()
                matches.extend(re.findall(pattern, line))

    return matches

if __name__ == "__main__":
    param_cnt = len(sys.argv) - 1
    if param_cnt < 2:
        raise SystemExit("param cnt={} too less".format(param_cnt))
    
    project=sys.argv[1]
    include_path = sys.argv[2]

    def_file = open(f"{project}.def", "w")
    def_file.write(f"LIBRARY {project}\n")
    def_file.write("EXPORTS\n")

    functions = extract_functions(include_path)
    for function_name in functions:
        def_file.write(f"{function_name}\n")

    def_file.close()
