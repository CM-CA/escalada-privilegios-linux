#!/bin/bash
# Define colors
red='\e[31m'
reset='\e[0m'
green='\e[32m'
blue='\e[34m'
violet='\e[35m'

# Function to display the menu
menu() {
    echo -e "${red}|-----------------------------|${reset}"
    echo -e "${red}|   Welcome to Priv_Linux!    |${reset}"
    echo -e "${red}|-----------------------------|${reset}\n"
}

# Function to handle SIGINT signal (Ctrl + C)
exit_handler() {
    echo -e "\n${red}Exiting...${reset}"
    exit 1
}

# Set the exit_handler function as the handler for SIGINT signal
trap exit_handler SIGINT

# Folder for output files
output_folder="priv_linux_results"

# Function to create the output folder if it doesn't exist
create_output_folder() {
    if [ ! -d "$output_folder" ]; then
        mkdir "$output_folder"
    fi
}

# Function to pause and wait for user input
pause() {
    read -p "Press Enter to continue..."
    echo
}

# Function to handle basic commands
basic_commands() {
    output_file="$output_folder/basic_commands.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}============= Basic Commands =============${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}=========== Current User ================${reset}"
    echo -e "${blue}=========================================${reset}"
    whoami | tee -a "$output_file"
    echo -e "${red}\nid\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}======= User and Group Information ======${reset}"
    echo -e "${blue}=========================================${reset}"
    id | tee -a "$output_file"
    echo -e "${red}\nenv\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}========== User System Variables ========${reset}"
    echo -e "${blue}=========================================${reset}"
    env | tee -a "$output_file"
    echo -e "${red}\nps -eo\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}=== Commands Executed on the System ===${reset}"
    echo -e "${blue}=========================================${reset}"
    ps -eo user,command | tee -a "$output_file"
}

# Function to handle SUID, sudo, and capabilities permissions
suid_sudo_capabilities() {
    output_file="$output_folder/suid_sudo_capabilities.txt"
    [ -f "$output_file" ] && rm "$output_file"
    read -p "Do you have the current user's password? (Y/N): " response
    if [ "$response" = "Y" ]; then
        read -sp "Enter the password: " password
    else
        echo -e "${red}No password available, proceeding with the process${reset}"
        password=""
    fi
    echo

    echo -e "${red}=== SUID, sudo, and Capabilities Permissions ===${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}========== SUID Permissions =============${reset}"
    echo -e "${blue}=========================================${reset}"
    while IFS= read -r file; do
        if [[ $file =~ (dbus-daemon-launch-helper|ssh-keysign|su|newgrp|passwd|umount|chfn|gpasswd|chsh|mount|sudo|mount.nfs) ]]; then
            echo "$file" | tee -a "$output_file"
        else
            echo -e "${red}$file${reset}" | tee -a "$output_file"
        fi
    done < <(find / -type f -perm -u=s 2>/dev/null)
    echo -e "${red}\nsudo result\n=====================\n${reset}" >> "$output_file"
    echo -e "${violet}Visit https://gtfobins.github.io/ to check for matching SUID binaries${reset}"
    echo -e "${blue}============================================${reset}"
    echo -e "${blue}============ sudo Permissions ==============${reset}"
    echo -e "${blue}============================================${reset}"
    echo -e "${password}\n" | sudo -S -l | tee -a "$output_file"
    echo -e "${red}\nCapabilities result\n=====================\n${reset}" >> "$output_file"
    echo -e "${violet}Visit https://gtfobins.github.io/ to check for matching sudo binaries${reset}" 
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}============= Capabilities ==============${reset}"
    echo -e "${blue}=========================================${reset}"
    getcap -r / 2>/dev/null | tee -a "$output_file"
    echo -e "${violet}Visit https://gtfobins.github.io/ to check for matching capabilities${reset}"
    echo -e "${red}\nAdditional find command\n=====================\n${reset}" >> "$output_file"
    find / -type f -name '*.txt' 2>/dev/null | tee -a "$output_file"
}

# Function to handle internal ports
internal_ports() {
    output_file="$output_folder/internal_ports.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}============= Internal Ports =============${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}=============== netstat =================${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${red}\nNetstat result\n=====================\n" >> "$output_file"
    netstat -tuln | tee -a "$output_file"
    echo -e "\nss -tulpn result\n=====================\n" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}============== ss -tulpn ================${reset}"
    echo -e "${blue}=========================================${reset}"
    ss -tulpn | tee -a "$output_file"
}

# Function to handle folders with write and/or read permissions
folders_permissions() {
    output_file="$output_folder/folders_permissions.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}===== Folders with Write and/or Read Permissions ===${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}============ Directories ================${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${red}\nDirectories\n=====================\n${reset}" >> "$output_file"
    find / -writable 2>/dev/null | cut -d "/" -f 2,3 | grep -v proc | sort -u | tee -a "$output_file"
    echo -e "${red}\nWritable files\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}============ Writable files =============${reset}"
    echo -e "${blue}=========================================${reset}"
    find / -writable 2>/dev/null | grep -v -i -E 'proc|run|sys|dev' | tee -a "$output_file"
}

# Function to handle core system files
core_system_files() {
    output_file="$output_folder/core_system_files.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}=========== Core system files ============${reset}"
    echo -e "${blue}=========================================${reset}"
    files_to_check=(
        "/etc/passwd"
        "/etc/shadow"
        "/etc/issue"
        "/etc/hostname"
        "/etc/login.defs"
        "/proc/version"
        "/proc/self/environ"
        "/proc/sched_debug"
    )
    for file in "${files_to_check[@]}"; do
        echo -e "${red}\n$file\n=====================\n${reset}" >> "$output_file"
        cat "$file" | tee -a "$output_file"
    done
}

# Function to handle cronjobs and system processes
cronjobs_system_processes() {
    output_file="$output_folder/cronjobs.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}=============== Cronjobs =================${reset}"
    echo -e "${blue}=========================================${reset}"
    files_to_check=(
        "/etc/crontab"
        "/var/spool/cron"
        "/etc/anacron"
    )
    for file in "${files_to_check[@]}"; do
        echo -e "${red}\n$file result\n=====================\n${reset}" >> "$output_file"
        cat "$file" | tee -a "$output_file"
    done
    echo -e "${red}\nsystemctl list-timers result\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}========= systemctl list-timers =========${reset}"
    echo -e "${blue}=========================================${reset}"
    systemctl list-timers | tee -a "$output_file"
    echo -e "${red}\nps aux\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}================= ps aux ================${reset}"
    echo -e "${blue}=========================================${reset}"
    ps aux | tee -a "$output_file"
}

# Function to handle kernel check
kernel_check() {
    output_file="$output_folder/kernel.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}============= Kernel check ===============${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}================ uname -a ===============${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${red}\nuname -a result\n=====================\n${reset}" >> "$output_file"
    uname -a | tee -a "$output_file"
    echo -e "${red}\nlsb_release result\n=====================\n${reset}" >> "$output_file"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}=========== lsb_release -a ==============${reset}"
    echo -e "${blue}=========================================${reset}"
    lsb_release -a | tee -a "$output_file"
}

# Function to handle NFS
nfs_check() {
    output_file="$output_folder/nfs.txt"
    [ -f "$output_file" ] && rm "$output_file"
    echo -e "${red}=== NFS /etc/exports ===${reset}"
    echo -e "${blue}=========================================${reset}"
    echo -e "${blue}========== NFS - /etc/exports ===========${reset}"
    echo -e "${blue}=========================================${reset}"
    sed '/no_root_squash/s//\x1b[31m&\x1b[0m/' /etc/exports
    echo -e "${violet}If the 'no_root_squad' is in the file check that PE --> https://j4ckie0x17.gitbook.io/notes-pentesting/escalada-de-privilegios/linux#nfs${reset}"
}

# Main loop
while true; do
    # Show menu
    menu

    echo -e "REMINDER: All the results will be saved at folder ${red}priv_linux_results${reset}, Example: (currentpath)/priv_linux_results/basic_commands.txt"
    echo
    echo -e "${red}Select an option:${reset}"
    echo
    echo -e "1. ${green}Basic Commands${reset}"
    echo -e "2. ${green}SUID, sudo, and Capabilities Permissions${reset}"
    echo -e "3. ${green}Internal Ports${reset}"
    echo -e "4. ${green}Folders with Write and/or Read Permissions${reset}"
    echo -e "5. ${green}Core system files${reset}"
    echo -e "6. ${green}Cronjobs/System processes${reset}"
    echo -e "7. ${green}Kernel check${reset}"
    echo -e "8. ${green}NFS (/etc/exports), if there is NFS${reset}"
    echo -e "9. ${green}pspy64 (procmon-manual)${reset}"
    echo -e "10. ${red}Exit${reset}"
    echo

    # Read user selection
    read -p "Option: " option

    # Execute the selected option
    case $option in
        1)  create_output_folder
            basic_commands
            pause
            ;;
        2)  create_output_folder
            suid_sudo_capabilities
            pause
            ;;
        3)  create_output_folder
            internal_ports
            pause
            ;;
        4)  create_output_folder
            folders_permissions
            pause
            ;;
        5)  create_output_folder
            core_system_files
            pause
            ;;
        6)  create_output_folder
            cronjobs_system_processes
            pause
            ;;
        7)  create_output_folder
            kernel_check
            pause
            ;;
        8)  create_output_folder
            nfs_check
            pause
            ;;
        9)  echo -e "${blue}=========================================${reset}"
            echo -e "${blue}=========== pspy64 - procmon ============${reset}"
            echo -e "${blue}=========================================${reset}"
            old_process=$(ps -eo user,command)
            while true; do
                new_process=$(ps -eo user,command)
                diff <(echo "$old_process") <(echo "$new_process") | grep "[\>\<]" | grep -vE "procmon|command|kworker"
                old_process=$new_process
            done
            ;;
        10) echo "Exiting..."
            exit 0
            ;;
        *)  echo "Invalid option. Please select a number from 1 to 10."
            ;;
    esac
done
