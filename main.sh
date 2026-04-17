#!/bin/zsh
#the main menu 
cd /home/vboxuser5/ASDworkspace || exit 1
#========================================
#        including all files needed 

for file in ./FUNCTION_FOLDER/*.sh; do source "$file";done

#================================================================
#        calling the menu functions and starting the menu 

while true; do
show_menu
read menu_choice 

    case $menu_choice in 
    1)
    # generating the reports
        while true; do 
            echo -e " Generate Reports "
            report_menu
            read report_menu_choice
            case $report_menu_choice in
            1)
                while true; do 
                    echo -e "Generate hardware reports"
                    hardware_menu
                    read hardware_menu_choice
                    case $hardware_menu_choice in
                        1)
                        # generating detailed hardware report
                            ./REPORTS_FOLDER/HARDWARE_INFO.sh
                        ;;
                        2)
                        # generate short hardware report
                            ./REPORTS_FOLDER/HARDWARE_INFO_SHORT.sh
                        ;;
                        3)
                            echo -e "returning to the report menu"
                            break
                        ;;
                        4)
                            echo -e "returning to the main menu"
                            break 2
                        ;;
                        *)
                            echo -e "Invalid choice. Repeate again."
                        ;;

                    esac

                done
            ;;
            2)  
                while true; do 
                    echo -e "Generate software reports"
                    software_menu
                    read software_menu_choice
                    case $software_menu_choice in
                        1)
                        # generate detailed software report
                            ./REPORTS_FOLDER/SOFTWARE_INFO.sh 
                        ;;
                        2)
                        # generate short software report 
                            ./REPORTS_FOLDER/SOFTWARE_INFO_SHORT.sh 
                        ;;
                        3)
                            echo -e "returning to the report menu"
                            break
                        ;;
                        4)
                            echo -e "returning to the main menu"
                            break 2
                        ;;
                        *)
                            echo -e "Invalid choice. Repeate again."
                        ;;

                    esac

                done
            ;;
            3)
                break
            ;;
            *)
                echo -e "Invalid choice. Repeate again."
            ;;
            esac
        done
    ;;
    2)
        # manual save of reports to saving_dir
        manual_save
    ;;
    3)
    # sending saved report via email
        send_via_email
    ;;
    4)
    # automating the execution 
        automation_menu
    ;;
    5)
    # remote accessing 
        remote_monitoring_menu
    ;;
    6)
    # exiting the program
        exit
    ;;
    *)
        echo -e "Invalid choice. Repeate again."
    ;;
    esac



done