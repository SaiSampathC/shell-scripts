#!/bin/bash

# === Terminal Colors ===
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
MAGENTA='\033[1;95m'
CYAN='\033[1;96m'
RESET='\033[0m'

# === Thresholds ===
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90

# === Config ===
ALERT_EMAIL="admin@example.com"  # Set your email here
SLACK_WEBHOOK_URL=""             # Optional Slack webhook
LOG_FILE="/tmp/server_health.log"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# === Header ===
print_header() {
    echo -e "${CYAN}========================================="
    echo -e "${MAGENTA}      SERVER HEALTH CHECK DASHBOARD      "
    echo -e "${CYAN}=========================================${RESET}"
    echo ""
}

log() {
    echo "$timestamp - $1" >> "$LOG_FILE"
}

send_alert() {
    local message="$1"

    # Send email
    echo "$message" | mail -s "Server Health Alert" "$ALERT_EMAIL"

    # Send to Slack if configured
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL" > /dev/null 2>&1
    fi
}

draw_status() {
    local label="$1"
    local value="$2"
    local threshold="$3"
    local unit="$4"

    if (( value > threshold )); then
        echo -e "${RED}[FAIL] $label: ${value}${unit} (threshold: ${threshold}${unit})${RESET}"
        log "$label above threshold: ${value}${unit}"
        send_alert "$label alert: ${value}${unit} > ${threshold}${unit}"
    else
        echo -e "${GREEN}[OK]   $label: ${value}${unit}${RESET}"
        log "$label within normal range: ${value}${unit}"
    fi
}

check_cpu() {
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    usage_int=${usage%.*}
    draw_status "CPU Usage" "$usage_int" "$CPU_THRESHOLD" "%"
}

check_memory() {
    usage=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
    draw_status "Memory Usage" "$usage" "$MEM_THRESHOLD" "%"
}

check_disk() {
    echo -e "${YELLOW}-- Disk Usage --${RESET}"
    df -h --output=source,pcent,target | tail -n +2 | while read -r line; do
        usage=$(echo "$line" | awk '{print $2}' | sed 's/%//')
        mount_point=$(echo "$line" | awk '{print $3}')
        if (( usage > DISK_THRESHOLD )); then
            echo -e "${RED}[FAIL] Disk on ${mount_point}: ${usage}%${RESET}"
            log "Disk usage high on ${mount_point}: ${usage}%"
            send_alert "Disk usage alert: ${mount_point} is at ${usage}%"
        else
            echo -e "${GREEN}[OK]   Disk on ${mount_point}: ${usage}%${RESET}"
            log "Disk usage normal on ${mount_point}: ${usage}%"
        fi
    done
}

check_services() {
    echo -e "${YELLOW}-- Critical Services --${RESET}"
    for service in nginx docker; do
        if ! systemctl is-active --quiet "$service"; then
            echo -e "${RED}[FAIL] $service is not running${RESET}"
            log "$service is DOWN"
            send_alert "Service alert: $service is DOWN"
        else
            echo -e "${GREEN}[OK]   $service is running${RESET}"
            log "$service is running"
        fi
    done
}

# === Run ===
clear
print_header
check_cpu
check_memory
check_disk
check_services
echo -e "\n${CYAN}Log written to ${LOG_FILE}${RESET}\n"

