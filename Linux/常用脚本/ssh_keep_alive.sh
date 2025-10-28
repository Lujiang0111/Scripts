#!/bin/bash

sleep_duration=30
if [ $# -ge 1 ]; then
    sleep_duration=$1
fi

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
    echo -e "\033[33mcycle ${cycle_time}, keep alive\033[0m"

    if [ "$running" = true ]; then
        sleep "${sleep_duration}" &
        sleep_pid=$!
        wait ${sleep_pid}
        sleep_pid=
    fi
done
