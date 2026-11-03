# Programming

## param json注释

```json
{
    "remote_ip": "str",
    "remote_port": "int",
    "local_ip": "str",
    "local_port": "int",
    "trans_mode": "enum, [receiver, transmitter]",
    "conn_mode": "enum, [caller, listener, rendezvous]",
    "weight": "int, 100",
    "conn_timeout_ms": "int, 3000",
    "passphrase": "str",
    "encrypt_type": "enum, [aes128, aes192, aes256]",
    "payload_size": "int, 1316",
    "latency_ms": "int, 120",
    "stream_id": "str",
    "fc": "int, 65536",
    "buf_size": "int, 25600 * payload_size",
    "group_type": "enum, [boardcast, backup]",
    "groups": [
        {
            "remote_ip": "str",
            "remote_port": "int",
            "local_ip": "str",
            "local_port": "int",
            "weight": "int, 100",
            "conn_timeout_ms": "int, 3000",
            "buf_size": "int, 25600 * payload_size"
        }
    ]
}
```