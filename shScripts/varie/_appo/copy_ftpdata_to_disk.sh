#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 13-04-2022 17.03.35
#========================================

scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
scriptDir="$(dirname $scriptFPath)"
scriptName="$(basename $scriptFPath .sh)" # remove extension
profiles="${scriptDir}/${scriptName}_profiles.sh"


#########################################################
# trap ctrl-c and call ctrl_c()
#########################################################
trap ctrl_c INT
function @_ctrl_c() {
    echo "** Trapped CTRL-C"
    rCode=1
    exit 1
}

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


function @_displayProfiles() {
    # declare -F| egrep -v "displayProfiles|set_colors|ctrl|parseInput|esegui" | cut -d' ' -f 3| xargs -I % sh -c "echo -n \"    project.....: \"; echo %"
    declare -F| egrep -v "@_" | cut -d' ' -f 3| xargs -I % sh -c "echo -n \"    project.....: \"; echo %"
    echo
    exit 0
}

function @_parseInput() {
    local args=$*
    g_fEXECUTE=0
    # g_Args=''
    # check rhe word and remove it from args
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''

    args=$(echo $args) # remove BLANKs
    if [ ! "$args" == "" ]; then
        echo "${TAB} some parameters are wrong...."
        echo "${TAB} params:       $args"
        exit
    fi
    g_Args=$(echo $args) # remove BLANKs
}

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
    # if [[ "$g_fEXECUTE" -eq "1" && $g_DRY_RUN == '' ]]; then
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        eval $cmd
        # sudo $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && echo "rcode=$rCode" && exit $rCode
    fi
    echo
    CMD_DESCR=
}


function @_set_pause() {
    echo -e "${TABpurpleH}  enter to continue....(x|q to exit)$colorReset"
    read choice
    [[ "$choice" == 'q' || "$choice" == 'x' ]] && exit
}


function laura() {
    sourceDir='/home/laura'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}

function silvia() {
    sourceDir='/home/silvia'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}

function elena() {
    sourceDir='/home/elena'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}

function brother_printer() {
    sourceDir='/home/brother_printer'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}



#################################################
# M A I N
#################################################
    # set -xv
    hostname=$(hostname -s); hostname_lower=${hostname,,}

    # --------------------------
    # get profile/function name
    # --------------------------
    profile_name=$1
    [[ "$profile_name" == "" ]] && @_displayProfiles
    [[ " $profile_name " == *" -h "* ]] && @_displayProfiles
    shift 1
    set -u # check undefined variables

    # ------------ Parse Input
    args=" $* "
    echo -e "${TABcyanH} profile.........: $profile_name"
    echo -e "${TABcyanH} input args......: [$args]"
    @_parseInput $@
    echo -e "${TABcyanH} remaining args..: [$g_Args]"
    echo
    # ------------ Parse Input

    $profile_name;rCode=$?
    if [ $rCode -eq 0 ] ; then
        echo -e "${TABcyanH} user           : $profile_name"
        echo -e "${TABcyanH} sourceDir      : $sourceDir"
        echo -e "${TABcyanH} mainDestDir    : $mainDestDir"
        echo
        for file in "$sourceDir"/*; do
            echo "$file"
            # echo sudo cp -p "$file" "${destPictureDir}"/
            # echo sudo mv "$file" "${destPictureDir}"/
        done
    else
        echo "rCode: $rCode"
    fi

