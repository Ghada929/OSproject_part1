#!/bin/zsh
#=====================================
#      HARDWARE REPORT FUNCTIONS      
#==================================================
#========FUNCTIONS OF THE NON DETAILED INFO========

cpu_info(){
    echo "CPU Model name : $(lscpu | grep -i "model name" | cut -d: -f2 | xargs)"
    echo "Architecture : $(uname -m)"
    echo "Total CPU cores : $(nproc)"
}

memory_info(){
    echo "Total memory : $(free -gh | grep -i "mem" | xargs | cut -d' ' -f2)"
    echo "Available memory : $(free -gh | grep -i "mem" | xargs | cut -d' ' -f7)"
}

storage_info(){
    echo "Disk(s) size : $(lsblk | grep -i "disk" | awk '{print $4}')"
    df -hT  | grep -i "^/dev/" | while read VARline; do
        PARTITION=$(echo $VARline | awk '{print $1}') 
        USED=$(echo $VARline | awk '{print $4}')
        PERCENT=$(echo $VARline | awk '{print $6}')
        TYPE=$(echo $VARline | awk '{print $2}')
        echo "Disk partitions : $PARTITION ,type : $TYPE , usage : $USED , percentage : $PERCENT"
    done
}

graphic_info(){
    echo "GPU model : $(lspci | grep -E "VGA|3D|Display" | cut -d: -f3 | xargs)"
}

network_info(){
    ip -4 address show | grep -E "^[0-9]" | while read line; do
    INTERFACE=$(echo $line | awk '{print $2}' | sed 's/://g')
    IP=$(ip addr show $INTERFACE| grep -i "inet " | awk '{print $2}')
    if [ "$INTERFACE" != "lo" ];then 
        MAC=$(ip addr show $INTERFACE | grep -i "link/ether" | awk '{print $2}')
    else 
        MAC="00:00:00:00:00:00"
    fi 
    echo "Interface: $INTERFACE, IPv4: $IP, MAC: $MAC"
done
}

motherboard_info(){
    echo "Motherboard information :"
    echo "Manufacturer: $(sudo -A dmidecode -s baseboard-manufacturer)"
    echo "Product Name: $(sudo -A dmidecode -s baseboard-product-name)"
    echo "System Manufacturer: $(sudo -A dmidecode -s system-manufacturer)"
    echo "System Product: $(sudo -A dmidecode -s system-product-name)"
}

usb_device_info(){
    lsusb | while read lines; do 
        echo $lines | cut -d' ' -f7-
    done
}

#========FUNCTIONS OF THE DETAILED INFO========
   
#========cpu functions==========
get_cpu_vendor(){
    echo "CPU vendor : $(lscpu | grep -i "vendor id" | cut -d: -f2 | xargs)"
}

get_cpu_socket_count(){
    echo "CPU Socket count : $(lscpu | grep -i "socket(s)" | cut -d: -f2 | xargs)"
}

get_cpu_cores_per_socket(){
    echo "Cores per socket : $(lscpu | grep -i "socket:" | cut -d: -f2 | xargs)"
}
get_cpu_threads_per_core(){
    lscpu  |  grep -i "thread" | cut -d: -f2 | xargs
}

get_current_cpu_speed(){
    cat /proc/cpuinfo | grep -i processor | while read speed_line; do 
    PROCESSOR_NAME=$(echo "$speed_line" |cut -d: -f2 | xargs)
    n_line=0
    SPEED=$( cat /proc/cpuinfo | grep -i mhz | while read speed_val; do 
        if [[ "$n_line" = "$PROCESSOR_NAME" ]]; then
            echo "$speed_val" | cut -d: -f2 | xargs 
            break
        fi
        ((n_line++))
    done
    )
    echo "Processor id : $PROCESSOR_NAME , speed : $SPEED"
    done
}

get_cpu_max_speed(){
    echo "CPU max speed: $(lscpu | grep -i "max mhz" || echo "This info is not available in your machine")"
}

get_cpu_min_speed(){
    echo "CPU min speed: $(lscpu | grep -i "min mhz" || echo "This info is not available in your machine")"
}

get_cpu_flags(){
    lscpu | grep -i flags | xargs
}

get_cpu_vulnerabilities(){
    echo "CPU vulnerabilities:"
    for file in /sys/devices/system/cpu/vulnerabilities/*; do
    name=$(basename "$file")
    stat=$( cat "$file" 2>/dev/null || echo "unable to read")
    echo "  $name : $stat"
    
    done
}

get_cpu_family(){
   echo  "CPU family : $(lscpu | grep -i "cpu family" | cut -d: -f2 | xargs) "
}

get_cpu_model(){
    echo "CPU model: $(lscpu | grep -i "model:" | cut -d: -f2 | xargs)"
}

get_cpu_stepping(){
    echo "CPU stepping : $(lscpu | grep -i stepping | cut -d: -f2 | xargs)"
}

get_cpu_cache(){
    if lscpu --caches 2>/dev/null | grep -q "L1d"; then 
    echo -e "CPU cache : \n$(lscpu --caches | while read line; do 
    name=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    type=$(echo "$line" | awk '{print $5}')
    echo "  $name ($type) $size"
    done)"

    else 
    cache=$(cat /proc/cpuinfo | grep "cache size" | head -1 | cut -d: -f2 | xargs)
        if [ -n "$cache" ]; then
            echo "CPU cache : $cache"
        else
            echo "CPU cache : not available in this environment"
        fi
    fi
}

#============memory info=================
get_used_memory(){
    echo "Used memory : $(free -h | grep -i mem | xargs | cut -d" " -f3)"
}

get_total_swap(){
    echo "Total swap : $(free -h | grep -i swap | xargs | cut -d" " -f2)"
}

get_used_swap(){
    echo "Used swap : $(free -h | grep -i swap | xargs | cut -d" " -f3)"
}

get_memory_type(){
    TYPE=$(sudo -A dmidecode -t memory 2>/dev/null | grep "Type:" | grep -v "Unknown" | head -1 | cut -d: -f2 | xargs)
    if [ -n "$TYPE" ]; then
        echo "$TYPE"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_speed(){
    SPEED=$(sudo -A dmidecode -t memory 2>/dev/null | grep "Speed:" | grep -v "Unknown" | head -1 | cut -d: -f2 | xargs)
    if [ -n "$SPEED" ]; then
        echo "$SPEED MHz"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_slots_total(){
    SLOTS=$(sudo -A dmidecode -t memory 2>/dev/null | grep "Number Of Devices" | cut -d: -f2 | xargs)
    if [ -n "$SLOTS" ]; then
        echo "$SLOTS"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_slots_used(){
    USED=$(sudo -A dmidecode -t memory 2>/dev/null | grep -c "Size: [0-9]")
    if [ "$USED" -gt 0 ]; then
        echo "$USED"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_manufacturer(){
    MANUF=$(sudo -A dmidecode -t memory 2>/dev/null | grep "Manufacturer:" | grep -v "Not Specified" | head -1 | cut -d: -f2 | xargs)
    if [ -n "$MANUF" ]; then
        echo "$MANUF"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_form_factor(){
    FORM=$(sudo -A dmidecode -t memory 2>/dev/null | grep "Form Factor:" | head -1 | cut -d: -f2 | xargs)
    if [ -n "$FORM" ]; then
        echo "$FORM"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_max_capacity(){
    MAX=$(sudo -A dmidecode -t memory 2>/dev/null | grep "Maximum Capacity" | head -1 | cut -d: -f2 | xargs)
    if [ -n "$MAX" ]; then
        echo "$MAX"
    else
        echo "Not available (virtualized environment)"
    fi
}

get_memory_details(){
    echo "Individual RAM Sticks:"
    DETAILS=$(sudo -A dmidecode -t memory 2>/dev/null | grep -E "Size:|Locator:|Speed:|Manufacturer:|Part Number" | head -20)
    if [ -n "$DETAILS" ]; then
        echo "$DETAILS" | while read line; do
            echo "  $line"
        done
    else
        echo "  Not available (virtualized environment)"
    fi
}


#=============storage functions================

get_name_model_size(){
    lsblk -d -o NAME,MODEL,SIZE,TYPE,ROTA,TRAN,VENDOR,SERIAL| grep -i disk | while read line; do
    name=$( echo "$line" | awk '{print $1}' ) 
    model=$(echo "$line" | awk '{for(i=2;i<(NF-5);i++) printf "%s " ,$i}')
    size=$(echo "$line" | awk '{print $(NF-5)}')
    type=$(echo "$line" | awk '{print $(NF-4)}')
    type_disk=$(echo "$line" | awk '{print $(NF-3)}')
    tran=$(echo "$line" | awk '{print $(NF-2)}')
    vendor=$(echo "$line" | awk '{print $(NF-1)}')
    serial=$(echo "$line" | awk '{print $NF}')

    if [ "$type_disk" = "0" ]; then
    ty="SSD"
    else
        if [ "$type_disk" = "1" ]; then
        ty="HDD"
        else
        echo "thee is no type "
        fi
    fi    
    echo "Disk name: $name "
    echo "Model: $model "
    echo "Size: $size "
    echo "Type: $type_disk"
    echo "Interface: $tran"
    echo "Vendor: $vendor"
    echo "Serial: $serial"
    done
}

get_partitions_detailed(){
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID| grep -i part | sed 's/[└─├─]//g'| while read line; do
    name=$( echo "$line" | awk '{print $1}') 
    size=$( echo "$line" | awk '{print $2}')
    mountpoint=$(echo "$line" | awk '{print $4}')
    filesystem=$(echo "$line" | awk '{print $5}')
    UUID=$(echo "$line" | awk '{print $6}')

    echo "Disk name: $name "
    echo "  Size: $size "
    echo "  Filesystem: $filesystem"
    echo "  Mount Point: $mountpoint"
    echo "  UUID: $UUID"
    done
}


#============graphics functions=============
get_gpu_vendor(){
    echo "GPU Vendor: $(lspci | grep -E "VGA|3D|Display" | cut -d: -f3 | awk '{print $1}' | xargs)"
}

get_gpu_driver(){
    echo "GPU Driver: $(lspci -k | grep -A 2 -E "VGA|3D|Display" | grep -i "kernel driver" | cut -d: -f2 | xargs)"
}

get_gpu_memory(){
    MEM=$(lspci -v | grep -A 10 -E "VGA|3D|Display" | grep -i "memory at" | head -1 | grep -o "size=[0-9]*[A-Z]" | cut -d= -f2)
    if [ -n "$MEM" ]; then
    echo "GPU Memory (VRAM): $MEM" 
    else
    echo "GPU Memory (VRAM): not available (virtualized environment) "
    fi
}

get_gpu_count(){
    echo "GPU Count: $(lspci | grep -c -E "VGA|3D|Display")"
}

get_gpu_temperature(){
    if command -v nvidia-smi &> /dev/null; then
        TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null)
        echo "GPU Temperature: ${TEMP}°C"
    elif command -v sensors &> /dev/null; then
        TEMP=$(sensors | grep -i "gpu" | head -1 | awk '{print $3}')
        if [ -n "$TEMP" ]; then
        echo "GPU Temperature: $TEMP"
        else 
        echo "GPU Temperature: Not available"
        fi
    else
        echo "GPU Temperature: Not available"
    fi
}


#===================NETWORK HARDWARE FUNCTIONS=======================
get_network_card(){
    echo "Network model(s):\n$(lspci | grep -i ethernet | cut -d: -f3-)"
}

get_network_hardware(){
    echo "Network hardware: "
    lspci | grep -i "ethernet\|network" | while read line; do
        echo " $line"
    done
}

get_network_driver(){
    DRIVER=$(lspci -k | grep -A 2 -i "ethernet\|network" | grep -i "kernel driver" | cut -d: -f2-)
    echo "Network driver(s):\n$DRIVER"
}
get_network_count(){
    count=$(lspci | grep -c -i "ethernet\|network")
    echo "Network cards count: $count"
}

get_link_speed(){
    echo "Link Information:"
    ip -br link show | grep -v "lo" | while read line; do
        IFACE=$(echo "$line" | awk '{print $1}')
        if [ -n "$IFACE" ]; then
            if command -v ethtool &> /dev/null; then
                SPEED=$(ethtool $IFACE 2>/dev/null | grep "Speed:" | awk '{print $2}')
                DUPLEX=$(ethtool $IFACE 2>/dev/null | grep "Duplex:" | awk '{print $2}')
                LINK=$(ethtool $IFACE 2>/dev/null | grep "Link detected:" | awk '{print $3}')
                
                if [ -n "$SPEED" ] || [ -n "$LINK" ]; then
                    echo "  $IFACE: Speed=$SPEED, Duplex=$DUPLEX, Link=$LINK"
                else
                    echo "  $IFACE: Link info not available"
                fi
            else
                echo "  ethtool not installed (install for link speed info)"
                break
            fi
        fi
    done
}


#==================USB FUNCTIONS======================
get_usb_controllers(){
    echo "USB Controllers:"
    lspci | grep -i usb | while read line; do
        echo "  $line"
    done
}

get_usb_tree(){
    echo "USB Device Tree:"
    lsusb -t 2>/dev/null | while read line; do
        echo "  $line"
    done
}

get_usb_details(){
    echo "USB Device Details:"
    lsusb -v 2>/dev/null | grep -E "idVendor|idProduct|iProduct|bcdUSB|bMaxPower" | head -20 | while read line; do
        echo "  $line"
    done
}

get_usb_speeds(){
    echo "USB Device Speeds:"
    OUTPUT=$(lsusb -t 2>/dev/null | grep -E "[0-9]+M")
    if [ -n "$OUTPUT" ]; then
        echo "$OUTPUT" | while read line; do
            echo "  $line"
        done
    else
        echo "  Not available"
    fi
}

get_usb_serial(){
    echo "USB Serial Numbers:"
    for dev in /sys/bus/usb/devices/*/serial; do
        if [ -f "$dev" ]; then
            DEVICE=$(basename $(dirname "$dev"))
            SERIAL=$(cat "$dev" 2>/dev/null)
            echo "  $DEVICE: $SERIAL"
        fi
    done
}

get_usb_manufacturer(){
    echo "USB Manufacturers:"
    for dev in /sys/bus/usb/devices/*/manufacturer; do
        if [ -f "$dev" ]; then
            DEVICE=$(basename $(dirname "$dev"))
            MANUF=$(cat "$dev" 2>/dev/null)
            echo "  $DEVICE: $MANUF"
        fi
    done
}

get_usb_product(){
    echo "USB Products:"
    for dev in /sys/bus/usb/devices/*/product; do
        if [ -f "$dev" ]; then
            DEVICE=$(basename $(dirname "$dev"))
            PRODUCT=$(cat "$dev" 2>/dev/null)
            echo "  $DEVICE: $PRODUCT"
        fi
    done
}

get_usb_count(){
    COUNT=$(lsusb | wc -l)
    echo "USB Devices Count: $COUNT"
}


#==============MOTHERBOARD FUNCTIONS=============
get_motherboard_serial(){
    echo "Motherboard Serial: $(sudo -A dmidecode -s baseboard-serial-number 2>/dev/null || echo "Not available")"
}

get_motherboard_version(){
    echo "Motherboard Version: $(sudo -A dmidecode -s baseboard-version 2>/dev/null || echo "Not available")"
}

get_chipset(){
    echo "Chipset: $(lspci | grep "Host bridge" | cut -d: -f3- | xargs || echo "Not available")"
}

get_southbridge(){
    echo "Southbridge: $(lspci | grep "ISA bridge" | cut -d: -f3- | xargs || echo "Not available")"
}


get_sata_controller(){
    echo "SATA Controller: $(lspci | grep "SATA" | cut -d: -f3- | xargs || echo "Not available")"
}


get_audio_controller(){
    echo "Audio Controller: $(lspci | grep "Audio" | cut -d: -f3- || echo "Not available")"
}

#============BIOS / UEFI / FIRMWARE FUNCTIONS=============

get_bios_vendor(){
    VENDOR=$(sudo -A dmidecode -s bios-vendor 2>/dev/null)
    if [ -n "$VENDOR" ]; then
        echo "BIOS Vendor: $VENDOR"
    else
        echo "BIOS Vendor: Not available"
    fi
}

get_bios_version(){
    VERSION=$(sudo -A dmidecode -s bios-version 2>/dev/null)
    if [ -n "$VERSION" ]; then
        echo "BIOS Version: $VERSION"
    else
        echo "BIOS Version: Not available"
    fi
}

get_bios_date(){
    DATE=$(sudo -A dmidecode -s bios-release-date 2>/dev/null)
    if [ -n "$DATE" ]; then
        echo "BIOS Release Date: $DATE"
    else
        echo "BIOS Release Date: Not available"
    fi
}

get_bios_revision(){
    REV=$(sudo -A dmidecode -t bios 2>/dev/null | grep "BIOS Revision" | cut -d: -f2 | xargs)
    if [ -n "$REV" ]; then
        echo "BIOS Revision: $REV"
    else
        echo "BIOS Revision: Not available"
    fi
}

get_firmware_revision(){
    REV=$(sudo -A dmidecode -t bios 2>/dev/null | grep "Firmware Revision" | cut -d: -f2 | xargs)
    if [ -n "$REV" ]; then
        echo "Firmware Revision: $REV"
    else
        echo "Firmware Revision: Not available"
    fi
}

get_uefi_mode(){
    if [ -d /sys/firmware/efi ]; then
        echo "Boot Mode: UEFI"
    else
        echo "Boot Mode: Legacy BIOS"
    fi
}

get_secure_boot(){
    if command -v mokutil &> /dev/null; then
        SB=$(mokutil --sb-state 2>/dev/null)
        if [ -n "$SB" ]; then
            echo "Secure Boot: $SB"
        else
            echo "Secure Boot: Not available"
        fi
    else
        echo "Secure Boot: Not available (mokutil not installed)"
    fi
}

get_tpm(){
    if [ -d /sys/class/tpm ]; then
        echo "TPM: Present"
    else
        echo "TPM: Not present"
    fi
}

get_smbios_version(){
    VERSION=$(sudo -A dmidecode -t 0 2>/dev/null | grep "SMBIOS" | awk '{print $2}' | xargs )
    if [ -n "$VERSION" ]; then
        echo "SMBIOS Version: $VERSION"
    else
        echo "SMBIOS Version: Not available"
    fi
}
 #============SYSTEM OVERVIEW FUNCTIONS=============

get_kernel_version(){
    echo "Kernel Version: $(uname -r)"
}

get_system_serial(){
    echo "System Serial Number: $(sudo -A dmidecode -s system-serial-number 2>/dev/null || echo 'Not available')"
}

get_system_uuid(){
    echo "System UUID: $(sudo -A dmidecode -s system-uuid 2>/dev/null || echo 'Not available')"
}

get_uptime(){
    echo "System Uptime: $(uptime -p)"
}

get_last_boot(){
    echo "Last Boot: $(who -b | awk '{print $3, $4}')"
}

get_virtualization(){
    VIRT=$(systemd-detect-virt 2>/dev/null)
    if [ -n "$VIRT" ]; then
        echo "Virtualization: $VIRT"
    else
        echo "Virtualization: None (bare metal)"
    fi
}

get_chassis_type(){
    echo "Chassis Type: $(sudo -A dmidecode -s chassis-type 2>/dev/null || echo 'Not available')"
}

#=============TOTAL FUNCTIONS===================
total_system_overview_info(){
    get_kernel_version
    get_system_serial
    get_system_uuid
    get_uptime
    get_last_boot
    get_virtualization
    get_chassis_type
    # 7 functions
}

total_bios_uefi_firmware(){
    get_bios_vendor
    get_bios_version
    get_bios_date
    get_bios_revision
    get_firmware_revision
    get_uefi_mode
    get_secure_boot
    get_tpm
    get_smbios_version
    # 9 functions
}

total_motherboard(){
    motherboard_info  # non detailed 
    get_motherboard_serial
    get_motherboard_version
    get_chipset
    get_southbridge
    get_sata_controller
    get_audio_controller
    # 7 functions
}

total_usb(){
    usb_device_info   # non detailed 1
    get_usb_controllers
    get_usb_tree
    get_usb_details
    get_usb_speeds
    get_usb_serial
    get_usb_manufacturer
    get_usb_product
    get_usb_count
    # 9 functions
}

total_network_hardware(){
    network_info  # non detailed
    get_network_card
    get_network_hardware
    get_network_driver
    get_network_count
    get_link_speed
    # 6 functions
}

total_graphics(){
    graphic_info  # non detailed 
    get_gpu_vendor
    get_gpu_driver
    get_gpu_memory
    get_gpu_count
    get_gpu_temperature
    # 6 functions
}

total_storage(){
    storage_info  # non detailed 
    get_name_model_size
    get_partitions_detailed
    # 3 functions
}

total_memory(){
    memory_info  # non detailed
    get_used_memory
    get_total_swap
    get_used_swap
    get_memory_type
    get_memory_speed
    get_memory_slots_total
    get_memory_slots_used
    get_memory_manufacturer
    get_memory_form_factor
    get_memory_max_capacity
    get_memory_details
    # 12 functions
}

total_cpu(){
    cpu_info  # non detailed 
    get_cpu_vendor
    get_cpu_socket_count
    get_cpu_cores_per_socket
    get_cpu_threads_per_core
    get_current_cpu_speed
    get_cpu_max_speed
    get_cpu_min_speed
    get_cpu_flags
    get_cpu_vulnerabilities
    get_cpu_family
    get_cpu_model
    get_cpu_stepping
    get_cpu_cache
    # 13 functions
}
