#!/bin/bash 
#hardware info report
export SUDO_ASKPASS=/home/$(whoami)/askpass.sh
cd /home/$(whoami)/ASDworkspace

source ./colors.sh
source ./FUNCTION_FOLDER/hardware_functions.sh
source ./FUNCTION_FOLDER/menu_functions.sh

echo $user_log_file
auto_log_save hardware detailed
{

echo -e "${primary}=======================================${reset}"
echo -e "${primary}|     ${bold} HARDWARE INVENTORY REPORT      |${reset}"
echo -e "${primary}=======================================${reset}"
echo -e "${secondary}Generated on :${reset} $(date) "
echo -e "${secondary}Hostname     :${reset} $(hostname) "
echo -e "${secondary}User         :${reset} $(whoami) "
echo -e "${primary}Sections of the report:${reset} "

echo -e "   ${muted}1_SYSTEM OVERVIEW   "
echo -e "   2_PROCESSOR(CPU)   "
echo -e "   3_MEMORY(RAM)   "
echo -e "   4_STORAGE(DISKS)   "
echo -e "   5_GRAPHICS(GPU)   "
echo -e "   6_NETWORK HARDWARE   "
echo -e "   7_MOTHERBOARD INFO   "
echo -e "   8_USB DEVICES   "
echo -e "   9-FIRMWARES${reset}   "
echo -e "\n${secondary}STARTING THE REPORT...\n${reset}"

echo -e "   ${primary}Section 1 : SYSTEM OVERVIEW${reset}   " 
total_system_overview_info
echo " "

echo -e "   ${primary}Section 2 : PROCESSOR(CPU)${reset}   " 
total_cpu
echo " "

echo -e "   ${primary}Section 3 : MEMORY(RAM)${reset}   " 
total_memory
echo " "

echo -e "   ${primary}Section 4 : STORAGE(DISKS)${reset}   "
total_storage
echo " "

echo -e "   ${primary}Section 5 : GRAPHICS(GPU)${reset}   "
total_graphics
echo " "

echo -e "   ${primary}Section 6 : NETWORK HARDWARE${reset}   "
total_network_hardware
echo " "

echo -e "   ${primary}Section 7 : MOTHERBOARD INFO${reset}   "
total_motherboard
echo " "

echo -e "   ${primary}Section 8 : USB DEVICES${reset}   "
total_usb
echo " "

echo -e "   ${primary}Section 9 : FIRMWARES${reset}   "
total_bios_uefi_firmware
echo " "

echo -e "${success}Auto_save succeeded.${reset}"

echo -e "${primary}=======================================${reset}"
echo -e "${primary}|           ${bold} END OF REPORT            |${reset}"
echo -e "${primary}=======================================${reset}"
} | sudo -A tee "$user_log_file" && chown vboxuser5:vboxuser5 "$user_log_file" 2>/dev/null
send_via_email_auto "znghada59@gmail.com" "System report" "please find attached" 2
chown vboxuser5:vboxuser5 "$user_log_file" 2>/dev/null