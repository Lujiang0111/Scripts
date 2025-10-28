#!/bin/bash
shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

cd "${shell_dir}" || exit
if ! command -v python3 &>/dev/null; then
    echo -e "Python3 not found, install python3..."

    # unzip python
    python3_version="Python-3.13.5"
    rm -rf ${python3_version}
    tar -zxv -f ${python3_version}.tgz &>/dev/null

    # Install python
    cd ${python3_version} || exit
    { ./configure --enable-optimizations && make clean && make -j"$(nproc)" && make install; } >/dev/null

    if ! command -v python3 &>/dev/null; then
        echo -e "Install python3 fail!"
        exit 0
    fi
    echo -e "Install python3 [ok]"
fi
