#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 23-07-2022 13.48.07
#========================================



#########################################################
# variabili di base e lettura profile
#########################################################
function base_vars() {
    scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    scriptDir="$(dirname $scriptFPath)"
    scriptName="$(basename $scriptFPath .sh)" # remove extension
    # scriptName="$(basename $scriptFPath)" # contiene extension
    # ETH0_IP=$(hostname -I | cut -d' ' -f1)
    # host_name=$(hostname -s | tr '[:upper:]' '[:lower:]')
    hostname=$(hostname -s); hostname=${hostname,,}
    DATE=$(date +'%d-%m-%Y %H:%M:%S')
    now=$(date "+%Y%m%d_%H%M")


    #-------------------------------
    # -  P R O F I L E S
    #-------------------------------
    local profile=0
    if [[ "$profile" -eq '1' ]]; then
        profile_data="${scriptDir}/${scriptName}_profiles.sh"
        [[ ! -f "$profile_data" ]] && echo "profile $profile_data not found!" && exit 1
        source $profile_data
    fi
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
function set_colors() {
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
set_colors

#############################################
# https://stackabuse.com/how-to-parse-command-line-arguments-in-bash/
# https://www.baeldung.com/linux/bash-parse-command-line-arguments
#############################################
function parseInput() {
    #############################################
    #
    #############################################
    function help() {
        echo -e "$TAByellowH    syntax $(basename $BASH_SOURCE) script_path [options]"
        echo -e "${cyanH}"
        echo "${TAB}Options:
            -h|--help           this help
            --host              remote_host
            --user              user name of remote host [default: $USER]
            --port              ssh port [defult: 22]
            --go                really execute commands
            --remote-args       argument to be passed remotely to the script [may be repeated more than one]
            "

        echo -e "${colorReset}"
        echo
        exit 2
    }


    g_host=''
    g_port='22'
    g_user="$USER"
    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'
    g_remote_args=''

    N_ARGUMENTS=$# # Returns the count of arguments that are in short or long options
    [[ "$N_ARGUMENTS" -lt 1 ]] && help

    # ':' argument is expected otherwise it's just a flag
    SHORT='h'
    LONG='host:,port:,user:,go,script:,remote-args:,help'
    VALID_ARGS=$(getopt -a -n ParseInput --options $SHORT --longoptions $LONG -- "$@")
    if [[ $? -ne 0 ]]; then
        exit 1;
    fi

    eval set -- "$VALID_ARGS"
    while [ : ]; do
        case "$1" in
            --host)
                shift
                g_host=$1
                ;;

            --port)
                shift
                g_port=$1
                ;;

            --user)
                shift
                g_user=$1
                ;;

            --remote-args)
                shift
                g_remote_args+=" $1"
                ;;

            --go)
                g_fEXECUTE=1
                g_DRY_RUN=''
                g_remote_args='--go'
                ;;

            -h | --help)
                help; ;;

            --)
                shift
                break
                ;;
            *)
                echo "Unexpected option: $1"; help; ;;
        esac

        shift # importante!!! skip $1 arg
    done

    echo -e "${colorReset}"
    echo -e "${TABgray}------[${hostname}]------------------------"

    [[ "$g_host" == 'local' ]] && g_user='' && g_port=''

    echo -e "${TABcyanH}host:         ${g_host}"
    echo -e "${TABcyanH}port:         ${g_port}"
    echo -e "${TABcyanH}user:         ${g_user}"
    echo -e "${TABcyanH}script:       ${g_script}"
    echo -e "${TABcyanH}fEXECUTE:     ${g_fEXECUTE}"
    echo -e "${TABcyanH}remote_args:  $g_remote_args"
    echo

}




#############################################
#
#############################################
function set_pause() {

    echo -e "${TABpurpleH}  please enter.... [$g_DRY_RUN]:
                x|q:        exit|quit
                <enter>:    process
                any key:    skip this
                ${colorReset}"
    read choice



    case "$choice" in
        '')
            choice='p'
            ;;
        x|q)
            exit 1
            ;;
        *)
            echo "[${choice}]: skipping"
            ;;

    esac

}




#############################################
# esegui con pause
#############################################
function esegui() {
    local _cmd_descr=$1
    local _cmd=$2

    echo -e "${TABcyanH}${_cmd_descr}${colorReset}"
    echo -e "${TABpurpleH}[${g_DRY_RUN}]$cyanH: $_cmd ${colorReset}"

    eseguiCMD_retVal=
    eseguiCMD_rcode=

    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        ret_val=$(eval $_cmd); rcode=$?
        [[ "$rcode" -ne 0 ]] && echo -e "${TABpurpleH}${TAB}${TAB}rcode=$rcode${colorReset}" && exit $rcode
    else
        ret_val=$g_DRY_RUN
        rcode=0
    fi

    eseguiCMD_retVal=$ret_val
    eseguiCMD_rcode=$rcode
    echo -e "${TAByellowH}rcode:   $eseguiCMD_rcode"
    echo -e "${TAByellowH}ret_val: $eseguiCMD_retVal"

}





#########################################
# call:
#  "__REMOTE_EXEC "192.168.1.23" "pi" "${ln_SCRIPTS_DIR}/crontab/crontab_update_devel.sh" "=" "
#########################################
function __REMOTE_EXEC() {
    local line="$@"
    local remote_host remote_port remote_user src_file
    IFS=',' read -r  remote_host remote_port remote_user src_file remote_args<<< ${line}
    fname=$(basename $src_file)
    dst_file="/tmp/$fname"

    local hostname=$(hostname -s); hostname=${hostname,,}
    local ip_addr=$(hostname -I | cut -d' ' -f1)
    local ip_addr=$(hostname -I)

    if [[ "$remote_host" == "$hostname" || " $ip_addr " == *" $remote_host "* ]]; then
        ${src_file} "$@"
    else
        BASE_SSH="-o ConnectTimeout=10 -i $ln_tunnel_ssh_key"
        SCP_CMD="/usr/bin/scp -P ${remote_port} -p ${BASE_SSH} ${src_file} ${remote_user}@${remote_host}:${dst_file}" # scrive nella HOME
        esegui "Transferring file to remote" "${SCP_CMD}"
        SSH_CMD="/usr/bin/ssh -p ${remote_port} ${BASE_SSH} ${remote_user}@${remote_host}"
        esegui "Executing script remotely" "${SSH_CMD} ${dst_file} $remote_args"
    fi
}



#################################################
# M A I N
# 1. Save current crontab in .ln/config
# 2. display differences of new crontab with current
# 2. if diff != 0 load new crontab
#################################################
    base_vars
    g_script=$1
    shift 1
    parseInput "$@"
    set_pause
    [[ "$choice" == "p" && "$g_fEXECUTE" -eq "1" ]] && echo -e "${TAByellowH} working on dir: ${remote}${colorReset}" && ${CMD}

    ln_tunnel_ssh_key="$HOME/.ssh/ln_tunnel_ed25519"
    __REMOTE_EXEC "${g_host}, ${g_port}, ${g_user}, ${g_script}, ${g_remote_args}"

