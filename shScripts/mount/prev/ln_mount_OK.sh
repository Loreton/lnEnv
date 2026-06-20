#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.28.56
#========================================


source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null

#########################################################
# -             P R O F I L E S
#########################################################
profile_data="${scriptDir}/${noext_scriptName}_profiles.sh"
[[ ! -f "$profile_data" ]] && echo "profile $profile_data not found!" && exit 1
source $profile_data



function displayProfiles() {
    prefix_str='@_'
    suffix_str=''
    funcsList=$(declare -F | egrep  ${prefix_str} | cut -d' ' -f 3)

    printf "\n${TAB}${TAByellowH} %-25s %s\n" "profile_name" "UUID"
    echo -en "${cyanH}"
    # echo "${TAB}Profile name              UUID:"
    for func_name in $funcsList; do
        $func_name ### call it
        profile_name=${func_name#"${prefix_str}"}
        profile_name=${profile_name#"${suffix_str}"}
        # echo "${TAB}${TAB}$profile_name         $g_UUID"
        # y="${profile_name:0:60}${g_UUID:0:$((40 - ${#profile_name}))}"
        y="${profile_name:0:60}${g_UUID:0:$((60 - ${#profile_name}))}"
        # echo "${TAB}${TAB}$y"s
        printf "${TAB}${TAB} %-25s %s\n" $profile_name $g_UUID
    done
    echo -e "${colorReset}"
    echo
}

#############################################
#
#############################################
function syntax() {
    echo -e "${TAByellowH}    syntax $(basename $BASH_SOURCE) profile_name [options..]"

    echo -en "${cyanH}"
    [[ "$1" -eq "1" ]] && displayProfiles
    echo "${TAB}Options:"
    echo "${TAB}${TAB}-h|--help    this help"
    echo "${TAB}${TAB}--go         execute commands"
    echo "${TAB}${TAB}--mount      execute command with dry-run option"
    echo "${TAB}${TAB}--umount     execute command with dry-run option"
    echo -e "${colorReset}"
    echo
}





#############################################
#
#############################################
function parseInput() {
    local args=$*
    echo "${TAB}command line: $args"
    [[ -z $args ]] && syntax 1 && exit 1
    g_fEXECUTE=0
    g_ACTION=''
    g_DRY_RUN='--dry-run'

    # check rhe word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''
    word='--mount';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_ACTION='mount'
    word='--umount';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_ACTION='umount'

    g_Args=$(echo $args) # remove BLANKs
    echo "${TAB}input args:   $g_Args"
    echo
}




#############################################
# need the following variables:
#    $g_fEXECUTE
# caller: https://stackoverflow.com/questions/10707173/bash-parameter-quotes-and-eval/10707498#10707498
#############################################
function @local_esegui() {
    # set -u
    # set -x
    local stacklevel=$1
    local CMD_DESCR=$2
    local cmd=$3
    local indent=$TAB
    # set +x
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
    echo -e "${TAB}${TAB}exists             : $g_diskExists"
    echo -e "${TAB}${TAB}path               : $g_currMPath"
    echo -e "${TAB}${TAB}isMOUNTED on       : ${purpleH}${g_MOUNTED_ON}${cyanH}"
    echo -e "${TAB}${TAB}preferred MPoint   : ${g_MPoint}"
    echo -e "${TAB}${TAB}device UUID        : ${g_UUID}"
    echo -e "${TAB}${TAB}device TYPE        : ${g_fsTYPE}"
    echo -e "${TAB}${TAB}userID:groupID     : ${g_userID}:${g_groupID}"
    echo -e "${TAB}${TAB}userNAME:groupNAME : ${g_userNAME}:${g_groupNAME}"
    echo
    echo -e "${TAB}${TAB}change label extx: sudo e2label /dev/sda1 Ln1TB_41"
    echo -e "${TAB}${TAB}change label ntfs: sudo ntfslabel /dev/sda1 Ln1TB_31"
    echo -en "${colorReset}"
    echo
    set -u
}









################################
# -
################################
function verifyDiskByUUID {
    g_MOUNTED_ON='not mounted'
    g_isMOUNTED=0
        # verifichiamo se lo UUID Ã¨ presente nel sistema
    g_currMPath=$(/sbin/blkid -U ${g_UUID})

    if [[ -n "$g_currMPath" ]]; then
        g_diskExists='true'
        mountLine=$(mount | grep $g_currMPath)

        if [[ -n "$mountLine" ]]; then
            g_MOUNTED_ON=$(echo $mountLine | cut -f3 -d\ )
            g_isMOUNTED=1
            displayDevice "disk is mounted on: $g_MOUNTED_ON"

        else
            displayDevice "disk $g_LABEL exists but is NOT mounted"
        fi

    else
        displayDevice "${redH}required disk ${g_LABEL} not found/attached on system."
        exit 1

    fi

}


################################
# -
################################
function mountDiskByUUID {

    if [[ $g_isMOUNTED -eq 0 ]]; then

        # if [[ -d $g_MPoint ]]; then
        #     @local_esegui 0 "removing mount point"  "sudo rmdir $g_MPoint"
        # fi

        if [[ -d "$g_MPoint" ]]; then
            echo -e "${TABpurpleH}mount point already exists\n"
        else
            @local_esegui 0 "creating mount point"   "sudo mkdir $g_MPoint"
            @local_esegui 0 "changing owner"         "sudo chown -R $g_userNAME:$g_groupNAME $g_MPoint"
        fi

        @local_esegui 0 "Executing command"      "sudo /bin/mount -t ${g_fsTYPE} ${g_OPTIONS} -U ${g_UUID} ${g_MPoint}"


    else
        exit
    fi

}



################################
# -
################################
function uMountDiskByUUID {

    if [[ $g_isMOUNTED -eq 1 ]]; then
        # @local_esegui 0 "Executing command" "sudo /bin/umount ${g_MPoint}"
        # @local_esegui 0 "removing mount point"  "sudo rmdir $g_MPoint"
        @local_esegui 0 "Executing command" "sudo /bin/umount ${g_MOUNTED_ON}"
        [[ -d ${g_MOUNTED_ON} ]] && @local_esegui 0 "removing mount point"  "sudo rmdir ${g_MOUNTED_ON}"
    else
        exit
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

    # set -u # check undefined variables
    parseInput $@
    echo $g_Args
    g_profile_name=$1
    # --------------------------
    # Execute profile_name
    # --------------------------
    "@_${g_profile_name}" >/dev/null 2>&1;rCode=$?
    exit

    g_userID=$( id -g $g_userNAME )
    g_groupID=$( id -u $g_userNAME )
    g_groupNAME=$( id -gn $g_userNAME )


    # [[ "$g_userNAME" == 'pi' ]] && g_groupNAME='lesla' || g_groupNAME=$( id -gn $g_userNAME )
    if [[ "$g_userNAME" == 'pi' ]]; then
        g_groupNAME='lesla'
        g_groupID=$( getent group 'lesla' | cut -d: -f3 )
    fi


    if [ $rCode -ne 0 ] ; then
        syntax 1
        echo -e "${TABredH} Function $g_profile_name NOT found. (rCode: $rCode)"
        echo
        exit 1
    fi


    verifyDiskByUUID
    # g_currMPath=$(/sbin/blkid -U ${g_UUID})
    case $g_ACTION in
        mount)
            mountDiskByUUID
            # verifyDiskByUUID
            # echo "sudo lsof $currMPath"
            # echo "sudo fuser -vm $currMPath"
            ;;

        umount*)
            uMountDiskByUUID
            # verifyDiskByUUID
            ;;

        *)
            if [[ -z $g_UUID ]]; then
                listDisks
            fi
            syntax 0
            exit 1


            ;;
    esac

    if [[ $g_fEXECUTE -eq 0 ]]; then
        echo
        echo -e "${TAByellowH}run in --dry-run mode"
        echo -e "${TAByellowH}enter --go as an argument to execute the command "
        echo
    fi
