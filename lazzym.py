import ttkbootstrap as ttk
from ttkbootstrap.constants import *
from tkinter import simpledialog, messagebox
import subprocess

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        messagebox.showinfo("Output", result.stdout)
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", e.stderr)

def airmon_function():
    input_serial = simpledialog.askstring("Input", "What serial do you want to use (e4:d6:f7):")
    if input_serial:
        commands = [
            "sudo airmon-ng check kill",
            "sleep 2",
            "sudo airmon-ng start wlan1",
            "sleep 2",
            "sudo ip link set wlan1mon down",
            f"sudo macchanger -m bc:52:b7:{input_serial} wlan1mon",
            "sleep 1",
            "sudo ip link set wlan1mon up",
            "sleep 1",
            "iwconfig"
        ]
        for cmd in commands:
            run_command(cmd)

def airodump_function():
    band_choice = messagebox.askyesno("Band", "Do you want to specify a band?")
    if band_choice:
        band = simpledialog.askstring("Band", "Enter band (a/b/ab):")
        write_to_file = messagebox.askyesno("Output", "Do you want to write the output to a file?")
        if write_to_file:
            output_file = simpledialog.askstring("Output File", "Enter output file name (without extension):")
            run_command(f"sudo airodump-ng --band {band} -w {output_file} wlan1mon")
        else:
            run_command(f"sudo airodump-ng --band {band} wlan1mon")
    else:
        channel_choice = messagebox.askyesno("Channel", "Do you want to specify a channel?")
        if channel_choice:
            channel = simpledialog.askstring("Channel", "Enter channel number:")
            target_choice = messagebox.askyesno("Target", "Do you want to specify a target?")
            if target_choice:
                target_type = simpledialog.askstring("Target Type", "Enter target type (BSSID or ESSID):")
                target = simpledialog.askstring("Target", f"Enter target {target_type}:")
                output_file = simpledialog.askstring("Output File", "Enter output file name (without extension):")
                run_command(f"sudo airodump-ng -c {channel} --{target_type.lower()} {target} -w {output_file} wlan1mon")
            else:
                output_file = simpledialog.askstring("Output File", "Enter output file name (without extension):")
                run_command(f"sudo airodump-ng -c {channel} -w {output_file} wlan1mon")
        else:
            target_choice = messagebox.askyesno("Target", "Do you want to specify a target?")
            if target_choice:
                target_type = simpledialog.askstring("Target Type", "Enter target type (BSSID or ESSID):")
                target = simpledialog.askstring("Target", f"Enter target {target_type}:")
                output_file = simpledialog.askstring("Output File", "Enter output file name (without extension):")
                run_command(f"sudo airodump-ng --{target_type.lower()} {target} -w {output_file} wlan1mon")
            else:
                messagebox.showinfo("Info", "No channel or target specified. Exiting...")

def aireplay_function():
    deauth_num = simpledialog.askstring("Deauth Packets", "Enter the number of deauthentication packets to send:")
    bssid = simpledialog.askstring("BSSID", "Enter BSSID:")
    station = simpledialog.askstring("Station", "Enter STATION (client MAC address):")
    run_command(f"sudo aireplay-ng -0 {deauth_num} -a {bssid} -c {station} wlan1mon")

def aircrack_function():
    wordlist = simpledialog.askstring("Wordlist", "Enter the wordlist file name:")
    cap_file = simpledialog.askstring("PCAP File", "Enter the pcap file name:")
    run_command(f"sudo aircrack-ng -w {wordlist} {cap_file}")

def decrypt_function():
    method_choice = simpledialog.askinteger("Decryption Method", "Select Decryption Method:\n1) xxd\n2) base64\n3) openssl\n4) 7-Zip\n5) steghide")
    input_file = simpledialog.askstring("Input File", "Enter the input file name:")
    create_output = messagebox.askyesno("Output File", "Do you want to create an output file?")
    output_file = ""
    if create_output:
        output_file = simpledialog.askstring("Output File", "Enter the output file name:")
    
    if method_choice == 1:
        cmd = f"sudo xxd -p -r {input_file}"
    elif method_choice == 2:
        cmd = f"sudo base64 --decode {input_file}"
    elif method_choice == 3:
        if output_file:
            cmd = f"sudo openssl enc -aes-256-cbc -d -in {input_file} -out {output_file}"
        else:
            messagebox.showerror("Error", "Output file is required for openssl.")
            return
    elif method_choice == 4:
        cmd = f"sudo 7z e {input_file}"
    elif method_choice == 5:
        cmd = f"sudo steghide extract -sf {input_file}"
    else:
        messagebox.showerror("Error", "Invalid option. Please try again.")
        return
    
    if output_file:
        cmd += f" > {output_file}"
    run_command(cmd)

def ARP_scan_function():
    choice = simpledialog.askinteger("ARP Scan", "Choose ARP scan option:\n1) NMAP ARP\n2) META ARP")
    if choice == 1:
        run_command("sudo arp-scan -l -I wlan0")
    elif choice == 2:
        run_command("sudo arp-scan -l -I wlan0")
    else:
        messagebox.showerror("Error", "Invalid choice. Please select 1 or 2.")

def NMAP_scan_function():
    choice = simpledialog.askinteger("NMAP Scan", "Choose NMAP scan option:\n1) NMAP\n2) Metasploit")
    target_ip = simpledialog.askstring("Target IP", "Enter target IP:")
    specify_ports = messagebox.askyesno("Ports", "Do you want to specify ports?")
    if specify_ports:
        ports = simpledialog.askstring("Ports", "Enter ports (e.g., 80,443):")
        if choice == 1:
            run_command(f"sudo nmap -sV -Pn -p{ports} {target_ip}")
        elif choice == 2:
            run_command(f"sudo nmap -n -v -Pn -p{ports} {target_ip} -sVC -oA targetports")
    else:
        if choice == 1:
            run_command(f"sudo nmap -sV -Pn -p- {target_ip}")
        elif choice == 2:
            run_command(f"sudo nmap -n -v -Pn -p- {target_ip} -sVC -oA allports")

def show_menu():
    app = ttk.Window(themename="darkly")
    app.title("Lazy Manager")
    
    ttk.Label(app, text="Welcome to Your Lazy Manager", font=("Helvetica", 16)).pack(pady=10)
    ttk.Label(app, text="Please select an option:", font=("Helvetica", 12)).pack(pady=5)
    
    ttk.Button(app, text="1) Airmon", command=airmon_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="2) Airodump", command=airodump_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="3) Aireplay", command=aireplay_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="4) Aircrack", command=aircrack_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="5) Decrypt", command=decrypt_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="6) ARP scan", command=ARP_scan_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="7) NMAP scan", command=NMAP_scan_function, bootstyle=SUCCESS).pack(pady=5)
    ttk.Button(app, text="8) Exit", command=app.quit, bootstyle=DANGER).pack(pady=5)
    
    app.mainloop()

if __name__ == "__main__":
    show_menu()
