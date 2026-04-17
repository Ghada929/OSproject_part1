#!/bin/zsh
export SUDO_ASKPASS=/home/$(whoami)/askpass.sh
cd /home/$(whoami)/ASDworkspace

source ./colors.sh
source ./FUNCTION_FOLDER/software_functions.sh
source ./FUNCTION_FOLDER/menu_functions.sh

echo $user_log_file
auto_log_save "software" "detailed"
{

#===============================
#      REPORT HEADER
#===============================

echo -e "${primary}============================================${reset}"
echo -e "${primary}        SOFTWARE INVENTORY REPORT          ${reset}"
echo -e "${primary}============================================${reset}"

echo -e "${secondary}Generated At :${reset} $(date)"
echo -e "${secondary}Hostname     :${reset} $(hostname)"
echo -e "${secondary}User         :${reset} $(whoami)"

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}              SYSTEM OVERVIEW              ${reset}"
echo -e "${primary}============================================${reset}"

get_hostname
get_uptime
get_current_user

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}                 OS INFO                   ${reset}"
echo -e "${primary}============================================${reset}"

os_info

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}                 USERS                     ${reset}"
echo -e "${primary}============================================${reset}"

get_all_users

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}               PROCESSES                  ${reset}"
echo -e "${primary}============================================${reset}"

get_full_processes

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}                SERVICES                  ${reset}"
echo -e "${primary}============================================${reset}"

get_full_services

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}                  PORTS                   ${reset}"
echo -e "${primary}============================================${reset}"

get_full_ports

echo -e "\n${primary}============================================${reset}"
echo -e "${primary}                PACKAGES                 ${reset}"
echo -e "${primary}============================================${reset}"

get_package_count

echo -e "\n${success}REPORT COMPLETED SUCCESSFULLY${reset}"
echo -e "${muted}End of analysis${reset}"

} | sudo -A tee "$user_log_file"
chown vboxuser5:vboxuser5 "$user_log_file" 2>/dev/null
send_via_email_auto "znghada59@gmail.com" "System report" "please find attached" 4