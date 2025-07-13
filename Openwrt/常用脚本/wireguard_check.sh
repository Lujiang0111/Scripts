#!/bin/bash
wg_interface=Wireguard
ping_target=172.28.8.1

fail_cnt=0
for i in {1..3}; do
    if ! ping -c 1 -W 3 ${ping_target} >/dev/null 2>&1; then
        fail_cnt=$((fail_cnt + 1))
    fi
done

if [ ${fail_cnt} -ge 3 ]; then
    logger -t wireguard_check "wireGuard peer ping fail, reconnect"
    ifdown ${wg_interface}
    sleep 10
    ifup ${wg_interface}
fi
