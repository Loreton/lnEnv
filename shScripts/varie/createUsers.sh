#!/bin/bash

#  adduser --group [--gid ID] GROUP
#  addgroup [--gid ID] GROUP
#     Add a user group
#
#  addgroup --system [--gid ID] GROUP
#     Add a system group
#
#  adduser USER GROUP
#     Add an existing user to an existing group

# set -u  # Treat unset variables as an error when substituting.




# trap "exit 1" TERM
# export TOP_PID=$$
# function lnExit() {
#     kill -s TERM $TOP_PID
# }



#############################################
# need the following variables:
#    $g_fEXECUTE
# caller: https://stackoverflow.com/questions/10707173/bash-parameter-quotes-and-eval/10707498#10707498
#############################################
function ____esegui() {
    set -u
    # set -x
    local stacklevel=$1
    local CMD_DESCR=$2
    local cmd=$3
    local indent=$4
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

function esegui() {
    local stacklevel=1
    local indent=$TAB
    ____esegui $stacklevel "$@" "$indent"
}

#############################################
# -
#############################################
function parseInput() { # solo per console
    g_fEXECUTE=0
    g_fDELETE_USER=0
    args=$@

    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1
    word='--delete';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fDELETE_USER=1

    g_username=$(echo $args | cut -d' ' -f1)
    args=${args//$g_username/}
    g_rest_arguments=$(echo $args) # strip text
}



#############################################
# - check username
#############################################
function checkUserName() {
    local user_name=$1

    if [[ -z "$user_name" ]]; then
        printf "${TABredH}please enter user name\n"
        printf "${TAByellowH}${all_USERS}\n"
        lnExit
    fi


    users=$(cut -d: -f1 /etc/passwd | tr '\n' ' ')
    if [[ " $users " == *" $user_name "* ]]; then
        printf "${TABredH}user: %s already exists\n" $user_name
        lnExit
    fi

    userID=$(getUserID $user_name)
    if [[ -z $userID ]]; then
        printf "${TABredH}user: %s not found in list\n" $g_username
        lnExit
    fi
}





#############################################
# -
#############################################
function getGroupID() {
    group_name=$1
    unset _group_id

    [[ "$group_name" == "lesla" ]] &&       _group_id=1101
    [[ "$group_name" == "sftp_users" ]] &&  _group_id=1102
    echo $_group_id
}

#############################################
# -
#############################################
function getUserID() {
    user_name=$1
    unset _uudi
    [[ "$user_name" == "laura" ]] &&    _uudi=1012
    [[ "$user_name" == "silvia" ]] &&   _uudi=1013
    [[ "$user_name" == "elena" ]] &&    _uudi=1014
    [[ "$user_name" == "ale" ]] &&      _uudi=1015
    [[ "$user_name" == "loreto" ]] &&   _uudi=1016
    [[ "$user_name" == "scanner" ]] &&  _uudi=1022
    [[ "$user_name" == "camera" ]] &&   _uudi=1023
    [[ "$user_name" == "xerox" ]] &&    _uudi=1024
    echo $_uudi
}

#############################################
# less /etc/group
#############################################
function createGroup() {
    local group_name=$1

    group_id=$(getGroupID $group_name)
    if [[ -z $group_id ]]; then
        printf "group: %s not found in list" $group_name
        lnExit
    fi

    groups=$(groups)
    if [[ " $groups " == *" $group_name "* ]]; then
        printf "${TABredH}group: %s already exists" $group_name
    else
        esegui "creating $group - $group_id" "sudo addgroup $group_name --gid ${group_id}"
    fi
}




#############################################
#
#############################################
function createUser() {
    local user=$1
    local user_id=$2
    local home="/home/${user}"

    local group_name=$user
    local gid=$user_id

    esegui "creating group"            "sudo addgroup ${group_name} --gid ${gid}"
    esegui "creating user and group"   "sudo adduser ${user} --uid ${user_id} --gid ${gid}" # crea anche la /home/adding user


}


#############################################
#
#############################################
function generate_ssh_key() {
    local user=$1
    local ssh_dir="/home/${user}/.ssh"
    local user_backup_dir="${ln_BASE_CONFIG_DIR}/.ssh_common/${user}"

    esegui "creating SSH directory"    "sudo mkdir -p ${ssh_dir}"
    esegui "creating $user backup directory"  "sudo mkdir -p ${user_backup_dir}"
    esegui "generating $user ed25519"    "sudo ssh-keygen -t ed25519 -o -a 100  -f ${user_backup_dir}/id_ed25519 -C ${user}.ed25519"
    esegui "generating $user RSA key"    "sudo ssh-keygen -t rsa     -b 2048    -f ${user_backup_dir}/id_rsa     -C ${user}.rsa"
    esegui "changing directory attributes"  "sudo chown -R pi:pi ${user_backup_dir}"
}

#############################################
#
#############################################
function copy_ssh_key() {
    local user=$1
    local ssh_dir="/home/${user}/.ssh"
    local user_backup_dir="${ln_BASE_CONFIG_DIR}/.ssh_common/generic"

    esegui "making ssh directory"  "sudo mkdir -p ${ssh_dir}/"
    esegui "copying to $user ssh directory"  "sudo cp ${user_backup_dir}/* ${ssh_dir}/"
    esegui "changing directory attributes"  "sudo chown -R $user:$user ${ssh_dir}"
    esegui "changing directory attributes"  "sudo chmod 600 ${ssh_dir}/*"
}


#############################################
#
#############################################
function scannerUserSetUp() {
    local user=$1
    local home="/home/${user}"

    esegui "creating FTP directory"         "sudo mkdir -p ${home}/FTP"
    esegui "changing directory attributes"  "sudo chmod 755 ${home}/FTP"

    # esegui "creating Brother directory"     "sudo mkdir -p ${home}/FTP/brother"
    # esegui "changing directory attributes"  "sudo chmod 755 ${home}/FTP/brother"

    # esegui "creating Xerox directory"       "sudo mkdir -p ${home}/FTP/xerox"
    # esegui "changing directory attributes"  "sudo chmod 755 ${home}/FTP/xerox"

    esegui "changing directory attributes"  "sudo chown -R ${user}:lesla ${home}/FTP"
}

#############################################
#
#############################################
function cameraUserSetUp() {
    local user=$1
    local home="/home/${user}"

    esegui "creating FTP directory"         "sudo mkdir -p ${home}/FTP"
    esegui "changing directory attributes"  "sudo chmod 755 ${home}/FTP"

    esegui "creating Brother directory"     "sudo mkdir -p ${home}/FTP/IE30"
    esegui "changing directory attributes"  "sudo chmod 755 ${home}/FTP/IE30"

    esegui "changing directory attributes"  "sudo chown -R ${user}:lesla ${home}/FTP"
}




#############################################
#
#############################################
function deleteUser() {
    local user_name=$1
    local user_groups=$(groups $user_name | cut -d':' -f2)

    for group in $user_groups; do
        [[ $group == $user_name ]] && continue
        esegui "removing user from group: $group" "sudo deluser $g_username $group"
    done
    esegui "removing user and group" "sudo deluser ${g_username}"
}


#############################################################
#           M A I N
#############################################################
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors trap_exit" >/dev/null
    set -u
    parseInput $@
    if [[ "$g_fDELETE_USER" -eq '1' ]]; then
        deleteUser $g_username
        lnExit
    fi

    all_USERS="ale laura silvia elena scanner xerox camera"
    checkUserName $g_username

    userID=$(getUserID $g_username)
    if [[ -z $userID ]]; then
        echo
        echo -e "  ${yellowH}please enter one of the following usernames"
        echo -e "  ${cyanH}$all_USERS${colorReset}"
        echo
        exit 1
    fi

    createUser $g_username $userID

    # generate_ssh_key $g_username
    copy_ssh_key $g_username




    if [[ " ale laura silvia elena " == *" $g_username "* ]]; then
        mountPoint="/media/pi/Ln1TB_41/sFTP/${g_username}"
        if [[ -d ${mountPoint} ]]; then
            esegui "create external link" "sudo ln -sf "${mountPoint}" "/home/${g_username}/${g_username}_disk""
            createGroup 'lesla'
            esegui "adding user to group" "sudo adduser $g_username lesla"
        else
            printf "${TABredH}mountPoint: %s doesn't exists\n" $mountPoint
            lnExit
        fi
    elif [[ " scanner xerox " == *" $g_username "* ]]; then
        scannerUserSetUp $g_username
    elif [[ "$g_username" == 'camera' ]]; then
        cameraUserSetUp $g_username
    fi