#!/bin/bash
shell_path=$(
    cd "$(dirname "$0")" || exit
    pwd
)

# 定义变量
target_path="/path/to/target"      # 目标路径
source_path="${shell_path}/source" # 替换文件所在路径
backup_path="${shell_path}/backup" # 备份路径

help() {
    echo "使用方法: bash $0 [backup|update|rollback]"
    echo "  backup      备份源文件"
    echo "  update      备份并替换目标文件"
    echo "  rollback    回滚到备份文件"
    printf '\033[33m%s\033[0m\n' "  注意:       bash无法省略"
    exit 0
}

# 检查命令是否足够参数
if [[ $# -lt 1 ]]; then
    help
fi

# 函数：备份文件
backup_files() {
    echo "Starting backup..."

    rm -rf "${backup_path}"
    mkdir -p "${backup_path}"

    while IFS= read -r -d '' file; do
        relative_path="${file#"${source_path}"}"
        target_file="${target_path}/${relative_path}"
        backup_file="${backup_path}/${relative_path}"

        if [[ -f "${target_file}" ]]; then
            mkdir -p "$(dirname "${backup_file}")"
            cp "${target_file}" "${backup_file}"
            echo "Backed up: ${target_file} -> ${backup_file}"
        fi
    done < <(find "${source_path}" -type f -print0)

    echo "Backup completed."
}

# 函数：替换文件
replace_files() {
    echo "Starting file replacement..."

    while IFS= read -r -d '' file; do
        relative_path="${file#"${source_path}"}"
        target_file="${target_path}/${relative_path}"

        mkdir -p "$(dirname "${target_file}")"
        \cp -rf "${file}" "${target_file}"
        echo "Replaced: ${file} -> ${target_file}"
    done < <(find "${source_path}" -type f -print0)

    echo "File replacement completed."
}

# 函数：回滚文件
rollback_files() {
    echo "Starting rollback..."

    while IFS= read -r -d '' file; do
        relative_path="${file#"${backup_path}"}"
        target_file="${target_path}/${relative_path}"

        if [[ -f "${file}" ]]; then
            \cp -rf "${file}" "${target_file}"
            echo "Restored: ${file} -> ${target_file}"
        else
            echo "File not found in backup: ${file}"
        fi
    done < <(find "${backup_path}" -type f -print0)

    echo "Rollback completed."
}

case "$1" in
backup)
    backup_files
    ;;
update)
    backup_files
    replace_files
    ;;
rollback)
    rollback_files
    ;;
*)
    help
    ;;
esac
