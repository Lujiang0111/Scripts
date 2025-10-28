#!/bin/bash
shell_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)
shell_dir=$(realpath "${shell_dir}")

log_dir="${shell_dir}/disk_monitor_log"
mkdir -p "${log_dir}"

stats_file="${log_dir}/spindown_stats.txt"
debug_file="${log_dir}/spindown_debug.log"

# 修改此处硬盘列表
disks=("/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde")
declare -A last_state
declare -A standby_count
declare -A active_count

for disk in "${disks[@]}"; do
    last_state[${disk}]="unknown"
    standby_count[${disk}]=0
    active_count[${disk}]=0
done

# 添加调试函数
debug_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >>"${debug_file}"
}

# 更新统计信息的函数
update_stats() {
    local current_time="$1"
    local today
    today=$(date '+%Y-%m-%d')

    {
        echo "=== 统计信息 (${current_time}) ==="
        echo "今日日期: ${today}"
        echo "监控开始时间: $(head -n 1 "${debug_file}" 2>/dev/null | cut -d':' -f1 || echo "${current_time}")"
        echo ""
    } >"${stats_file}"

    for disk in "${disks[@]}"; do
        {
            echo "硬盘 ${disk}:"
            echo "- 进入休眠次数: ${standby_count[${disk}]}"
            echo "- 唤醒次数: ${active_count[${disk}]}"
            echo ""
        } >>"${stats_file}"
    done
}

while true; do
    current_time=$(date '+%Y-%m-%d %H:%M:%S')

    for disk in "${disks[@]}"; do
        current_state=$(hdparm -C "${disk}" 2>/dev/null | grep "drive state" | awk '{print $NF}')

        # 添加调试信息
        debug_log "硬盘: ${disk}"
        debug_log "当前状态: $current_state"
        debug_log "上次状态: ${last_state[${disk}]}"

        if [ "${last_state[${disk}]}" != "$current_state" ]; then
            debug_log "状态发生变化"
            if [ "$current_state" = "standby" ]; then
                ((standby_count[${disk}]++))
                debug_log "${disk} 进入休眠，计数: ${standby_count[${disk}]}"
            elif [ "$current_state" = "active/idle" ]; then
                ((active_count[${disk}]++))
                debug_log "${disk} 被唤醒，计数: ${active_count[${disk}]}"
            fi

            # 更新状态前记录
            debug_log "更新状态: ${last_state[${disk}]} -> $current_state"
            last_state[${disk}]=$current_state
            # 更新状态后验证
            debug_log "更新后的状态: ${last_state[${disk}]}"

            update_stats "${current_time}"
        else
            debug_log "状态未变化"
        fi

        debug_log "-------------------"
    done

    sleep 300 # 每5分钟检查一次
done
