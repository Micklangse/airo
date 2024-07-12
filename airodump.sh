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

    # Prompt for writing to file
    echo "Do you want to write the output to a file? (y/n)"
    read write_to_file

    if [ "$write_to_file" = "y" ]; then
        # Prompt for output file name
        echo "Enter output file name (without extension):"
        read output_file

        # Run airodump-ng with band option and write to file
        sudo airodump-ng $band_option -w "$output_file" wlan1mon
    else
        # Run airodump-ng with band option without writing to file
        sudo airodump-ng $band_option wlan1mon
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
                exit 1
            fi

            # Prompt for output file name
            echo "Enter output file name (without extension):"
            read output_file

            # Run airodump-ng with channel, target, and output file options
            sudo airodump-ng $channel_option $target_option -w "$output_file" wlan1mon
        else
            # Prompt for output file name
            echo "Enter output file name (without extension):"
            read output_file

            # Run airodump-ng with channel and output file options
            sudo airodump-ng $channel_option -w "$output_file" wlan1mon
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
                exit 1
            fi

            # Prompt for output file name
            echo "Enter output file name (without extension):"
            read output_file

            # Run airodump-ng with target and output file options
            sudo airodump-ng $target_option -w "$output_file" wlan1mon
        else
            echo "No channel or target specified. Exiting..."
            exit 1
        fi
    fi
fi
