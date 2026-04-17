# README OF OS PROJECT PART ONE

## 1. PROJECT OVERVIEW

This project is a Linux‑based automated audit solution designed for the Operating Systems course at the National School of Cybersecurity.  
It collects complete hardware and software information from a Linux machine, generates both short (non‑detailed) and full (detailed) reports, and provides advanced features such as email transmission, cron automation, and remote monitoring via SSH.

## Main capabilities:
- Hardware audit (CPU, RAM, storage, GPU, network, USB, motherboard, BIOS)
- Software audit (OS, kernel, users, processes, services, ports, packages)
- Two report levels: short (concise) and full (complete technical data)
- Automatic saving to a dedicated log directory
- Email sending with PDF attachment (using mutt / msmtp)
- Manual and automatic report saving
- Cron job scheduling for daily execution
- Remote monitoring (SSH to remote machines + SCP report retrieval)

## 2. PROJECT STRUCTURE
# ASDworkspace/
│
├── main.sh                              # Main menu – entry point
├── colors.sh                            # Colour definitions for terminal output
├── email.c                              # C source code for email validation
├── email                                # Compiled email validator
├── askpass.sh                           # Password helper for sudo in cron
│
├── FUNCTION_FOLDER/                     # All function libraries
│   ├── hardware_functions.sh            # Hardware audit functions (70+)
│   ├── software_functions.sh            # Software audit functions
│   └── menu_functions.sh                # Menu display and utility functions
│
├── REPORTS_FOLDER/                      # Report generation scripts
│   ├── HARDWARE_INFO_SHORT.sh           # Hardware short report
│   ├── HARDWARE_INFO.sh                 # Hardware detailed report
│   ├── SOFTWARE_INFO_SHORT.sh           # Software short report
│   └── SOFTWARE_INFO.sh                 # Software detailed report
│
├── saved_reports/                       # Reports saved manually by the user
├── remote_reports/                      # Reports retrieved from remote machines
└── EXAMPLE REPORT                       # Report generated as an example 

## 3. INSTALLATION

# Prerequisites
- Linux distribution (Ubuntu 20.04+, Kali Linux, or Arch WSL)
- `zsh` or `bash` shell
- `sudo` privileges

# Step‑by‑step installation
 bash
# 1. Place the project in your workspace
cd /home/yourusername/
cp -r ASDworkspace /your/target/location/
cd ASDworkspace

# 2. Make all scripts executable
chmod +x *.sh
chmod +x FUNCTION_FOLDER/*.sh
chmod +x REPORTS_FOLDER/*.sh

# 3. Install required packages
sudo apt update
sudo apt install -y mutt msmtp msmtp-mta enscript ghostscript mailutils openssh-server

# 4. Compile the email validator
gcc -o email email.c
chmod +x email

# 5. (Optional) Create a password helper for cron
echo '#!/bin/bash' > ~/askpass.sh
echo 'echo "YOUR_SUDO_PASSWORD"' >> ~/askpass.sh
chmod 700 ~/askpass.sh

## CONFIGURATION

# Email (msmtp)

Create ~/.msmtprc: ## for configurating msmtp command 
# bash  in terminal write : 
cat > ~/.msmtprc << 'EOF'
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account        gmail
host           smtp.gmail.com
port           587
from           YOUR-EMAIL@gmail.com
user           YOUR-EMAIL@gmail.com
password       YOUR-APP-PASSWORD

account default : gmail
EOF

chmod 600 ~/.msmtprc



# Important: Use a Gmail App Password (not your regular password). Generate it from Google Account → Security → App Passwords.

## Mutt (for PDF attachments)

Create ~/.muttrc:

bash
cat > ~/.muttrc << 'EOF'
set sendmail = "/usr/bin/msmtp"
set use_from = yes
set realname = "Your Name"
set from = "YOUR-EMAIL@gmail.com"
set envelope_from = yes
EOF

# Cron password helper (optional)

# If you keep sudo inside the scripts, the askpass.sh file must be executable and contain your sudo password.

Add the following line to your crontab (with crontab -e):
SUDO_ASKPASS=/home/yourusername/askpass.sh

# HOW TO RUN

you have two choices :
1_install the code runner extension and click the "run code" button 
2_using terminal : ./main.sh


# HOW TO NAVIGATE THOUGH THE MAIN INTERACTIVE MENU 
Navigate by typing the number of the desired option and pressing Enter.

# MENU OPTIONS

## Option Description
1 Generate Reports (hardware / software, short / detailed)
2 Save an existing report to a custom location
3 Send a report by email (as PDF attachment)
4 Automate report generation with cron
5 Remote monitoring (SSH to other machines)
6 Exit the program

# LOGS AND SAVED REPORTS

## Auto‑saved reports
Every generated report is automatically saved to:

/var/log/sys_audit/$(hostname)/$(whoami)/
├── hardware/
│   ├── short/
│   │   └── report_hardware_short_YYYYMMDD_HHMMSS.txt
│   └── detailed/
│       └── report_hardware_detailed_YYYYMMDD_HHMMSS.txt
└── software/
    ├── short/
    │   └── report_software_short_YYYYMMDD_HHMMSS.txt
    └── detailed/
        └── report_software_detailed_YYYYMMDD_HHMMSS.txt


## Manually saved reports
Reports copied through the Save Report to File option are stored in:
./saved_reports/
## Remote reports
Reports fetched from remote machines are stored in:
./remote_reports/

# AUTOMATION (CRON)
From the main menu, select Option 4 to:
## Setup automatic report – choose the report type, hour and minute.
    The script automatically installs a cron job.
## View scheduled reports – displays the current user’s crontab.
## Remove scheduled reports – deletes all cron jobs for the current user.
Example cron entry (daily at 4:30 AM):
30 4 * * * /home/username/ASDworkspace/REPORTS_FOLDER/HARDWARE_INFO_SHORT.sh
## REMOTE MONITORING

The remote monitoring feature allows you to execute the audit script on another Linux machine and retrieve the generated report.

How it works

1. Add a remote machine (hostname, username, SSH port, path to the remote script).
2. The script connects via SSH, runs the remote report, and copies the result back.
3. Execution can be manual or scheduled via cron.

SSH key setup (recommended for passwordless operation)
ssh-keygen -t rsa -b 4096
ssh user@remote_host

Shared report directory
All retrieved reports are stored locally in:  /home/username/remote_reports/

 ## TROUBLESHOOTING

Issue Solution
Email not sending Verify ~/.msmtprc contents and that the Gmail App Password is correct.
Mutt opens an interactive screen Use sendmail or msmtp directly; add < /dev/null to the mutt command.
Cron job does not run Check crontab -l and ensure the cron service is active: sudo systemctl status cron.
Permission denied for log directory Run sudo chown -R $USER:$USER /var/log/sys_audit/.
sudo asks for a password inside cron Create askpass.sh and set SUDO_ASKPASS in the crontab, or use sudo crontab -e.
SSH connection refused Install the SSH server: sudo apt install openssh-server.
dmidecode fails in cron Use the askpass helper or run the cron job with sudo crontab -e.

Useful log files
# Cron logs
sudo grep CRON /var/log/syslog | tail -20

# Email logs (msmtp)
cat ~/.msmtp.log

# Remote monitoring debug logs
cat /tmp/remote_*.log
## DEPENDENCIES

Package Purpose
mutt sending emails with PDF attachments
msmtp lightweight SMTP client
enscript text → PostScript conversion
ghostscript PostScript → PDF conversion
mailutils provides the mail command
openssh-server enables SSH remote access

Install all at once:

sudo apt install mutt msmtp msmtp-mta enscript ghostscript mailutils openssh-server

  Hardware report development – [Zouani Hiba Ghada]
  Software report development – [Radjah Ritadj]

Course: Operating Systems (OS2)
Institution: National School of Cybersecurity