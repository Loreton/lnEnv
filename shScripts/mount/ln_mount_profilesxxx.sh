#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 04-04-2023 17.01.42
#========================================



function @xx_seagate_500GB() {
    # LABEL="SeaGate_500GB" UUID="0E4D094B0E4D094B" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="42e11593-fea2-11e8-8d90-1c7508f2b04f"
    g_UUID='0E4D094B0E4D094B'
    g_LABEL='SeaGate_500GB'
    g_TYPE='ntfs-3g'
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_userNAME='pi'
    g_userNAME=$USER; groupID='lesla'
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
}

function @_Ln1TB_B() {
    # LABEL="Toshiba_1TB_LnDisk" UUID="843671A53671993E" TYPE="ntfs" PTTYPE="atari" PARTUUID="7fcb449d-01"
    g_LABEL='Ln1TB_B'
    g_disk='toshiba_1TB_LnDisk'
    g_UUID='843671A53671993E'
    g_TYPE='ntfs-3g'
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
}


function @_toshiba_1TB_Ubun() {
    # LABEL="Toshiba_1TB_Ubun"   UUID="441d4b2e-2e17-451d-8835-485e388f6595" TYPE="ext4" PARTUUID="7fcb449d-02"
    g_UUID='441d4b2e-2e17-451d-8835-485e388f6595'
    g_LABEL='Toshiba_1TB_Ubun'
    g_TYPE='ext4'
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
}


function @_Ln1TB_41() {
    # LABEL="Ln1TB_A" UUID="cb09f029-226a-474c-a63d-1718a3bc67b3" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="00442663-01"
    g_disk='toshiba_1TB_A'
    g_LABEL='Ln1TB_41'
    # g_UUID='0EBE144A0EBE144A'
    g_UUID='cb09f029-226a-474c-a63d-1718a3bc67b3'
    g_TYPE='ext4'
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
}

function @_SD_500GB_SDD() {
    g_disk='sandisk_SD_500GB'
    g_LABEL="SD_500GBa"
    g_UUID="e694b62a-b4a2-491b-b841-818e5733bd66"
    g_TYPE="ext4"
    g_PARTLABEL="Extreme SSD"
    g_PARTUUID="8e50a9ed-0674-45ce-98db-c790e6dc632a"
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o defaults,noauto,relatime,rw,nousers" # sembra non dare errore bad superblock
}

function @_WD_500GB_SDD() {
    g_disk='westDigital_WD_500GB'
    g_LABEL="WD_500GBa"
    g_UUID="7726c1f1-da47-4c0a-807e-028f6ac4901d"
    g_TYPE="ext4"
    g_PARTUUID="8969a95c-8e6f-4c55-a934-d9b1c2ca5060"
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o defaults,noauto,relatime,rw,nousers" # sembra non dare errore bad superblock
}
function @_bkup2_500GB() {
    # - usb-devices
    # dev/sda1: LABEL="bkup2-500GB" UUID="c1cb918b-9a98-4ec1-ac82-7ce9d7a3ff00" TYPE="ext4" PARTUUID="1d720666-a863-43d7-8f22-57ed16548716"
    g_disk='unknown'
    g_LABEL="bkup2_500GB"
    g_UUID="c1cb918b-9a98-4ec1-ac82-7ce9d7a3ff00"
    g_TYPE="ext4"
    g_PARTLABEL="My Passport"
    g_PARTUUID="1d720666-a863-43d7-8f22-57ed16548716"
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER       ## replaced into the script
    g_userNAME=$USER
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    g_OPTIONS="-o defaults,noauto,relatime,rw,nousers" # sembra non dare errore bad superblock
}


function @_Samsung_HM250JI() {
    # UUID="2b488ba1-0097-466e-8d0c-c172a9fac374" TYPE="ext4" PARTLABEL="Samsung_HM250JI" PARTUUID="64c1ced9-0b6c-4ffa-8181-6fb7b34824a3"
    # LABEL="Samsung_HM250JI",UUID="37D22367375B0EBE" TYPE="ntfs" PTTYPE="dos" PARTUUID="dd42a659-01"
    g_UUID="37D22367375B0EBE"
    g_PARTUUID="dd42a659-01"
    g_TYPE="ntfs-3g"
    g_LABEL="Samsung_HM250JI"
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME='pi'
    g_userNAME=$USER
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,umask=022,exec,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    # XXX="${currMPath} ${userID}"
    # sudo mount -t ntfs -o umask=022,exec,uid=1000,gid=1000 /dev/sda2 /media/USBDongle1
}




function @_RaspBerry_pi41() {
    # LABEL="rootfs" UUID="6a932c1f-7335-42d9-9351-1b1b2ca538d4" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="bf6d7ef6-02"
    g_LABEL="Pi41"
    g_UUID="6a932c1f-7335-42d9-9351-1b1b2ca538d4"
    g_BLOCK_SIZE="4096"
    g_TYPE="ext4"
    g_PARTUUID="bf6d7ef6-02"
    g_MPoint="/media/${USER}/${g_LABEL}"
    g_userNAME=$USER

    g_groupID="$USER"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,umask=022,exec,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    # sudo /bin/mount -t ext4  -U 6a932c1f-7335-42d9-9351-1b1b2ca538d4 /mnt/Pi41
    g_OPTIONS=""
}



function @_LnDataDisk() {
    # LABEL="LnDataDisk" BLOCK_SIZE="512" UUID="0C6A19B30C6A19B3" TYPE="ntfs" PARTUUID="93ae59b1-01"
    g_LABEL="LnDataDisk"
    g_UUID="0C6A19B30C6A19B3"
    g_BLOCK_SIZE="512"
    g_TYPE="ntfs"
    g_PARTUUID="93ae59b1-01"
    g_MPoint="/media/${USER}/${g_LABEL}"

    g_userNAME="$USER"
    g_groupID="$USER"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,umask=022,exec,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    # sudo /bin/mount -t ext4  -U 6a932c1f-7335-42d9-9351-1b1b2ca538d4 /mnt/Pi41
    g_OPTIONS=""
}


function @_pennaUsb_16GB() {
    # LABEL="MULTIBOOT" UUID="1608-3544" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="c3072e18-01"
    g_LABEL="MULTIBOOT"
    g_UUID="1608-3544"
    g_BLOCK_SIZE="512"
    g_TYPE="vfat"
    g_PARTUUID="c3072e18-01"
    g_MPoint="/media/${USER}/${g_LABEL}"

    g_userNAME="$USER"
    g_groupID="$USER"
    g_OPTIONS="-o uid=${g_userID},gid=${g_groupID}"
    g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,umask=022,exec,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
    # sudo /bin/mount -t ext4  -U 6a932c1f-7335-42d9-9351-1b1b2ca538d4 /mnt/Pi41
    g_OPTIONS=""
}



