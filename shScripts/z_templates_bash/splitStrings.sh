#!/bin/bash



function splitString() {
    local string="$1"
    local sep="$2"
    # output of sudo blkid -o list | grep -i uuid
    # string="/sda6 swap [SWAP] bbae7341-e76f-4e68-acf0-f96720e1295b /sda5 ext4 / 8d6062a2-d53f-4a92-8917-2fe4589f8417 /sdb2 ntfs LnDisk_SD_ntfs /media/loreto/LnDisk_SD_ntfs 52424AE443D5E32A /sdb1 ext4 LnDisk_SD_ext4 /media/loreto/LnDisk_SD_ext4 76827f6b-bd94-4158-8024-6c1a8fefb52e /sdc1 vfat 102-NOBOOT /media/loreto/102-NOBOOT1 6ABD-70D6 /sda4 ntfs (not mounted) 3CA46968A469261C /sda2 vfat /boot/efi F867-CF35 /sda1 ntfs (not mounted) C6CAF8FFCAF8ED15"
    # string="Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-12-16 14:36 CET Nmap scan report for Unused-852E00.lan (192.168.1.144) Host is up (0.037s latency). MAC Address: BC:DD:C2:85:2E:00 (Espressif) Nmap done: 1 IP address (1 host up) scanned in 0.15 seconds "

    # sep="for"
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
    for item in "${myArray[@]}"; do
      echo $item
    done

}


splitString "/home/loreto/lnprofile/sh_scripts/z_templates_bash/splitStrings.sh" "sh_"