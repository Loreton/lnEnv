#!/bin/bash
# cd /d d:\LnFree\_Tools\netCat2




function display_fdisk {
    set -u
    local device="$1"
    local SECTORS="$2"
    local server_name="$3"

    echo -e "\n\n$TABcyanH sudo fdisk -l ${device}${colorReset}"
    sudo fdisk -l ${device}
    echo -e "\n"

    DATE=$(date +'%Y-%m-%d')
    BLOCKS="bs=512 count=${SECTORS}"
    OPTIONS='conv=sync,noerror status=progress'
    fileOut="/media/loreto/LnDisk_SD_ext4/myData/Backups/${server_name}/${server_name}_${DATE}_${SECTORS}.img.gz"

    # [[ -f "$fileOut" ]] && echo -e "${TABredH}File $fileOut already exists!" && exit 1
    CMD="sudo dd if=${device} ${OPTIONS} ${BLOCKS} | gzip -c | ssh loreto@192.168.1.47 -p 2222 dd of=${fileOut}"
    echo -e "${TAByellowH}$CMD\n"
    [[ $action == "--go" ]] && eval $CMD
}


function lnpi22_to_img {
    display_fdisk "/dev/mmcblk0" 31340544 "lnpi22"
}

function lnpi23_to_img {
    display_fdisk "/dev/mmcblk0" 31116288 "lnpi23"
}

function lnpi31_to_img {
    display_fdisk "/dev/mmcblk0" 62521344 "lnpi31"
}

function asusp2520l_to_img {
    echo -e "${TAByellowH}nothing to do!!!\n"
}


function img_to_SD {
    sudo dd if=sd-card-copy.img of=/dev/xxxxx bs=512 contu=333333333 status=progress
}



function @_dd_to_img() {
    DATE=$(date +'%Y-%m-%d')
    fileOut="/media/loreto/LnDisk_SD_ext4/myData/Backups/lnpi31/lnpi31_${DATE}.img.gz"
    OPTIONS='conv=sync,noerror bs=512 count=62521343 status=progress'
    OPTIONS='conv=sync,noerror bs=128k status=progress'
    echo """
    # *******************************************
    # *  Lato server di destinazione
    # *******************************************

    # * Attivazione reverse tunnel
        ssh -R -N 9001:localhost:9001 pi@192.168.1.31

    # * Start NetCat Server con redirezione output su file
        nc -l -p 9001 | dd of=$fileOut


    #### **** Lato client raspBerry con uso di netCat
    # * dare il comando:  sudo fdisk -l /dev/mmcblk0 (per leggere sectors-end)

        sudo dd if=/dev/mmcblk0 ${OPTIONS} | nc localhost 9001

    # versione con compressione on fly ed output in locale (lo user ha accesso alla destinazione)
        sudo dd if=/dev/mmcblk0 ${OPTIONS} | gzip -c | nc localhost 9001


    #### **** Lato client raspBerry to ssh remoto
        OPTIONS='conv=sync,noerror bs=128k status=progress'
        DATE=$(date +'%Y-%m-%d')
        sudo dd if=/dev/mmcblk0 ${OPTIONS} | gzip -c | ssh loreto@192.168.1.47 'dd of=$fileOut'

    """

}



function ___() {
    # *-------------------------------------------------
    # * redirect di una porta su un altra porta
    # *-------------------------------------------------
        # http://unix.stackexchange.com/questions/10428/simple-way-to-create-a-tunnel-from-one-local-port-to-another
        nc -l -p 8777 -c "nc 127.0.0.1 8080"

}


# Then run this on the source system
# dd if=/dev/sda | nc <target-system-ip> 9001
# dd if=/dev/sda | nc localhost 9001

hostName=$(hostname -s)

action=$1
source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null
${hostName}_to_img
