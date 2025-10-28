import os
import re
import sys


def extract_functions(include_dir):
    pattern = r"^[^\S\n]*\w+[\*\&]?\s+[\*\&]?\s*([a-zA-Z]\w+)\s*\("

    header_files = [
        f
        for f in os.listdir(include_dir)
        if os.path.isfile(os.path.join(include_dir, f)) and ".h" in f
    ]

    matches = []
    for header_file in header_files:
        header_file_path = os.path.join(include_dir, header_file)
        with open(header_file_path, "r", encoding="utf-8") as file:
            for line in file:
                line = line.strip()
                matches.extend(re.findall(pattern, line))

    return matches


if __name__ == "__main__":
    param_cnt = len(sys.argv) - 1
    if param_cnt < 2:
        raise SystemExit("param cnt={} too less".format(param_cnt))

    project = sys.argv[1]
    include_dir = sys.argv[2]

    def_file = open(f"{project}.def", "w")
    def_file.write(f"LIBRARY {project}\n")
    def_file.write("EXPORTS\n")

    functions = extract_functions(include_dir)
    for function_name in functions:
        def_file.write(f"{function_name}\n")

    def_file.close()
