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


####################################################
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
####################################################
function @_set_colors() {
    TAB='    '
    red='\033[0;31m';    redH='\033[1;31m';    TABred="${TAB}${red}";       TABredH="${TAB}${redH}"
    green='\033[0;32m';  greenH='\033[1;32m';  TABgreen="${TAB}${green}";   TABgreenH="$BgreenH{T}"
    yellow='\033[0;33m'; yellowH='\033[1;33m'; TAByellow="${TAB}${yellow}"; TAByellowH="${TAB}${yellowH}"
    blue='\033[0;34m';   blueH='\033[1;34m';   TABblue="${TAB}${blue}";     TABblueH="${TAB}${blueH}"
    purple='\033[0;35m'; purpleH='\033[1;35m'; TABpurple="${TAB}${purple}"; TABpurpleH="${TAB}${purpleH}"
    cyan='\033[0;36m';   cyanH='\033[1;36m';   TABcyan="${TAB}${cyan}";     TABcyanH="${TAB}${TABcyanH}"
    gray='\033[0;37m';   white='\033[1;37m';   TABgray="${TAB}${gray}";     TABgrayH="${TAB}${grayH}"
    colorReset='\033[0m' # No Color
}
@_set_colors

#############################################
# - sudo mkfs.ext4 /dev/sdXY -L label_name
# - sudo fsck /dev/sda1
# - sudo lsblk -fs
# - sudo e2label /dev/sda1 label_name
#############################################
function @_esegui() {
    CMD_DESCR=$1
    cmd=$2

    echo -e "${TABcyanH} ${CMD_DESCR}${colorReset}"
    echo -e "${TABpurpleH} [$g_DRY_RUN]$yellowH: $cmd ${colorReset}"
    if [[ "$g_EXECUTE" -eq "1" ]]; then
        eval $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && echo "rcode=$rCode" && exit $rCode
    fi
    echo
    CMD_DESCR=
}



function usersList() {
    _users="\
        laura       1012    lesla
        silvia      1013    lesla
        elena       1014    lesla
        ale         1015    lesla
        printer     1021    lesla
        scanner     1022    lesla
    "
}

#############################################
# -
#############################################
function parseInput() { # solo per console
    g_EXECUTE=0
    g_DELETE=0
    g_username=$1; shift 1 # positional argument
    args=$@

    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_EXECUTE=1
    word='--delete';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_DELETE=1

    g_rest_arguments=$(echo $args) # strip text
}



function getGroupID() {
    group_name=$1
    [[ "$group_name" == "lesla" ]] &&       GID=1101
    [[ "$group_name" == "sftp_users" ]] &&  GID=1102
    echo $GID
}



# less /etc/group
function createGroup() {
    # group='sftp_users'
    group='lesla' && groupID=1101 && echo "$group: $groupID" && sudo addgroup $group --gid ${groupID}

}




function createUser() {
    local group_name=$g_username
    local gid=$g_uid

    @_esegui "creating group" "sudo addgroup ${group_name} --gid ${gid}"
    @_esegui "adding user to group" "sudo adduser ${g_username} --uid ${g_uid} --gid ${gid}" # crea anche la /home/adding user
    for group in $g_groups; do
        @_esegui "adding user to group" "sudo adduser $g_username $group"
    done

}

function deleteUser() {
    local group_name=$g_username
    local gid=$g_uid

    for group in $g_groups; do
        @_esegui "removing user from group" "sudo deluser $g_username $group"
    done
    @_esegui "removing user and group" "sudo deluser ${g_username}"
    # @_esegui "deleting group" "sudo delgroup ${group_name}"

}



################ MAIN BLOCK
    parseInput $@
    echo $g_username


    usersList
    FOUND=
    while IFS= read -r line; do
        line=$(echo $line) # trim BLANKs
        [[ "$line" == "" ]] && continue

        IFS=': ' read user_name g_uid g_groups <<< $line
        if [[ "$user_name" == "#" ]]; then
            echo "skipping... $line"
            continue
        fi
        if [[ "$user_name" == "$g_username" ]]; then
            echo "FOUND $g_username $g_uid"
            [[ "$g_DELETE" -eq "0" ]] && createUser
            [[ "$g_DELETE" -eq "1" ]] && deleteUser
            FOUND=1
        fi
    done < <(printf '%s\n' "$_users")

    if [[ -z "$g_username" ]]; then
        echo "please enter username to be created."
        echo $_users
        echo " --go     to add user"
        echo " --delete to remove user"
        exit 1
    elif [[ -z "$FOUND" ]]; then
        echo "username: [$g_username] NOT found in users_list."
        exit 1
    fi

