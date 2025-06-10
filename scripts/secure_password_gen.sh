#!/bin/bash

# ---------------------------------------------------
# Simple Password Generator (SPG)
# Author: SaiSampathC
# ---------------------------------------------------

# ANSI colors for style
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Welcome banner
echo -e "${CYAN}=========================================="
echo -e "   Simple Password Generator (SPG) v1.1"
echo -e "   Author: SaiSampathC"
echo -e "==========================================${RESET}"
sleep 1 #just a chill UX pause

# Get desired password length from user
get_password_length() {
    while true; do
        read -rp "$(echo -e "${YELLOW}Enter password length (6-128): ${RESET}")" PASS_LENGTH
        if [[ "$PASS_LENGTH" =~ ^[0-9]+$ ]] && (( PASS_LENGTH >= 6 && PASS_LENGTH <= 128 )); then
            break
        else
            echo -e "${RED}Invalid input. Enter a number between 6 and 128.${RESET}"
        fi
    done
}

# Get number of passwords to generate
get_password_count() {
    while true; do
        read -rp "$(echo -e "${YELLOW}How many passwords to generate? (1-100): ${RESET}")" PASS_COUNT
        if [[ "$PASS_COUNT" =~ ^[0-9]+$ ]] && (( PASS_COUNT >= 1 && PASS_COUNT <= 100 )); then
            break
        else
            echo -e "${RED}Invalid input. Enter a number between 1 and 100.${RESET}"
        fi
    done
}

# Generate passwords
generate_passwords() {
    echo -e "\n${GREEN}Generating $PASS_COUNT password(s) of length $PASS_LENGTH...${RESET}"
    PASSWORDS=()
    for ((i = 1; i <= PASS_COUNT; i++)); do
        PASSWORD=$(openssl rand -base64 $((PASS_LENGTH * 2)) | tr -dc 'A-Za-z0-9' | head -c "$PASS_LENGTH")
        PASSWORDS+=("$PASSWORD")
        echo -e "${CYAN}Password $i:${RESET} $PASSWORD"
    done
    echo -e "\n${GREEN}Done generating passwords.${RESET}"
}

# Optionally save passwords to a file
save_passwords() {
    read -rp "$(echo -e "${YELLOW}Save passwords to a file? (y/n): ${RESET}")" SAVE
    if [[ "$SAVE" =~ ^[Yy]$ ]]; then
        FILE="passwords_$(date +%Y%m%d_%H%M%S).txt"
        for ((i = 1; i <= PASS_COUNT; i++)); do
            echo "Password $i: ${PASSWORDS[i-1]}" >> "$FILE"
        done
        echo -e "${GREEN}Passwords saved to $FILE${RESET}"
    fi
}

# Run it
get_password_length
get_password_count
generate_passwords
save_passwords

# Goodbye
echo -e "\n${CYAN}Thanks for using SPG. Stay safe out there!"
echo -e "- SaiSampathC${RESET}\n"

