#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 08-02-2026 09.20.02
#========================================



commonFunction="${HOME}/filu/lnEnv/init/commonFunctions"
if ! declare -F @setColors > /dev/null; then
    source ${commonFunction}/colors.functions
fi






function getDeviceData() {
    local device=$1
    [[ $device == '/dev' ]] && return
    g_UUID=$(lsblk -no UUID $device)
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
    string=$(sudo blkid -o list | grep '/dev/sd')

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
    divider=$divider$divider
    width=120
    printf "$header" "DEVICE" "fs_type" "fs_size" "label" "mountPoint" "UUID"
    printf "${divider}\n"

    for item in "${myArray[@]}"; do
        # echo $item
        if [[ -z "$item" || "$item" == "/dev" ]]; then
            continue
        fi  
        IFS=' ' read device ignore_rest <<< $item
        getDeviceData $device
        printf "${format}" "$device" "$g_fsTYPE" "$g_fsSize" "$g_LABEL" "$g_currMPoint" "$g_UUID"
    done
}


#############################################
# https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/
# called by:     parseInput "$@"
# No colons         - No values are required
# Single colon (:)  - Value is required for this option
# Double colon (::) - Value is optional - NON è vero
#############################################
function parseInput() {
    input_help() {
        echo -e "${TAB}${cyanH}Usage: $(basename $0)
                ${cyanH}[ --action ]        ${yellowH}mount|umount
                ${cyanH}[ --device ]        ${yellowH}device path
                ${cyanH}[ --uuid ]          ${yellowH}device UUID
                ${cyanH}[ --go ]            ${yellowH}real execute
                ${cyanH}[ -h | --help  ]    ${yellowH}this help"
        exit 2
    }

    N_ARGUMENTS=$# # Returns the count of arguments that are in short or long options
    [[ "$N_ARGUMENTS" -eq 0 ]] && listDevices && input_help


    ### - defaults
    g_fEXECUTE=0
    g_ACTION=''
    g_DEV=''
    g_UUID=''
    g_DRY_RUN='--dry-run'

    OPTS=$(getopt -a -n ParseInput --options 'h' --longoptions 'action:,uuid:,go,help,device:' -- "$@")
    eval set -- "$OPTS"

    while :; do
        case "$1" in
            --action )
                g_ACTION="$2"; shift; shift; ;;

            --device )
                g_DEV="$2"; shift; shift; ;;

            --uuid )
                g_UUID="$2"; shift; shift;
                g_DEV=$(/sbin/blkid -U $g_UUID)
                ;;

            -h | --help)
                listDevices
                input_help; ;;

            --go)
                g_fEXECUTE=1 && g_DRY_RUN=''; shift 1; ;;



            --)
                shift 1; break; ;;

            *)
                echo "Unexpected option: $1"; input_help; ;;
        esac
    done



    _test=${g_ACTION:?"--action is mandatory argument"}
    # _test=${g_DEV:?"--device is mandatory argument"}
    # echo "g_ACTION:     $g_ACTION"
    # echo "g_EXECUTE:    $g_EXECUTE"
    # echo "g_DEVICE:     $g_DEV"
}




#############################################
# need the following variables:
#    $g_fEXECUTE
# caller: https://stackoverflow.com/questions/10707173/bash-parameter-quotes-and-eval/10707498#10707498
#############################################
function @local_esegui() {
    local stacklevel=$1
    local CMD_DESCR=$2
    local cmd=$3
    local indent=$TAB

    caller="${FUNCNAME[stacklevel+1]}:${BASH_LINENO[stacklevel]}"
    printf "\n${indent}[${caller}]"
    printf "\n${indent}${cyanH} ${CMD_DESCR}${colorReset}\n"
    if [[ "$g_fEXECUTE" -eq "1" || "$g_fEXECUTE" == "go" ]]; then
        printf "${indent}${purpleH} [executing]$yellowH: ${cmd}${colorReset}\n"
        eval '$cmd'
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && printf "${indent}${redH} ${rCode}${colorReset}\n" && exit $rCode
    else
        printf "${indent}${purpleH} [dry-run]$yellowH: ${cmd}${colorReset}\n"
    fi
}






################################
# -
################################
function displayDevice() {
    set +u # -u  Treat unset variables as an error when substituting
    TEXT=$*
    echo
    echo -e "${TAByellowH}"
    echo -e "${TAB}---------------------------------------------------------------"
    echo -e "${TAB}--- $TEXT${TAByellowH}"
    echo -e "${TAB}---------------------------------------------------------------"
    echo -e "${TABcyanH}"

    echo -e "${TAB}${TAB}path               : $g_DEVICE"
    echo -e "${TAB}${TAB}current   MPoint   : ${purpleH}${g_currMPoint}${cyanH}"
    echo -e "${TAB}${TAB}preferred MPoint   : ${g_reqMPoint}"
    echo -e "${TAB}${TAB}device    UUID     : ${g_UUID}"
    echo -e "${TAB}${TAB}device    TYPE     : ${g_fsTYPE}"
    echo -e "${TAB}${TAB}device    SIZE     : ${g_fsSize}"
    echo -e "${TAB}${TAB}userID:groupID     : ${g_userID}:${g_groupID}"
    echo -e "${TAB}${TAB}userNAME:groupNAME : ${g_userNAME}:${g_groupNAME}"

    # echo
    # echo -e "${purpleH}"
    # echo -e "${TAB}${TAB}change label extx: sudo e2label $g_DEVICE Ln1TB_41"
    # echo -e "${TAB}${TAB}change label ntfs: sudo ntfslabel $g_DEVICE Ln1TB_31"
    echo -en "${colorReset}"
    echo
    set -u
}












################################
# -
################################
function mountDisk {

    ### check for wrong mountpoint
    if [[ "$g_currMPoint" != "$g_reqMPoint" ]]; then
        uMountDisk "silent"
        getDeviceData $g_DEV
        err_msg="${redH}[in wrong moutpoint]$colorReset"
    fi

    if [[ -z $g_currMPoint ]]; then
        displayDevice "current status: $g_DEVICE"

        if [[ -d "$g_reqMPoint" ]]; then
            echo -e "${TABpurpleH}mount point already exists\n"
        else
            @local_esegui 0 "creating mount point"   "sudo mkdir "$g_reqMPoint""
            @local_esegui 0 "changing owner"         "sudo chown -R $g_userNAME:$g_groupNAME "$g_reqMPoint""
        fi

        [[ ${g_fsTYPE} == "ntfs" ]] && g_OPTIONS+=",fmask=133,dmask=022" ## evita di avere le dir in inverse video
        [[ ${g_fsTYPE} == "ext4" ]] && g_OPTIONS="" ## wrong fs type, bad option, bad superblock on /dev/sdxx, missing codepage or helper program, or other error
        @local_esegui 0 "Executing command"      "sudo /bin/mount -t ${g_fsTYPE} ${g_OPTIONS} -U ${g_UUID} "${g_reqMPoint}""

    else
        displayDevice "device: $g_DEVICE is already mounted!"

        exit
    fi

}



################################
# -
################################
function uMountDisk {
    local silent=$1

    if [[ -n $g_currMPoint ]]; then
        [[ "$silent" != "silent" ]] && displayDevice "current status: $g_DEVICE"
        @local_esegui 0 "Executing command" "sudo /bin/umount ${g_currMPoint}"
        [[ -d ${g_currMPoint} ]] && @local_esegui 0 "removing mount point"  "sudo rmdir ${g_currMPoint}"
    else
        displayDevice "device: $g_DEVICE is NOT mounted!"
        [[ "$silent" != "silent" ]] && exit
    fi

}





################################
# - MAIN
# - Comandi utili
# - sudo blkid
# - sudo lsblk
################################




#################################################
# M A I N
#################################################
    # set -xv
    hostname=$(hostname -s); hostname_lower=${hostname,,}
    parseInput $@

    # [[ ! -z "$g_UUID" ]] && g_DEV=$(/sbin/blkid -U "$g_UUID")

    g_userNAME="$USER"
    g_userID=$( id -g $g_userNAME )
    g_groupID=$( id -u $g_userNAME )
    g_groupNAME=$( id -gn $g_userNAME )

    if [[ -b "$g_DEV" ]]; then ### it's a block device /dev/sdxa

        getDeviceData $g_DEV

        g_OPTIONS=''
        g_OPTIONS="-o defaults,noauto,relatime,nousers,rw,flush,utf8=1,umask=022,exec,uid=${g_userID},gid=${g_groupID},dmask=002,fmask=113"
        g_OPTIONS="-o rw,uid=${g_userID},gid=${g_groupID}"



        ### ho notato che per alcuni è meglio non mettere uuid o gid (default: uid=gid=0)
        [[ "$g_LABEL" == "bkup2_500GB" ]] && g_OPTIONS=''

        g_reqMPoint="/media/${g_LABEL}"
        g_reqMPoint="/media/${USER}/${g_LABEL}"


    else
        # --------------------------
        # Execute profile_name
        # --------------------------
        echo -e "\n${TAB}${redH}device [$g_DEV] is NOT a block device${colorReset}"
        listDevices
        echo
        input_help
        exit
    fi

    if [[ "$g_userNAME" == 'pi' ]]; then
        # g_groupNAME='lesla'
        g_groupNAME='pi'
        g_groupID=$( getent group ${g_groupNAME} | cut -d: -f3 )
    fi



    # displayDevice "current status: $g_DEVICE"
    case $g_ACTION in
        mount)
            mountDisk
            ;;

        umount)
            uMountDisk
            ;;

        *)
            if [[ -z $g_UUID ]]; then
                set -x
                listDisks
                set +x
            fi
            input_help
            exit 1


            ;;
    esac

    if [[ $g_fEXECUTE -eq 0 ]]; then
        echo
        echo -e "${TAByellowH}run in --dry-run mode"
        echo -e "${TAByellowH}enter --go to execute the command "
        echo
        echo -e "${purpleH}"
        echo -e "${TAB}${TAB}change label extx: sudo e2label $g_DEVICE Ln1TB_41"
        echo -e "${TAB}${TAB}change label ntfs: sudo ntfslabel $g_DEVICE Ln1TB_31"
        echo -en "${colorReset}"
        echo
    else
        getDeviceData $g_DEV
        displayDevice "current status: $g_DEVICE"
        echo
    fi
