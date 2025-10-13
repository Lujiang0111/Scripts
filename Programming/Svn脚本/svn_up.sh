#!/bin/bash
shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

svn revert -R "${shell_dir}"
svn update "${shell_dir}"
