#!/bin/bash

sudo airmon-ng check
sleep 1
sudo airmon-ng check kill
sleep 1
sudo airmon-ng start wlan1
sleep 1
iwconfig
sleep 2

# Prompt for band
echo "Do you want to specify a band? (y/n)"
read band_choice

if [ "$band_choice" = "y" ]; then
    echo "Enter band (a/b/ab):"
    read band
    band_option="--band $band"
    
    # Prompt for output file name
    echo "Enter output file name (without extension):"
    read output_file
    
    # Run airodump-ng with band option
    sudo airodump-ng $band_option -w "$output_file" wlan1mon
else
    # Prompt for channel
    echo "Do you want to specify a channel? (y/n)"
    read channel_choice
    
    if [ "$channel_choice" = "y" ]; then
        echo "Enter channel number:"
        read channel
        channel_option="-c $channel"
    else
        channel_option=""
    fi
    
    # Prompt for target (BSSID or ESSID)
    echo "Do you want to specify a target? (y/n)"
    read target_choice
    
    if [ "$target_choice" = "y" ]; then
        echo "Enter target (BSSID or ESSID):"
        read target
        target_option="$target"
    else
        target_option=""
    fi
    
    # Prompt for output file name
    echo "Enter output file name (without extension):"
    read output_file
    
    # Run airodump-ng with channel and target options
    sudo airodump-ng $channel_option $target_option -w "$output_file" wlan1mon
fi
