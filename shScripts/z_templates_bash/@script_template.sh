#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 23-05-2022 14.58.17
#========================================


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
function set_colors() {
    TAB='    '
       red='\033[0;31m';    redH='\033[1;31m';    TABred="${TAB}${red}";       TABredH="${TAB}${redH}"
     green='\033[0;32m';  greenH='\033[1;32m';  TABgreen="${TAB}${green}";   TABgreenH="${TAB}${greenH}"
    yellow='\033[0;33m'; yellowH='\033[1;33m'; TAByellow="${TAB}${yellow}"; TAByellowH="${TAB}${yellowH}"
      blue='\033[0;34m';   blueH='\033[1;34m';   TABblue="${TAB}${blue}";     TABblueH="${TAB}${blueH}"
    purple='\033[0;35m'; purpleH='\033[1;35m'; TABpurple="${TAB}${purple}"; TABpurpleH="${TAB}${purpleH}"
      cyan='\033[0;36m';   cyanH='\033[1;36m';   TABcyan="${TAB}${cyan}";     TABcyanH="${TAB}${cyanH}"
      gray='\033[0;37m';   white='\033[1;37m';   TABgray="${TAB}${gray}";     TABgrayH="${TAB}${grayH}"
    colorReset='\033[0m' # No Color
}
set_colors


#########################################################
# trap ctrl-c and call ctrl_c()
#########################################################
trap ctrl_c INT
function ctrl_c() {
    echo "** Trapped CTRL-C"
    rCode=1
    exit 1
}


#########################################################
# variabili di base e lettura profile
#########################################################
function base_vars() {
    scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    scriptDir="$(dirname $scriptFPath)"
    scriptName="$(basename $scriptFPath .sh)" # remove extension
    # scriptName="$(basename $scriptFPath)" # contiene extension
    ETH0_IP=$(hostname -I | cut -d' ' -f1)
    host_name=$(hostname -s | tr '[:upper:]' '[:lower:]')
    host_name=$(hostname -s); host_name=${host_name,,}

    #-------------------------------
    # -  P R O F I L E S
    #-------------------------------
    profile_data="${scriptDir}/${scriptName}_profiles.sh"
    [[ ! -f "$profile_data" ]] && echo "profile $profile_data not found!" && exit 1
    source $profile_data
}



#############################################
# Ex.: getFunctionList lnpi23
#############################################
function getFunctionList() {
    local prefix_str="@_$1"
    local suffix_str=''
    # declare -F| egrep "${prefix_str}" | cut -d' ' -f 3 | cut -d'_' -f 2- | xargs -I % sh -c "echo -n \"${TAB}${TAB}profile: \"; echo %"
    local functions=$(declare -F | egrep  ${prefix_str} | cut -d' ' -f 3)
    # echo $funcsList
    local funcsList=''
    for func_name in $functions; do
        profile_name=${func_name#"${prefix_str}"}
        profile_name=${profile_name#"${suffix_str}"}
        funcsList="$funcsList $profile_name"
    done
    echo $funcsList
}

########

function displayProfiles() {
    prefix_str='@_'
    suffix_str=''
    # declare -F| egrep "${prefix_str}" | cut -d' ' -f 3 | cut -d'_' -f 2- | xargs -I % sh -c "echo -n \"${TAB}${TAB}profile: \"; echo %"
    funcsList=$(declare -F | egrep  ${prefix_str} | cut -d' ' -f 3)
    echo $funcsList

    echo -e "${cyanH}"
    echo "${TAB}Profiles:"
    for func_name in $funcsList; do
        profile_name=${func_name#"${prefix_str}"}
        profile_name=${profile_name#"${suffix_str}"}
        echo "${TAB} $profile_name"
    done
    echo -e "${colorReset}"
    echo
}

#############################################
#
#############################################
function syntax() {
    echo -e "$TAByellowH    syntax $(basename $BASH_SOURCE) profile_name [options..]"
    echo -e "${cyanH}"
    echo "${TAB}Options:"
    echo "${TAB}${TAB}-h|--help    this help"
    echo "${TAB}${TAB}--go         execute commands"
    echo "${TAB}${TAB}--test       execute commands with dry-run option"
    echo "${TAB}${TAB}--reverse    rsync remoteHost --> localHost"
    echo "${TAB}${TAB}--delete     delete not synched files..."
    echo -e "${colorReset}"
    displayProfiles '@_'
    echo
    exit 1
}



#############################################
#
#############################################
function parseInput() {
    local args=$*
    echo "${TAB}command line: $args"
    [[ -z $args ]] && syntax
    EXCLUDE=""
    g_fEXECUTE=0
    g_fREVERSE=0
    g_DRY_RUN='--dry-run'
    g_TEST=0
    rSync_DELETE=
    rSync_SSH_Options=
    g_fNOPROMPT=


    # check rhe word and remove it from args
    https://tldp.org/LDP/abs/html/parameter-substitution.html
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''
    word='--noprompt'; [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fNOPROMPT=1
    word='--test';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_TEST=1
    word='--reverse';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fREVERSE=1
    word='--delete';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && rSync_DELETE="--delete-after"

    if [[ $g_TEST -eq 1 ]]; then
        g_fEXECUTE=1
        g_DRY_RUN='--dry-run'
    fi

    g_Args=$(echo $args) # remove BLANKs
    echo "${TAB}input args:   $g_Args"
    echo
}


#############################################
# esegui con pause
#############################################
function displayCommand() {
    local PAUSE=$1
    local CMD_DESCR=$2
    local cmd=$3

    echo -e -n "${colorReset}"

    echo -e "${TABcyanH}${CMD_DESCR}${colorReset}"
    echo -e "${TABpurpleH}[$g_DRY_RUN]$cyanH: $cmd ${colorReset}"
    if [[ "$PAUSE" -eq "1" ]]; then
        echo
        echo -e "${TABpurpleH}  enter to skip....(eXit|Quit|Process)$colorReset"
        read choice
        [[ "${choice,,}" == 'q' || "${choice,,}" == 'x' ]] && exit
        [[ "${choice,,}" != 'p' ]] && return
        echo
    fi
}

#############################################
# esegui con pause
#############################################
function eseguiCmd1() {
    local PAUSE=$1
    local CMD_DESCR=$2
    local cmd=$3
    # displayCommand $*
    displayCommand "$PAUSE" "$CMD_DESCR" "$cmd"

    eseguiCmd_retVal=
    eseguiCmd_rcode=

    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        ret_val=$($CMD)
        rCode=$?
        echo -e "${TABpurpleH}${TAB}${TAB}rcode=$rCode${colorReset}"
        [[ "$rCode" -ne 0 ]] && exit $rCode
        eseguiCmd_retVal=$ret_val
        eseguiCmd_rcode=$rCode
    else
        eseguiCmd_retVal=$g_DRY_RUN
        eseguiCmd_rcode=0
    fi
    echo
}


#############################################
# esegui con pause
#############################################
function eseguiCmd2() {
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        eval $cmd
        rcode=$?
        echo -e "${TABpurpleH}${TAB}${TAB}rcode=$rcode${colorReset}"
        [[ "$rcode" -ne 0 ]] && exit $rcode
    fi
    eseguiCmd_rcode=$rcode
    echo
}

function set_pause() {
    echo -e "${TABpurpleH}  enter to continue....(x|q to exit)$colorReset"
    read choice
    [[ "$choice" == 'q' || "$choice" == 'x' ]] && exit
}


function @_laura() {
    sourceDir='/home/brother_printer'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}

function @_silvia() {
    sourceDir='/home/brother_printer'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}

function @_elena() {
    sourceDir='/home/brother_printer'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}

function @_brother_printer() {
    sourceDir='/home/brother_printer'
    [[ "$hostname_lower" == 'lnpi31' ]] && mainDestDir='/mnt/Toshiba_1TB_LnDisk'
}



#################################################
# M A I N
#################################################
    base_vars
    g_FUNCTIONS=$(getFunctionList)
    echo $g_FUNCTIONS



    set -u # check undefined variables
    parseInput $@
    echo $g_Args
    g_profile_name=$1

    # --------------------------
    # Read profile_name
    # --------------------------
    "${g_profile_name}" >/dev/null 2>&1;rCode=$?
    if [ $rCode -ne 0 ] ; then
        echo
        echo -e "${TAB}redH Function $g_profile_name NOT found. (rCode: $rCode)"
        echo
        exit 1
    fi

