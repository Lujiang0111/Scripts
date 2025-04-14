#!/bin/bash

urls=(
    "https://192.168.0.100/file1.txt"
    "https://192.168.0.100/file2.pdf"
    "https://192.168.0.100/file3.jpg"
)

for url in "${urls[@]}"; do
    curl -sL -m 60 "${url}" -o /dev/null
    sleep 1
done
