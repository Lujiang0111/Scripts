#!/bin/bash
if [ $# -lt 3 ]; then
    echo -e "\033[33mUsage:\033[0m"
    echo -e "Args:\t\tsh cycle_run_stop.sh exe_file run_duration(s) stop_duration(s)"
    echo -e "Example: \tsh cycle_run_stop.sh smartd 60 60"
    exit 0
fi

exe_file=$1
run_duration=$2
stop_duration=$3

if [[ "$exe_file" != /* ]]; then
    exe_file="./${exe_file}"
fi

if [ ! -f "$exe_file" ]; then
    echo -e "file ${exe_file} not exist!"
    exit 0
fi

if [ "${run_duration}" -le 0 ]; then
    echo -e "error: run_duration <= 0"
    exit 0
fi

if [ "${stop_duration}" -le 0 ]; then
    stop_duration=0
fi

exe_file_pid=
sleep_pid=
running=true

function TrapSigint() {
    running=false
    if [[ "x" != "${sleep_pid}x" ]]; then
        kill -9 "${sleep_pid}"
    fi
}
trap TrapSigint 2

cycle_time=0
while [ "$running" = true ]; do
    ((cycle_time++))
    echo -e "\033[33mcycle ${cycle_time}, run ${exe_file}\033[0m"
    ${exe_file} &
    exe_file_pid=$!

    if [ "$running" = true ]; then
        sleep "${run_duration}" &
        sleep_pid=$!
        wait ${sleep_pid}
        sleep_pid=
    fi

    echo -e "\033[33mcycle ${cycle_time}, kill ${exe_file_pid}\033[0m"
    kill -9 ${exe_file_pid}
    exe_file_pid=

    if [ "$running" = true ]; then
        sleep "${stop_duration}" &
        sleep_pid=$!
        wait ${sleep_pid}
        sleep_pid=
    fi
done
