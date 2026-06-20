#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 21-01-2026 18.06.14
#========================================


# if ! declare -F @lnLog > /dev/null;         then source ln_log.functions; fi
# if ! declare -F @lnEsegui > /dev/null;      then source esegui.functions; fi
# if ! declare -F @isAbsolute > /dev/null;    then source is_absolute.functions; fi
if ! declare -F @setColors > /dev/null;    then source  colors.functions; fi

export fEXECUTE=${1:---dry-run}




function getDeviceData() {
    local device=$1
    # [[ $device == '/dev' ]] && g_UUID="" && return
    # test=$(lsblk $device 2>/dev/null);rcode=$?
    # [[ "$rcode" -ne 0 ]] && return

    g_UUID=$(lsblk -no UUID $device 2>/dev/null)
    g_currMPoint=$(lsblk -no MOUNTPOINT $device)
    g_fsTYPE=$(lsblk -no FSTYPE $device)
    g_fsSize=$(lsblk -no SIZE $device)
    g_LABEL=$(lsblk -no LABEL $device)
    g_OWNER=$(lsblk -no OWNER $device)
    g_GROUP=$(lsblk -no GROUP $device)
    g_DEVICE=$device
}

#########################################################
# -             P R O F I L E S
#########################################################
function listDevices() {
    # string=$(sudo blkid -o list | grep '/dev/sd')
    string=$(sudo blkid -o list)
    declare BootDrive=$(findmnt -rno SOURCE /)
    len=${#BootDrive}
    len=$(( len - 1 ))
    bootDevice=${BootDrive:0:$len}

    sep="/dev"
    myArray=()
    i=0

    while test "${string#*$sep}" != "$string" ; do
        line="${string%%$sep*}"
        # echo $line
        if [[ $line != '' ]]; then
            myArray[$i]="${sep}${line}"
            i=$(($i+1))
        fi
        string="${string#*$sep}"
    done
    ### the last data
    i=$(($i+1))
    myArray[$i]="${sep}${string}"


    header="\n  \t%-12s %-8s %-15s %-15s %-30s %-30s\n"
    format="    \t%-12s %-8s %-15s %-15s %-30s %-30s\n"

    divider="================================================="
    divider="\t$divider$divider"
    width=120
    printf "$header" "DEVICE" "fs_type" "fs_size" "label" "mountPoint" "UUID"
    printf "${divider}\n"

    nDevices="${#myArray[@]}"
    nDevices=$((nDevices - 1))
    echo -e "\t${purpleH}found $nDevices devices (boot device: $BootDrive"
    validDevices=0
    systemDevices=0


    set -u
    for item in "${myArray[@]}"; do
        IFS=' ' read device ignore_rest <<< $item
        [[ ! -b $device ]] && continue ###. non ÃÂ¨ un block device
        getDeviceData $device
        if [[ ! -z "$g_UUID" ]]; then

            if [[ "${g_DEVICE}" == *"${bootDevice}"* ]]; then ###. isoliamo quelli di distema
                systemDevices=$((systemDevices + 1))
                echo -en "${gray}"
                printf "${format}" "$device" "$g_fsTYPE" "$g_fsSize" "$g_LABEL" "$g_currMPoint" "$g_UUID"
                echo -en "${resetColor}"
            else
                validDevices=$((validDevices + 1))
                echo -en "${cyan}"
                printf "${format}" "$device" "$g_fsTYPE" "$g_fsSize" "$g_LABEL" "$g_currMPoint" "$g_UUID"
                echo -en "${resetColor}"
            fi
        fi
    done
    echo -e "\t${purpleH}system devices: $systemDevices"
    echo -e "\t${purpleH}valid  devices: $validDevices"
    echo
}

listDevices