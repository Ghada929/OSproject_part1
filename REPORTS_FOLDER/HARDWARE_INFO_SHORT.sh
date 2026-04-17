#!/bin/zsh
#hardware info report 
export SUDO_ASKPASS=/home/$(whoami)/askpass.sh
cd /home/$(whoami)/ASDworkspace
source ./colors.sh
source ./FUNCTION_FOLDER/hardware_functions.sh
source ./FUNCTION_FOLDER/menu_functions.sh
echo $user_log_file
auto_log_save "hardware" "short"
{
echo -e "${primary}=======================================${reset}"
echo -e "${primary}|     ${bold} HARDWARE INVENTORY REPORT      |${reset}"
echo -e "${primary}=======================================${reset}"
echo -e "${secondary}Generated on :${reset} $(date) "
echo -e "${secondary}Hostname     :${reset} $(hostname) "
echo -e "${secondary}User         :${reset} $(whoami) "
echo -e "${primary}Sections of the report:${reset} "
echo -e "   ${muted}1_PROCESSOR(CPU)   "
echo -e "   2_MEMORY(RAM)   "
echo -e "   3_STORAGE(DISKS)   "
echo -e "   4_GRAPHICS(GPU)   "
echo -e "   5_NETWORK HARDWARE   "
echo -e "   6_MOTHERBOARD INFO   "
echo -e "   7_USB DEVICES${reset}   "

echo -e "\n${secondary}STARTING THE REPORT...\n"

echo "   ${primary}Section 1 : PROCESSOR(CPU)${reset}   " 
cpu_info
echo " "

echo "   ${primary}Section 2 : MEMORY(RAM)${reset}   " 
memory_info
echo " "

echo "   ${primary}Section 3 : STORAGE(DISKS)${reset}   " 
storage_info
echo " "

echo "   ${primary}Section 4 : GRAPHICS${reset}   "
graphic_info
echo " "

echo "   ${primary}Section 5 : NETWORK HARDWARE${reset}   "
network_info
echo " "

echo "   ${primary}Section 6 : MOTHERBOARD INFO${reset}   "
motherboard_info
echo " "

echo "   ${primary}Section 7 : USB DEVICES${reset}   "
usb_device_info
echo " "
echo -e "${success}Auto_save succeeded.${reset}"
echo -e "${primary}=======================================${reset}"
echo -e "${primary}|           ${bold} END OF REPORT            |${reset}"
echo -e "${primary}=======================================${reset}"
} | sudo -A tee "$user_log_file" 
send_via_email_auto "znghada59@gmail.com" "System report" "please find attached" 1
chown vboxuser5:vboxuser5 "$user_log_file" 2>/dev/null