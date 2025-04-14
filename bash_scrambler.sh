#!/bin/bash

# Some variables
file="none"
option_code=""
password=""

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

# Print menu and generate option code
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
    while true; do
        read -p "Enter filename or file path: " file
        if [[ -f "$file" || -d "$file" ]]; then
            break
        else
            printf "[!] File doesnt exist!\n"
        fi
    done
}

# Function checking whether the given data is a folder and packs it into an archive
tar_untar() {
    if [ "$1" == "1" ]; then
        tar -C "$(dirname "decrypted.tar")" -xf "decrypted.tar"
        rm "decrypted.tar"
    else
        tar -C "$(dirname "$file")" -cf "$file.tar" "$(basename "$file")"
        file="$file.tar"
    fi
}

process_aes() {
    read -s -p "Enter password: " password
    local option=${option_code:4:3}
    if [[ "${option_code:0:1}" == "e" ]]; then
        tar_untar "0"
        openssl enc "${aes_types[$option]}" -pbkdf2 -iter 1000 -salt -in "$file" -out "$file.enc" -pass pass:"$password"
        rm "$file"
        change_color "green"
        printf "[+] File encrypted"
    else
        openssl enc -d "${aes_types[$option]}" -pbkdf2 -iter 1000 -salt -in "$file" -out "decrypted.tar" -pass pass:"$password" 
        tar_untar "1"
        change_color "green"
        printf "[+] File decrypted"
    fi
}

# Main function
main () {
    clear
    banner
    menu
    process_aes
    echo "\n\n"
}

main

