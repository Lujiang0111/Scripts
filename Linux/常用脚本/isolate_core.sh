#!/bin/bash

# Check if running with root privileges
if [ "${EUID}" -ne 0 ]; then
    echo "Please run this script with root privileges"
    exit 1
fi

# Define GRUB configuration file path
GRUB_FILE="/etc/default/grub"

# Check if the file exists
if [ ! -f "${GRUB_FILE}" ]; then
    echo "Error: ${GRUB_FILE} does not exist"
    exit 1
fi

# Get the number of CPU cores
CPU_COUNT=$(nproc --all)

# bind last 2 cores
CPU_LAST=$((CPU_COUNT - 1))
CPU_SECOND_LAST=$((CPU_COUNT - 2))
ISOLATE_CORES="${CPU_SECOND_LAST},${CPU_LAST}"
echo -e "isolate ${ISOLATE_CORES} cores"

# Determine which variable to modify
if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "${GRUB_FILE}"; then
    TARGET_VAR="GRUB_CMDLINE_LINUX_DEFAULT"
else
    TARGET_VAR="GRUB_CMDLINE_LINUX"
fi
echo -e "target var=${TARGET_VAR}"

# Flag to track if changes were made
CHANGES_MADE=0

# Check and handle isolcpus parameter
if grep -q "isolcpus=" "${GRUB_FILE}"; then
    echo "file ${GRUB_FILE} line ${TARGET_VAR} already contains isolcpus parameter"
else
    echo "isolcpus not found, adding isolation: ${ISOLATE_CORES}"
    if grep -q "^${TARGET_VAR}=" "${GRUB_FILE}"; then
        sed -i "/^${TARGET_VAR}=/ s/\"$/ isolcpus=${ISOLATE_CORES}\"/" "${GRUB_FILE}"
        CHANGES_MADE=1
    fi
fi

# Check and handle rcu_nocbs_poll parameter
if grep -q "rcu_nocbs_poll" "${GRUB_FILE}"; then
    echo "file ${GRUB_FILE} line ${TARGET_VAR} already contains rcu_nocbs_poll parameter"
else
    echo "rcu_nocbs_poll not found, adding it"
    if grep -q "^${TARGET_VAR}=" "${GRUB_FILE}"; then
        sed -i "/^${TARGET_VAR}=/ s/\"$/ rcu_nocbs_poll\"/" "${GRUB_FILE}"
        CHANGES_MADE=1
    fi
fi

# Update GRUB configuration if changes were made
if [ "${CHANGES_MADE}" -eq 1 ]; then
    if command -v update-grub >/dev/null 2>&1; then
        update-grub
    elif command -v grub2-mkconfig >/dev/null 2>&1; then
        GRUB_CFG="/boot/grub2/grub.cfg"
        if [ -d /sys/firmware/efi ]; then
            GRUB_CFG=$(find /boot/efi -name "grub.cfg" 2>/dev/null | head -n 1)
        fi
        echo -e "grub.cfg name=${GRUB_CFG}"
        grub2-mkconfig -o "${GRUB_CFG}"
    else
        echo "Error: Could not find GRUB update command"
        exit 1
    fi
    echo -e "Successfully added parameters to ${TARGET_VAR}"
    echo -e "\033[33mPlease reboot the system to apply changes\033[0m"
fi
