#!/bin/bash

# Check if running with root privileges
if [ "${EUID}" -ne 0 ]; then
    echo "Please run this script with root privileges"
    exit 1
fi

# Define GRUB configuration file path
grub_file="/etc/default/grub"

# Check if the file exists
if [ ! -f "${grub_file}" ]; then
    echo "Error: ${grub_file} does not exist"
    exit 1
fi

echo -e "\n\033[33mOrigin grub file content:\n\033[0m$(cat ${grub_file})\n"

# Determine which variable to modify
if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "${grub_file}"; then
    target_var="GRUB_CMDLINE_LINUX_DEFAULT"
else
    target_var="GRUB_CMDLINE_LINUX"
fi
echo -e "Target var=${target_var}"

need_change=0

if [[ "install" == "$1" ]]; then
    isolate_cores=$2
    echo -e "\033[33mIsolate ${isolate_cores} cores\033[0m"

    # Check and handle isolcpus parameter
    if grep -q "isolcpus=" "${grub_file}"; then
        echo -e "File ${grub_file} line ${target_var} already contains isolcpus parameter"
    else
        echo -e "File ${grub_file} isolcpus not found, adding it: isolcpus=${isolate_cores}"
        if grep -q "^${target_var}=" "${grub_file}"; then
            sed -i "/^${target_var}=/ s/\"$/ isolcpus=${isolate_cores}\"/" "${grub_file}"
            need_change=1
        fi
    fi

    # Check and handle rcu_nocbs_poll parameter
    if grep -q "rcu_nocbs_poll" "${grub_file}"; then
        echo -e "File ${grub_file} line ${target_var} already contains rcu_nocbs_poll parameter"
    else
        echo -e "File ${grub_file} rcu_nocbs_poll not found, adding it: rcu_nocbs_poll"
        if grep -q "^${target_var}=" "${grub_file}"; then
            sed -i "/^${target_var}=/ s/\"$/ rcu_nocbs_poll\"/" "${grub_file}"
            need_change=1
        fi
    fi
else
    # Check and handle isolcpus parameter
    if grep -q "isolcpus=" "${grub_file}"; then
        echo -e "Remove isolcpus parameter"
        sed -i "/^${target_var}=/ {
            s/\bisolcpus=[^ \"']*//g
        }" "${grub_file}"
        need_change=1
    fi

    # Check and handle rcu_nocbs_poll parameter
    if grep -q "rcu_nocbs_poll" "${grub_file}"; then
        echo -e "Remove rcu_nocbs_poll parameter"
        sed -i "/^${target_var}=/ {
            s/\brcu_nocbs_poll\b//g
        }" "${grub_file}"
        need_change=1
    fi

    if [ "${need_change}" -eq 1 ]; then
        sed -i "/^${target_var}=/ {
            s/  */ /g
            s/\(${target_var}=\"\)\s*/\1/
            s/\s*\"$/\"/
        }" "${grub_file}"
    fi
fi

# Update GRUB configuration if changes were made
if [ "${need_change}" -eq 1 ]; then
    echo -e "\n\033[33mModified grub file content=\n\033[0m$(cat ${grub_file})\n"

    if command -v update-grub >/dev/null 2>&1; then
        echo -e "Updating grub..."
        update-grub
    elif command -v grub2-mkconfig >/dev/null 2>&1; then
        grub_cfg="/boot/grub2/grub.cfg"
        if [ -d /sys/firmware/efi ]; then
            grub_cfg=$(find /boot/efi -name "grub.cfg" 2>/dev/null | head -n 1)
        fi
        echo -e "EFI grub.cfg name=${grub_cfg}, grub2-mkconfig..."
        grub2-mkconfig -o "${grub_cfg}"
    else
        echo "Error: Could not find GRUB update command"
        exit 1
    fi
    echo -e "\033[33mPlease reboot the device to apply isolate changes\033[0m" >&2
else
    echo -e "\nGrub file no need to change!"
fi
