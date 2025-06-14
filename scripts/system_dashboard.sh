#!/bin/bash

# --------------------------
# SYSTEM HEALTH DASHBOARD
# Author: SaiSampathC
# --------------------------

GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

clear
echo -e "${CYAN}========== 🖥️ SYSTEM HEALTH DASHBOARD ==========${RESET}"

echo -e "${YELLOW}Hostname        :${RESET} $(hostname)"
echo -e "${YELLOW}Uptime          :${RESET} $(uptime -p)"
echo -e "${YELLOW}CPU Load        :${RESET} $(top -bn1 | grep "load average" | awk '{print $(NF-2), $(NF-1), $NF}')"
echo -e "${YELLOW}Memory Usage    :${RESET} $(free -h | awk '/^Mem/ {print $3 " / " $2}')"
echo -e "${YELLOW}Disk Usage      :${RESET} $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
echo -e "${YELLOW}IP Address      :${RESET} $(hostname -I | awk '{print $1}')"
echo -e "${YELLOW}Internet Status :${RESET} $(ping -c1 google.com &> /dev/null && echo -e "${GREEN}✅ Connected${RESET}" || echo -e "${RED}❌ Disconnected${RESET}")"

if command -v acpi &> /dev/null; then
    echo -e "${YELLOW}Battery Status  :${RESET} $(acpi -b | cut -d: -f2-)"
else
    echo -e "${YELLOW}Battery Status  :${RESET} acpi not installed"
fi

echo -e "${CYAN}===============================================${RESET}"
