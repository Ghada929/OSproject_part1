#!/bin/zsh
export SUDO_ASKPASS=/home/$(whoami)/askpass.sh
cd /home/$(whoami)/ASDworkspace

source ./colors.sh
source ./FUNCTION_FOLDER/software_functions.sh
source ./FUNCTION_FOLDER/menu_functions.sh

echo $user_log_file
auto_log_save "software" "short"
{

echo -e "${primary}====== SOFTWARE SHORT REPORT ======${reset}"

echo -e "\n${primary}SYSTEM INFO${reset}"
os_info

echo -e "\n${primary}USERS${reset}"
users_info

echo -e "\n${primary}PROCESSES${reset}"
process_info

echo -e "\n${primary}SERVICES${reset}"
services_info

echo -e "\n${primary}PORTS${reset}"
ports_info

} | sudo -A tee "$user_log_file"
chown vboxuser5:vboxuser5 "$user_log_file" 2>/dev/null
send_via_email_auto "znghada59@gmail.com" "System report" "please find attached" 3