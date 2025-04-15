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
    change_color "blue"
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

    # Ask if the user wants to encrypt or decrypt the data
    while true; do
        read -p "Do you want to encrypt or decrypt data [e/d]: " temp_option
        if [[ "$temp_option" == "e" || "$temp_option" == "d" ]]; then
            option_code+="$temp_option"
            break
        else
            change_color "red"
            printf "[!] Invalid option! Please enter 'e' for encrypt or 'd' for decrypt.\n"
            change_color "magenta"
        fi
    done

    # Ask the user to select an algorithm: aes or rsa
    while true; do
        read -p "Select algorithm [aes/rsa]: " temp_option
        if [[ "$temp_option" == "aes" || "$temp_option" == "rsa" ]]; then
            option_code+="$temp_option"
            break
        else
            change_color "red"
            printf "[!] Invalid algorithm! Please enter 'aes' or 'rsa'.\n"
            change_color "magenta"
        fi
    done

    # If AES is selected, ask for the AES mode type
    if [ "$temp_option" == "aes" ]; then
        while true; do
            read -p "Select AES type [cbc/cfb/ofb/ctr/ecb]: " temp_option
            case "$temp_option" in
                cbc|cfb|ofb|ctr|ecb)
                    option_code+="$temp_option"
                    break
                    ;;
                *)
                    change_color "red"
                    printf "[!] Invalid AES type! Options: cbc, cfb, ofb, ctr, ecb.\n"
                    change_color "magenta"
                    ;;
            esac
        done
    else
        # For RSA, add a placeholder for AES type options
        option_code+="---"
    fi

    # Ask the user to enter a filename or file path until a valid one is provided
    while true; do
        read -p "Enter filename or file path: " file
        if [[ -f "$file" || -d "$file" ]]; then
            break
        else
            change_color "red"
            printf "[!] File doesn't exist!\n"
            change_color "magenta"
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

# Function processing aes encryption and decryption
process_aes() {
    read -s -p "Enter password: " password
    # Print a newline after reading the password so messages display correctly
    echo
    local option=${option_code:4:3}

    if [[ "${option_code:0:1}" == "e" ]]; then
        # Prepare tar for encryption mode
        tar_untar "0" || {
            change_color "red"
            printf "\n[!] Error during tar preparation."
            return 1
        }

        # Perform encryption with OpenSSL
        openssl enc "${aes_types[$option]}" -pbkdf2 -iter 1000 -salt \
            -in "$file" -out "encrypted.enc" -pass pass:"$password" || {
            change_color "red"
            printf "\n[!] Error during encryption."
            return 1
        }

        # Remove the original file; check if deletion succeeded
        rm "$file" || {
            change_color "red"
            printf "\n[!] Error removing the original file."
            return 1
        }

        change_color "green"
        printf "\n[+] File encrypted"

    else
        # Perform decryption with OpenSSL
        openssl enc -d "${aes_types[$option]}" -pbkdf2 -iter 1000 -salt \
            -in "$file" -out "decrypted.tar" -pass pass:"$password" || {
            change_color "red"
            printf "\n[!] Error during decryption."
            return 1
        }

        # Extract the decrypted tar archive
        tar_untar "1" || {
            change_color "red"
            printf "\n[!] Error during tar extraction."
            return 1
        }

        change_color "green"
        printf "\n[+] File decrypted"
    fi
}


# Main function
main () {
    clear
    banner
    menu
    process_aes
    printf "\n\n"
}

main

