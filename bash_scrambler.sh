#!/bin/bash

# Some variables
alg_type="none"
filename="none"
option_code=""
declare -A colors=(
  [red]="\033[31m"
  [green]="\033[32m"
  [yellow]="\033[33m"
  [blue]="\033[34m"
  [magenta]="\033[35m"
  [cyan]="\033[36m"
  [reset]="\033[0m"
)

declare -A aes_types=(
  [cbc]="-aes-256-cbc"
  [cfb]="-aes-256-cfb"
  [ofb]="-aes-256-ofb"
  [ctr]="-aes-256-ctr"
  [ecb]="-aes-256-ecb"
  [gcm]="-aes-256-gcm" 
)


# Changing color function
change_color() {
    if [[ -v colors[$1]  ]]; then
        printf "%b" "${colors[$1]}"
    else
        printf "%b" "${colors[reset]}"
    fi
}

# Print banner on start
banner() {
    change_color "red"
    printf "
┌────────────────────────────────────────────────────────┐
│                                                        │
│ ░█▀▄░█▀█░█▀▀░█░█░░░█▀▀░█▀▀░█▀▄░█▀█░█▄█░█▀▄░█░░░█▀▀░█▀▄ │
│ ░█▀▄░█▀█░▀▀█░█▀█░░░▀▀█░█░░░█▀▄░█▀█░█░█░█▀▄░█░░░█▀▀░█▀▄ │
│ ░▀▀░░▀░▀░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀░▀░▀▀░░▀▀▀░▀▀▀░▀░▀ │
│                                                        │
└────────────────────────────────────────────────────────┘
"
}

# Print menu and choose one of the option
menu() {
    change_color "magenta"
    local temp_option=""
    read -p "Do you want to encrypt or decrypt data [e/d]:" temp_option
    option_code+="$temp_option"
    read -p "Select algorithm [aes/rsa]: " temp_option
    option_code+="$temp_option"
    if [ "$temp_option" == "aes" ]; then
        read -p "Select aes type [cbc/cfb/ofb/ctr/ecb/gcm]: " temp_option
        option_code+="$temp_option"
    else
        option_code+="---"
    fi
}

# Function checking whether the given data is a folder and packs it into an archive
to_zip_convert() {}

# Main function
main () {
    clear
    banner
    menu
}

main
