#!/bin/zsh
# menu functions
source ./colors.sh
export SUDO_ASKPASS=/home/$(whoami)/askpass.sh
REMOTE_CONFIG="$HOME/.remote_machines"
show_menu(){
    echo -e "${primary}======================================"
    echo -e "       ${bold}SYSTEM REPORT GENERATOR${reset}       "
    echo -e "${primary}======================================${reset}"
    echo -e "       ${muted}1_Generate Reports       "
    echo -e "       2_Save Report To A File       "
    echo -e "       3_Send Report Via Email       "
    echo -e "       4_Automating Execution       "
    echo -e "       5_Remote Access       "
    echo -e "       6_Exit${reset}       "
    echo -e "${primary}======================================${reset}"
echo -e "Enter your choice [1 - 6]" 
} 

report_menu(){
    echo -e "${primary}================================="
    echo -e "     ${bold}Generating Report Menu${reset}     "
    echo -e "${primary}=================================${reset}"
    echo -e "   ${muted}1_Generate hardware report   "
    echo -e "   2_Generate software report   "
    echo -e "   3_Return to the main menu${reset}   "
    echo -e "${primary}=================================${reset}"
echo -e "Enter your choice [1 - 3]"  
}

hardware_menu(){
    echo -e "${primary}=========================================="
    echo -e "     ${bold}Generating Hardware Report Menu${reset}     "
    echo -e "${primary}==========================================${reset}"
    echo -e "   ${muted}1_Generate detailed hardware report   "
    echo -e "   2_Generate short hardware report      "
    echo -e "   3_Return to the report menu           "
    echo -e "   4_Return to the main menu${reset}             "
    echo -e "${primary}==========================================${reset}"
echo -e "Enter your choice [1 - 4]"
}

software_menu(){
    echo -e "${primary}=========================================="
    echo -e "     ${bold}Generating Software Report Menu${reset}     "
    echo -e "${primary}==========================================${reset}"
    echo -e "   ${muted}1_Generate detailed software report   "
    echo -e "   2_Generate short software report      "
    echo -e "   3_Return to the report menu           "
    echo -e "   4_Return to the main menu${reset}             "
    echo -e "${primary}==========================================${reset}"
echo -e "Enter your choice [1 - 4]"
}

auto_log_save(){
    local file_type="$1"
    local version="$2"
    local user_log_dir="/var/log/sys_audit/$(hostname)/$(whoami)/$file_type/$version"
    sudo -A mkdir -p "$user_log_dir" 2>/dev/null || mkdir -p "$user_log_dir"
    local user_log_timestamp=$(date +"%Y%m%d_%H%M%S")
    user_log_file="$user_log_dir/report_${file_type}_${version}_$user_log_timestamp.txt"
    echo $user_log_file
}


manual_save(){
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Saving Reports Manualy${reset}      "
    echo -e "${primary}==========================================${reset}"
    echo -e "   ${muted}1_Saving detailed hardware report   "
    echo -e "   2_Saving short hardware report             "
    echo -e "   3_Saving detailed software report             "
    echo -e "   4_Saving short software report${reset}             "
    echo -e "${primary}==========================================${reset}"
    echo  "Enter your choice [1 - 4]: "
    read save 
    case $save in  
        1)
            # saving detailed hardware report
            Report_type="hardware"
            ver="detailed"
        ;;
        2)
            # saving short hardware report
            Report_type="hardware"
            ver="short"
        ;;
        3)
            # saving detailed software report
            Report_type="software"
            ver="detailed"
        ;;
        4)
            # saving short software report
            Report_type="software"
            ver="short"
        ;;
        *)
            # default case
            echo "Invalid choice."
        ;;
    esac
        REPORT_DIR="/var/log/sys_audit/$(hostname)/$(whoami)/$Report_type/$ver"
        # checking if dir exists
        if [ ! -d "$REPORT_DIR" ]; then
            echo -e "${red}No $Report_type reports found!${reset}"
        fi
        echo ""
        echo -e "${primary}Available $Report_type reports:${reset}"
        count=0
        for file in "$REPORT_DIR"/*.txt; do
            if [ -f "$file" ]; then
                echo " $file"
                count=$((count + 1))
            fi
        done 

        if [ "$count" -eq 0 ]; then 
            echo -e "${warning}No reports in $REPORT_DIR${reset}"
        fi

        echo ""

        # Ask user for filename to copy
        echo -n -e "${secondary}Enter the filename to copy (e.g., report_hardware_20250326_143022.txt):${reset} "
        read source_filename
    
        # Construct full path
        source_file="$REPORT_DIR/$source_filename"
    
        # Check if file exists
        while [ ! -f "$source_file" ]; do
        echo -e "${warning}File not found!${reset}"
        echo -n -e "${secondary}Enter a valid filename:${reset} "
        read source_filename
        source_file="$REPORT_DIR/$source_filename"
        done  

        # Ask destination filename
        echo ""
        echo -n -e "${secondary}Enter destination filename (e.g., my_report.txt):${reset} "
        read dest_filename

        # Add .txt if not present
        if [[ "$dest_filename" != *.txt ]]; then
            dest_filename="${dest_filename}.txt"
        fi
    
        # Create saved_reports directory
        mkdir -p "./saved_reports"
    
        # Check if destination already exists
        while [ -f "./saved_reports/$dest_filename" ]; do
            echo -e "${red}File already exists!${reset}"
            echo -n -e "${cyan}Enter a different filename:${reset} "
            read dest_filename
        done
    
        # Copy the file
        cp "$source_file" "./saved_reports/$dest_filename" 
        echo -e "${success}✓ Report saved to: ./saved_reports/$dest_filename${reset}"

}

send_via_email(){
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Send Report Via Email${reset}      "
    echo -e "${primary}==========================================${reset}"
    
    # 1. Get email address
    echo ""
    echo -n -e "${muted}Enter recipient email address:${reset} "
    read email
    
    # 2. Email validation 
    if [ ! -f "./email" ]; then
        echo -e "${red}Email validator not found! Run 'gcc -o email email.c' first.${reset}"
        return
    fi
    
    if ! ./email "$email"; then
        echo -e "${red}Invalid email format!${reset}"
        return
    fi
    echo -e "${green}✓ Email format valid${reset}"

    # 3. Get subject
    echo ""
    echo -n -e "${muted}Enter email subject (default: System Report):${reset} "
    read subject
    if [ -z "$subject" ]; then
        subject="System Report"
    fi
    
    # 4. Get optional message
    echo ""
    echo -n -e "${muted}Enter additional message (optional, press Enter to skip):${reset} "
    read message
    
    # 5. Select report type
    echo ""
    echo -e "${primary}Select report to send:${reset}"
    echo -e "   ${secondary}1${reset}) Hardware Short Report"
    echo -e "   ${secondary}2${reset}) Hardware Detailed Report"
    echo -e "   ${secondary}3${reset}) Software Short Report"
    echo -e "   ${secondary}4${reset}) Software Detailed Report"
    echo -n -e "${secondary}Enter choice [1-4]:${reset} "
    read report_choice

    case $report_choice in
        1) REPORT_TYPE="hardware"; VERSION="short" ;;
        2) REPORT_TYPE="hardware"; VERSION="detailed" ;;
        3) REPORT_TYPE="software"; VERSION="short" ;;
        4) REPORT_TYPE="software"; VERSION="detailed" ;;
        *)
            echo -e "${red}Invalid choice!${reset}"
            return
            ;;
    esac
    
    # 6. Find reports directory
    REPORT_DIR="/var/log/sys_audit/$(hostname)/$(whoami)/$REPORT_TYPE/$VERSION"
    
    if [ ! -d "$REPORT_DIR" ]; then
        echo -e "${red}No $REPORT_TYPE $VERSION reports found!${reset}"
        return
    fi

    # 7. Get latest report or let user choose
    latest_report=$(ls -t "$REPORT_DIR"/*.txt 2>/dev/null | head -1)
    
    if [ -z "$latest_report" ]; then 
        echo -e "${red}No report found in $REPORT_DIR${reset}"
        return
    fi
    
    echo ""
    echo -e "${secondary}Latest report: $(basename "$latest_report")${reset}" 
    echo -n -e "${secondary}Send this report via email? [Y/n]:${reset} "
    read confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        # List all available reports
        echo ""
        echo -e "${primary}Available $REPORT_TYPE $VERSION reports:${reset}"
        files=()
        count=0
        for file in "$REPORT_DIR"/*.txt; do
            if [ -f "$file" ]; then
                count=$((count + 1))
                files+=("$file")
                echo "  $count) $(basename "$file")"
            fi
        done
        
        echo -n -e "${muted}Select report number [1-$count]:${reset} "
        read report_num
        
        if ! [[ "$report_num" =~ ^[0-9]+$ ]] || [ "$report_num" -lt 1 ] || [ "$report_num" -gt "$count" ]; then
            echo -e "${red}Invalid selection!${reset}"
            return
        fi
        REPORT_FILE="${files[$((report_num - 1))]}"
    else
        REPORT_FILE="$latest_report"
    fi

    # 8. Create clean version without color codes
    CLEAN_FILE="/tmp/report_clean.txt"
    sed 's/\x1b\[[0-9;]*m//g' "$REPORT_FILE" > "$CLEAN_FILE"
    echo "clear version created"
    
    # 9. Create PDF
    echo ""
    echo -e "${secondary}Creating PDF report...${reset}"
    
    PDF_FILE="/tmp/report.pdf"
    
    # Check if tools are installed
    if ! command -v enscript &> /dev/null; then
        echo -e "${red}enscript not installed! Run: sudo -A apt install enscript${reset}"
        return
    fi
    
    if ! command -v ps2pdf &> /dev/null; then
        echo -e "${red}ps2pdf not installed! Run: sudo -A apt install ghostscript${reset}"
        return
    fi
    echo "tools installed"
    
    # Convert to PDF
    enscript --output=/tmp/report.ps "$CLEAN_FILE" 2>/dev/null 
    if [ $? -ne 0 ]; then
        echo -e "${red}Failed to create PostScript file${reset}"
        return
    fi
    
    ps2pdf /tmp/report.ps "$PDF_FILE" 2>/dev/null
    if [ $? -ne 0 ] || [ ! -f "$PDF_FILE" ]; then
        echo -e "${red}Failed to create PDF file${reset}"
        rm -f /tmp/report.ps
        return
    fi
    cp "$PDF_FILE" /home/vboxuser5/ASDworkspace
    #cd /home/vboxuser5/ASDworkspace 
    #PDF_FILE=report.pdf

    rm -f /tmp/report.ps
    echo -e "${green}✓ PDF created: $(basename "$PDF_FILE") (size: $(du -h "$PDF_FILE" | cut -f1))${reset}"

    # 10. Prepare email body (short, report is attached)
    TEMP_EMAIL=$(mktemp)
    {
        echo "Subject: $subject"
        echo "To: $email"
        echo ""
        echo "$message"
        echo ""
        echo "----------------------------------------"
        echo "Report: $(basename "$REPORT_FILE")"
        echo "Generated on: $(date)"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo "----------------------------------------"
        echo ""
        echo "The full report is attached as a PDF file."
    } > "$TEMP_EMAIL"
    

    # 11. Send email with PDF attachment
    echo ""
    echo -e "${secondary}Sending email to $email...${reset}"
    
    SENT=0

     # Try msmtp (inline only)
    if command -v msmtp &> /dev/null && [ $SENT -eq 0 ]; then
        MSMTP_EMAIL=$(mktemp)
        {
            echo "Subject: $subject"
            echo "To: $email"
            echo ""
            echo "$message"
            echo ""
            echo "----------------------------------------"
            echo "Report: $(basename "$REPORT_FILE")"
            echo "Generated on: $(date)"
            echo "Hostname: $(hostname)"
            echo "User: $(whoami)"
            echo "----------------------------------------"
            echo ""
            echo "=== REPORT CONTENT ==="
            cat "$CLEAN_FILE"
        } > "$MSMTP_EMAIL"

        msmtp "$email" < "$MSMTP_EMAIL" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${yellow}Report sent as inline text via msmtp (attachment not supported)${reset}"
            SENT=1
        fi
        rm -f "$MSMTP_EMAIL"
    fi
    
    # Try mutt (best for attachments)
    if command -v mutt &> /dev/null && [ $SENT -eq 0 ]; then
        echo "$subject $PDF_FILE $email $TEMP_EMAIL"
        cat "$PDF_FILE" > report.pdf
        mutt -a report.pdf -s "$subject" -- "$email"

        if [ $? -eq 0 ]; then
            echo -e "${green}✓ Report sent as PDF attachment via mutt${reset}"
            SENT=1
        else
            echo -e "${red}Mutt failed to send${reset}"
        fi
    fi

    # Try mailx with attachment
    if command -v mailx &> /dev/null && [ $SENT -eq 0 ]; then
        mailx -s "$subject" -a "$PDF_FILE" "$email" < "$TEMP_EMAIL" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${green}✓ Report sent as PDF attachment via mailx${reset}"
            SENT=1
        else
            echo -e "${red}Mailx failed to send${reset}"
        fi
    fi
    
    # Try mail with attachment
    if command -v mail &> /dev/null && [ $SENT -eq 0 ]; then
        mail -s "$subject" -a "$PDF_FILE" "$email" < "$TEMP_EMAIL" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${green}✓ Report sent as PDF attachment via mail${reset}"
            SENT=1
        fi
    fi
    
    # Try sendmail with attachment (complex)
    if command -v sendmail &> /dev/null && [ $SENT -eq 0 ]; then
        # sendmail doesn't support attachments directly, fallback to inline
        SENDMAIL_EMAIL=$(mktemp)
        {
            echo "Subject: $subject"
            echo "To: $email"
            echo ""
            echo "$message"
            echo ""
            echo "----------------------------------------"
            echo "Report: $(basename "$REPORT_FILE")"
            echo "Generated on: $(date)"
            echo "Hostname: $(hostname)"
            echo "User: $(whoami)"
            echo "----------------------------------------"
            echo ""
            echo "=== REPORT CONTENT ==="
            cat "$CLEAN_FILE"
        } > "$SENDMAIL_EMAIL"
        
        sendmail "$email" < "$SENDMAIL_EMAIL" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${yellow}Report sent as inline text via sendmail (attachment not supported)${reset}"
            SENT=1
        fi
        rm -f "$SENDMAIL_EMAIL"
    fi
    
    # Try ssmtp (inline only)
    if command -v ssmtp &> /dev/null && [ $SENT -eq 0 ]; then
        SSMTP_EMAIL=$(mktemp)
        {
            echo "Subject: $subject"
            echo "To: $email"
            echo ""
            echo "$message"
            echo ""
            echo "----------------------------------------"
            echo "Report: $(basename "$REPORT_FILE")"
            echo "Generated on: $(date)"
            echo "Hostname: $(hostname)"
            echo "User: $(whoami)"
            echo "----------------------------------------"
            echo ""
            echo "=== REPORT CONTENT ==="
            cat "$CLEAN_FILE"
        } > "$SSMTP_EMAIL"
        
        ssmtp "$email" < "$SSMTP_EMAIL" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${yellow}Report sent as inline text via ssmtp (attachment not supported)${reset}"
            SENT=1
        fi
        rm -f "$SSMTP_EMAIL"
    fi
    
    # No email tool found
    if [ $SENT -eq 0 ]; then
        echo -e "${red}No email tool found!${reset}"
        echo -e "${secondary}Please install one of:${reset}"
        echo -e "  sudo -A apt install mutt          # for PDF attachments"
        echo -e "  sudo -A apt install mailutils     # for mail/mailx"
        echo -e "  sudo -A apt install msmtp         # for msmtp"
        echo -e "  sudo -A apt install sendmail      # for sendmail"
    fi
    
    # Clean up
    #rm -f "$TEMP_EMAIL" "$CLEAN_FILE" /tmp/report_*.ps 2>/dev/null || true
}

#============ CRON FUNCTIONS ============

setup_cron() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Setup Automatic Reports${reset}      "
    echo -e "${primary}==========================================${reset}"

    # 1. Ask user which report to schedule
    echo ""
    echo -e "${secondary}Which report do you want to run automatically?${reset}"
    echo -e "  ${cyan}1${reset}) Hardware Short Report"
    echo -e "  ${cyan}2${reset}) Hardware Detailed Report"
    echo -e "  ${cyan}3${reset}) Software Short Report"
    echo -e "  ${cyan}4${reset}) Software Detailed Report"
    echo -n -e "${secondary}Enter choice [1-4]:${reset} "
    read report_choice

    # 2. Set the script path based on user choice
    case $report_choice in
        1) script_to_run="$(pwd)/REPORTS_FOLDER/HARDWARE_INFO_SHORT.sh" ;;
        2) script_to_run="$(pwd)/REPORTS_FOLDER/HARDWARE_INFO.sh" ;;
        3) script_to_run="$(pwd)/REPORTS_FOLDER/SOFTWARE_INFO_SHORT.sh" ;;
        4) script_to_run="$(pwd)/REPORTS_FOLDER/SOFTWARE_INFO.sh" ;;
        *) 
            echo -e "${red}Invalid choice!${reset}"
            return
            ;;
    esac

    # 3. Check if the script exists
    if [ ! -f "$script_to_run" ]; then
        echo -e "${red}Error: Report script not found at $script_to_run${reset}"
        return
    fi

    echo ""
    echo -e "${secondary}Script to run automatically:${reset}"
    echo "  $script_to_run"
    echo ""

    # 4. Ask for schedule time
    echo -e "${secondary}When should this run? (24-hour format)${reset}"
    echo -n -e "${cyan}Hour (0-23) [default: 4]:${reset} "
    read hour
    if [ -z "$hour" ]; then
        hour=4
    fi

    echo -n -e "${cyan}Minute (0-59) [default: 0]:${reset} "
    read minute
    if [ -z "$minute" ]; then
        minute=0
    fi

    # 5. Validate
    if [ "$hour" -lt 0 ] || [ "$hour" -gt 23 ]; then
        echo -e "${red}Invalid hour. Please use 0-23.${reset}"
        return
    fi
    if [ "$minute" -lt 0 ] || [ "$minute" -gt 59 ]; then
        echo -e "${red}Invalid minute. Please use 0-59.${reset}"
        return
    fi

    echo ""
    echo -e "${secondary}This will run the report daily at ${hour}:${minute}${reset}"
    echo -n -e "${secondary}Install this cron job? [y/N]:${reset} "
    read confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Add the cron job
        ( crontab -l 2>/dev/null; echo "$minute $hour * * * $script_to_run") | crontab -
        echo -e "${green}✓ Cron job installed successfully!${reset}"
    else
        echo -e "${yellow}Setup cancelled.${reset}"
    fi
}

view_cron() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Current Scheduled Reports${reset}      "
    echo -e "${primary}==========================================${reset}"
    echo ""
    
    # Check if there are any cron jobs
    if crontab -l 2>/dev/null; then
        echo ""
        echo -e "${green}✓ Above are your current cron jobs${reset}"
    else
        echo -e "${yellow}No cron jobs are currently scheduled${reset}"
    fi
    echo ""
}

remove_cron() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Remove Scheduled Reports${reset}      "
    echo -e "${primary}==========================================${reset}"
    echo ""
    
    # Show current jobs first
    echo -e "${secondary}Current scheduled reports:${reset}"
    if ! crontab -l 2>/dev/null; then
        echo -e "${yellow}No cron jobs found${reset}"
        return
    fi
    
    echo ""
    echo -e "${red}WARNING: This will remove ALL your cron jobs${reset}"
    echo -n -e "${secondary}Are you sure? [y/N]:${reset} "
    read confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Keep only lines with SUDO_ASKPASS
        crontab -l 2>/dev/null | grep -E "^(PATH=|SUDO_ASKPASS=)" | crontab -
        echo -e "${green}✓ All cron jobs have been removed${reset}"
    else
        echo -e "${yellow}Operation cancelled${reset}"
    fi
    echo ""
}

automation_menu(){
    echo ""
    echo -e "${cyan}1) Setup automatic report${reset}"
    echo -e "${cyan}2) View scheduled reports${reset}"
    echo -e "${cyan}3) Remove all scheduled reports${reset}"
    echo -e "${cyan}4) Back to main menu${reset}"
    echo -n -e "${cyan}Enter choice [1-4]:${reset} "
    read cron_choice
    
    case $cron_choice in
        1) setup_cron ;;
        2) view_cron ;;
        3) remove_cron ;;
        4) continue ;;
        *) echo -e "${red}Invalid choice${reset}" ;;
    esac
}


add_remote_machine() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Add Remote Machine${reset}      "
    echo -e "${primary}==========================================${reset}"
    # scan the info of the remote machine like user_name machine_name ...
    echo -n -e "${cyan}Remote machine name (e.g., server1):${reset} "
    read machine_name
    echo -n -e "${cyan}Remote username:${reset} "
    read remote_user
    echo -n -e "${cyan}Remote port [default: 22]:${reset} "
    read remote_port
    [ -z "$remote_port" ] && remote_port=22
    echo -n -e "${cyan}Remote script path:${reset} "
    read remote_script
    
    #add the machine to the group 
    sudo usermod -aG reportgroup "$remote_user"
    echo -e "$remote_user is added to reportgroup"

    # Save configuration
    echo "$machine_name|$remote_user|$remote_port|$remote_script" >> "$REMOTE_CONFIG"
}

list_remote_machines() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Remote Machines${reset}      "
    echo -e "${primary}==========================================${reset}"
    
    #special case if there is no remote machine
    if [ ! -f "$REMOTE_CONFIG" ]; then
        echo -e "${yellow}No remote machines configured${reset}"
        return
    fi
    
    echo ""
    echo "ID | Name | User | Port | Script"
    echo "---|------|------|------|-------"
    
    #list all the available remote machines
    id=1
    # ifs =internal fiel separator a built in variable in shell
    while IFS='|' read -r name user port script; do
        echo "$id | $name | $user | $port | $script"
        id=$((id + 1))
    done < "$REMOTE_CONFIG"
    echo ""
}

delete_remote_machine() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Delete Remote Machine${reset}      "
    echo -e "${primary}==========================================${reset}"
    
    list_remote_machines
    
    if [ ! -f "$REMOTE_CONFIG" ]; then
        return
    fi
    
    echo -n -e "${cyan}Enter machine ID to delete:${reset} "
    read machine_id
    
    # Delete the selected line
    sed -i "${machine_id}d" "$REMOTE_CONFIG" 2>/dev/null
    echo -e "${green}✓ Remote machine deleted${reset}"
}

setup_remote_cron() {
    echo -e "${primary}=========================================="
    echo -e "       ${bold}Setup Automatic Remote Monitoring${reset}      "
    echo -e "${primary}==========================================${reset}"
    
    # List remote machines
    list_remote_machines
    
    if [ ! -f "$REMOTE_CONFIG" ]; then
        return
    fi
    
    echo -n -e "${cyan}Enter machine ID to schedule:${reset} "
    read machine_id
    
    # Get remote machine details
    line=$(sed -n "${machine_id}p" "$REMOTE_CONFIG")
    IFS='|' read -r name user port script <<< "$line"
    
    # Ask for schedule time
    echo ""
    echo -n -e "${cyan}Hour (0-23) [default: 4]:${reset} "
    read hour
    [ -z "$hour" ] && hour=4
    echo -n -e "${cyan}Minute (0-59) [default: 0]:${reset} "
    read minute
    [ -z "$minute" ] && minute=0
    
    # Copy project to remote machine (first time setup)
    echo ""
    echo -e "${secondary}Copying project to remote machine $name...${reset}"
    sudo -A scp -r /home/vboxuser5/ASDworkspace "$user@$name:/home/$user/"
    
    if [ $? -eq 0 ]; then
        echo -e "${green}✓ Project copied to $name${reset}"
    else
        echo -e "${red}Failed to copy project to $name${reset}"
        return
    fi
    
    # Create wrapper script
    WRAPPER="/home/vboxuser5/ASDworkspace/remote_${name}.sh"
    
    cat > "$WRAPPER" << EOF
#!/bin/zsh
# Remote report for $name

# Run the remote script
ssh -p $port $user@$name "/home/$user/ASDworkspace/REPORTS_FOLDER/HARDWARE_INFO_SHORT.sh"

# Get the latest report from remote
LATEST=\$(ssh -p $port $user@$name "ls -t /var/log/sys_audit/*/hardware/short/*.txt 2>/dev/null | head -1")

if [ -n "\$LATEST" ]; then
    # Copy report back to local machine (ubuntu2)
    scp -P $port $user@$name:"\$LATEST" /home/vboxuser5/remote_reports/report_${name}_\$(date +%Y%m%d_%H%M%S).txt
    echo "Report from $name saved to /home/vboxuser5/remote_reports/" >> /tmp/remote_${name}.log
fi
EOF
    
    chmod +x "$WRAPPER"
    
    # Create local reports directory
    mkdir -p /home/vboxuser5/remote_reports
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$minute $hour * * * $WRAPPER") | crontab -
    
    echo ""
    echo -e "${green}✓ Remote monitoring scheduled for $name at $hour:$minute${reset}"
    echo -e "${secondary}Reports will be saved to: /home/vboxuser5/remote_reports/${reset}"
}

remote_monitoring_menu() {
    while true; do
        echo -e "${primary}=========================================="
        echo -e "       ${bold}Remote Monitoring${reset}      "
        echo -e "${primary}==========================================${reset}"
        echo -e "  ${cyan}1${reset}) Add remote machine"
        echo -e "  ${cyan}2${reset}) List remote machines"
        echo -e "  ${cyan}3${reset}) Delete remote machine"
        echo -e "  ${cyan}4${reset}) Setup automatic remote monitoring (cron)"
        echo -e "  ${cyan}5(${reset}) Back to main menu"
        echo -e "${primary}==========================================${reset}"
        echo -n -e "${secondary}Enter choice [1-6]:${reset} "
        read remote_choice
        
        case $remote_choice in
            1) add_remote_machine ;;
            2) list_remote_machines ;;
            3) delete_remote_machine ;;
            4) setup_remote_cron ;;
            5) break ;;
            *) echo -e "${red}Invalid choice${reset}" ;;
        esac
        echo ""
        echo -e "${cyan}Press Enter to continue...${reset}"
        read dummy
    done
}

send_via_email_auto() {
    local email="$1"
    local subject="$2"
    local message="$3"
    local report_type="$4"   # 1=Hardware Short, 2=Hardware Detailed, 3=Software Short, 4=Software Detailed

    case $report_type in
        1) REPORT_TYPE="hardware"; VERSION="short" ;;
        2) REPORT_TYPE="hardware"; VERSION="detailed" ;;
        3) REPORT_TYPE="software"; VERSION="short" ;;
        4) REPORT_TYPE="software"; VERSION="detailed" ;;
        *) echo "Invalid report type!"; return ;;
    esac

    REPORT_DIR="/var/log/sys_audit/$(hostname)/$(whoami)/$REPORT_TYPE/$VERSION"
    REPORT_FILE=$(ls -t "$REPORT_DIR"/*.txt 2>/dev/null | head -1)

    if [ -z "$REPORT_FILE" ]; then
        echo "No report found!"
        return
    fi

    # Remove ANSI color codes for clean email
    CLEAN_FILE="/tmp/report_clean.txt"
    sed 's/\x1b\[[0-9;]*m//g' "$REPORT_FILE" > "$CLEAN_FILE"

    # Send email with msmtp (inline content, no attachment)
    {
        echo "Subject: $subject"
        echo "To: $email"
        echo ""
        echo "$message"
        echo ""
        echo "----------------------------------------"
        echo "Report: $(basename "$REPORT_FILE")"
        echo "Generated on: $(date)"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo "----------------------------------------"
        echo ""
        echo "=== REPORT CONTENT ==="
        cat "$CLEAN_FILE"
    } | msmtp "$email"

    if [ $? -eq 0 ]; then
        echo "✓ Report sent to $email"
    else
        echo "Failed to send email"
    fi

    rm -f "$CLEAN_FILE"
}