import os
import subprocess
import sys
import time
import re


def record_top_stats(pid, interval) -> None:
    output_file = f"{pid}_top_stats.csv"
    with open(output_file, "a", encoding="utf-8") as file:
        print(f"record pid={pid} interval={interval} start!")
        if os.stat(output_file).st_size <= 0:
            file.write("Time, PID, VIRT, RES, %CPU, %MEM\n")
        try:
            while True:
                top_output = subprocess.run(
                    ["top", "-p", f"{pid}", "-b", "-n", "1"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    universal_newlines=True,
                    check=True,
                ).stdout
                processes_info = re.findall(
                    r"(\d+)\s+\S+\s+\d+\s+\d+\s+(\d+)\s+(\d+)\s+\d+\s+\S+\s+(\d+\.\d+)\s+(\d+\.\d+)\s+.*",
                    top_output,
                )

                current_time = time.strftime("%Y-%m-%d-%H:%M:%S", time.localtime())
                for pid, virt, res, cpu_percent, memory_percent in processes_info:
                    file.write(
                        f"{current_time}, {pid}, {virt}, {res}, {cpu_percent}, {memory_percent}\n"
                    )
                    file.flush()

                time.sleep(interval)
        except KeyboardInterrupt:
            print("record stop!")
            pass


if __name__ == "__main__":
    param_cnt = len(sys.argv) - 1
    if param_cnt < 1:
        raise SystemExit("param cnt={} too less".format(param_cnt))

    pid = int(sys.argv[1])
    interval = 1
    if param_cnt > 1:
        interval = int(sys.argv[2])
        if interval < 1:
            interval = 1

    record_top_stats(pid, interval)
