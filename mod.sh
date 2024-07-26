#!/bin/bash

# Script Name: LazyM
# Description: A multi-function lazy manager script for wireless network analysis and file operations
# Author: Your Name
# Date: July 25, 2024

# Function definitions
function show_menu {
    echo "Welcome to Your Lazy Manager"
    echo "Please select an option:"
    echo "1) Airmon"
    echo "2) Airodump"
    echo "3) Aireplay"
    echo "4) Aircrack"
    echo "5) Decrypt"
    echo "6) ARP scan"
    echo "7) NMAP scan"
    echo "8) Exit"
}

function airmon_function {
read -p "what serial do you want to us (e4:d6:f7): " input

    echo "Running Airmon..."
    echo "Killing interfering processes..."
    sudo airmon-ng check kill
    sleep 2
    echo "Starting monitor mode on wlan1..."
    sudo airmon-ng start wlan1
    sleep 2
    sudo ip link set wlan1mon down
    sleep 1
    sudo macchanger -m bc:52:b7:$input wlan1mon
    sleep 1 
    sudo ip link set wlan1mon up
    sleep 1
    echo "Displaying wireless interfaces:"
    iwconfig
    echo "Airmon process completed."
}

function airodump_function {
    echo "Running Airodump..."
    
    local band=""
    local channel=""
    local target=""
    local write_file=""
    local interface="wlan1mon"  # Assuming wlan1mon is the monitor mode interface
    
    # Prompt for band
    echo "Do you want to specify a band? (y/n)"
    read band_choice

    if [ "$band_choice" = "y" ]; then
        echo "Enter band (a/b/ab):"
        read band
        band_option="--band $band"

        # Prompt for writing to file
        echo "Do you want to write the output to a file? (y/n)"
        read write_to_file

        if [ "$write_to_file" = "y" ]; then
            # Prompt for output file name
            echo "Enter output file name (without extension):"
            read output_file

            # Run airodump-ng with band option and write to file
            sudo airodump-ng $band_option -w "$output_file" $interface
        else
            # Run airodump-ng with band option without writing to file
            sudo airodump-ng $band_option $interface
        fi
    else
        # Prompt for channel
        echo "Do you want to specify a channel? (y/n)"
        read channel_choice

        if [ "$channel_choice" = "y" ]; then
            echo "Enter channel number:"
            read channel
            channel_option="-c $channel"

            # Prompt for target (BSSID or ESSID)
            echo "Do you want to specify a target? (y/n)"
            read target_choice

            if [ "$target_choice" = "y" ]; then
                echo "Enter target type (BSSID or ESSID):"
                read target_type

                if [ "$target_type" = "BSSID" ]; then
                    echo "Enter target BSSID:"
                    read target
                    target_option="--bssid $target"
                elif [ "$target_type" = "ESSID" ]; then
                    echo "Enter target ESSID:"
                    read target
                    target_option="--essid $target"
                else
                    echo "Invalid target type. Exiting..."
                    return 1
                fi

                # Prompt for output file name
                echo "Enter output file name (without extension):"
                read output_file

                # Run airodump-ng with channel, target, and output file options
                sudo airodump-ng $channel_option $target_option -w "$output_file" $interface
            else
                # Prompt for output file name
                echo "Enter output file name (without extension):"
                read output_file

                # Run airodump-ng with channel and output file options
                sudo airodump-ng $channel_option -w "$output_file" $interface
            fi
        else
            # Prompt for target (BSSID or ESSID)
            echo "Do you want to specify a target? (y/n)"
            read target_choice

            if [ "$target_choice" = "y" ]; then
                echo "Enter target type (BSSID or ESSID):"
                read target_type

                if [ "$target_type" = "BSSID" ]; then
                    echo "Enter target BSSID:"
                    read target
                    target_option="--bssid $target"
                elif [ "$target_type" = "ESSID" ]; then
                    echo "Enter target ESSID:"
                    read target
                    target_option="--essid $target"
                else
                    echo "Invalid target type. Exiting..."
                    return 1
                fi

                # Prompt for output file name
                echo "Enter output file name (without extension):"
                read output_file

                # Run airodump-ng with target and output file options
                sudo airodump-ng $target_option -w "$output_file" $interface
            else
                echo "No channel or target specified. Exiting..."
                return 1
            fi
        fi
    fi
}

function aireplay_function {
    echo "Running Aireplay..."
    
    # Prompt for deauth number
    read -p "Enter the number of deauthentication packets to send: " deauth_num
    # Prompt for BSSID
    read -p "Enter BSSID: " bssid
    # Prompt for Station
    read -p "Enter STATION (client MAC address): " station
    
    # Construct and run the aireplay-ng command
    echo "Running aireplay-ng with the following parameters:"
    echo "Deauth packets: $deauth_num"
    echo "BSSID: $bssid"
    echo "Station: $station"
    
    sudo aireplay-ng -0 "$deauth_num" -a "$bssid" -c "$station" wlan1mon
}

function aircrack_function {
    echo "Running Aircrack..."
    
    # Prompt for wordlist file
    read -p "Enter the wordlist file name: " wordlist
    # Prompt for pcap file
    read -p "Enter the pcap file name: " cap_file
    
    # Construct and run the aircrack-ng command
    echo "Running aircrack-ng with the following parameters:"
    echo "Wordlist: $wordlist"
    echo "PCAP file: $cap_file"
    
    sudo aircrack-ng -w "$wordlist" "$cap_file"
}

function decrypt_function {
    echo "Select Decryption Method:"
    echo "1) xxd"
    echo "2) base64"
    echo "3) openssl"
    echo "4) 7-Zip"
    echo "5) steghide"
    
    read -p "Choose an option [1-5]: " method_choice
    read -p "Enter the input file name: " input_file
    read -p "Do you want to create an output file? (yes/no): " create_output
    
    if [[ "$create_output" == "yes" ]]; then
        read -p "Enter the output file name: " output_file
    fi
    
    case $method_choice in
        1)  # xxd
            if [[ -n "$output_file" ]]; then
                sudo xxd -p -r "$input_file" > "$output_file"
            else
                sudo xxd -p -r "$input_file"
            fi
            ;;
        2)  # base64
            if [[ -n "$output_file" ]]; then
                sudo base64 --decode "$input_file" > "$output_file"
            else
                sudo base64 --decode "$input_file"
            fi
            ;;
        3)  # openssl
            if [[ -n "$output_file" ]]; then
                sudo openssl enc -aes-256-cbc -d -in "$input_file" -out "$output_file"
            else
                echo "Output file is required for openssl."
            fi
            ;;
        4)  # 7-Zip
            sudo 7z e "$input_file"
            ;;
        5)  # steghide
            sudo steghide extract -sf "$input_file"
            ;;
        *) 
            echo "Invalid option. Please try again."
            ;;
    esac
}

function ARP_scan_function {
    echo "Choose ARP scan option"
    echo "1) NMAP ARP"
    echo "2) META ARP"
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in 
        1)
            echo "Running NMAP ARP scan..."
            sudo arp-scan -l -I wlan0
            ;;
        2)
            echo "Running META ARP scan..."
            sudo arp-scan -l -I wlan0
            ;;
        *)
            echo "Invalid choice. Please select 1 or 2."
            ;;
    esac         
}

function NMAP_scan_function {
    echo "Choose NMAP scan option:"
    echo "1) NMAP"
    echo "2) Metasploit"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            read -p "Enter target IP: " target_ip
            read -p "Do you want to specify ports? (y/n): " specify_ports
            if [ "$specify_ports" == "y" ]; then
                read -p "Enter ports (e.g., 80,443): " ports
                sudo nmap -sV -Pn -p"$ports" "$target_ip"
            else
                sudo nmap -sV -Pn -p- "$target_ip"
            fi
            ;;
        2)
            read -p "Enter target IP: " target_ip
            read -p "Do you want to specify ports? (y/n): " specify_ports
            if [ "$specify_ports" == "y" ]; then
                 read -p "Enter ports (e.g., 80,443): " ports
                 sudo nmap -n -v -Pn -p"$ports" "$target_ip" -sVC -oA targetports
            else
                 sudo nmap -n -v -Pn -p- "$target_ip" -sVC -oA allports
            fi      
            ;;
        *)
            echo "Invalid choice. Please select 1 or 2."
            ;;
    esac
    
}

# Main script execution
while true; do
    show_menu
    read -p "Enter your choice [1-8]: " choice
    case $choice in
        1) airmon_function ;;
        2) airodump_function ;;
        3) aireplay_function ;;
        4) aircrack_function ;;
        5) decrypt_function ;;
        6) ARP_scan_function ;;
        7) NMAP_scan_function ;;
        8) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    echo
    read -p "Press Enter to continue..."
    clear
done
