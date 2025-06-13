#!/bin/bash
shell_path=$(
    cd "$(dirname "$0")" || exit
    pwd
)
svn revert -R "${shell_path}"
svn update "${shell_path}"
