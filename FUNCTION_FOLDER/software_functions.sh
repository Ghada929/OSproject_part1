#!/bin/zsh
#=====================================
#      SOFTWARE REPORT FUNCTIONS      
#=====================================

#======== SHORT (NON DETAILED) ========

os_info(){
    echo "========== SYSTEM INFO =========="
    printf "%-20s : %s\n" "OS" "$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
    printf "%-20s : %s\n" "Kernel" "$(uname -r)"
    printf "%-20s : %s\n" "Architecture" "$(uname -m)"
}

users_info(){
    echo "\n========== LOGGED USERS =========="
    who | awk '{printf "%-15s %-15s %-20s\n",$1,$2,$3}'
}

process_info(){
    echo "\n========== TOP PROCESSES =========="
    ps aux | awk 'NR==1 {printf "%-10s %-6s %-6s %-10s %-10s %s\n",$1,$2,$3,$4,$5,$11}
                  NR>1 && NR<=6 {printf "%-10s %-6s %-6s %-10s %-10s %s\n",$1,$2,$3,$4,$5,$11}'
}

services_info(){
    echo "\n========== ACTIVE SERVICES =========="
    systemctl list-units --type=service --state=running \
    | awk 'NR>1 && NR<=6 {printf "%-40s %-10s %-10s\n",$1,$3,$4}'
}

ports_info(){
    echo "\n========== OPEN PORTS =========="
    ss -tuln | awk 'NR>1 {printf "%-10s %-20s %-20s\n",$1,$5,$6}' | head -5
}

packages_info(){
    echo "\n========== INSTALLED PACKAGES =========="
    dpkg -l | awk 'NR>5 && NR<=10 {printf "%-10s %-30s %-15s\n",$1,$2,$3}'
}

#======== DETAILED FUNCTIONS ========

get_hostname(){
    printf "\n%-20s : %s\n" "Hostname" "$(hostname)"
}

get_uptime(){
    printf "%-20s : %s\n" "Uptime" "$(uptime -p)"
}

get_current_user(){
    printf "%-20s : %s\n" "Current User" "$(whoami)"
}

get_all_users(){
    echo "\n========== SYSTEM USERS =========="
    cut -d: -f1 /etc/passwd | awk '{printf "%-20s\n",$1}' | head -15
}

get_full_processes(){
    echo "\n========== ALL PROCESSES =========="
    ps aux | awk '{printf "%-10s %-6s %-6s %-10s %-10s %s\n",$1,$2,$3,$4,$5,$11}'
}

get_full_services(){
    echo "\n========== ALL SERVICES =========="
    systemctl list-units --type=service \
    | awk 'NR>1 {printf "%-40s %-10s %-10s\n",$1,$3,$4}'
}

get_full_ports(){
    echo "\n========== ALL PORTS =========="
    ss -tuln | awk 'NR>1 {printf "%-10s %-20s %-20s\n",$1,$5,$6}'
}

get_package_count(){
    printf "\n%-20s : %s\n" "Total Packages" "$(dpkg -l | wc -l)"
}