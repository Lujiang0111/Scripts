# Programming

## param json注释

```json
"param_json": {
    "remote_ip": "str",
    "remote_port": "int",
    "local_ip": "str, """,
    "local_port": "int, 0",
    "trans_mode": "enum, {receiver, transmitter}",
    "conn_mode": "enum, {caller, listener, rendezvous}",
    "[caller]": {},
    "[listener]": {},
    "[rendezvous]": {},
    "weight": "int, 100",
    "conn_timeout_ms": "int, 3000",
    "passphrase": "str, """,
    "encrypt_type": "enum, aes128, {aes128, aes192, aes256}",
    "payload_size": "int, 1316",
    "latency_ms": "int, 120",
    "stream_id": "str, """,
    "fc": "int, 65536",
    "buf_size": "int, 25600 * payload_size",
    "group_type": "enum, boardcast, {boardcast, backup}",
    "groups": [
        {
            "remote_ip": "str",
            "remote_port": "int",
            "local_ip": "str, """,
            "local_port": "int, 0",
            "weight": "int, 100",
            "conn_timeout_ms": "int, 3000",
            "buf_size": "int, 25600 * payload_size"
        }
    ]
}
```

+ `"键": "类型, 默认值, 额外说明"`：有默认值的情况下为可选值
+ `[]`：可选