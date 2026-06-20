#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 08-02-2026 09.20.26
#========================================

source "$HOME/.loreto_setup" 0 ###. per ln_HOST_CONFIG_DIR, colors

ln_version="${BASH_SOURCE[0]}\n    version V2026-02-08_092026"

#########################################################
# variabili di base e lettura profile
#########################################################
function base_vars() {
    # source "${set_Main_Variables}" ### >/dev/null
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





#############################################
#
#############################################
function parseInput() {
    local args=$*
    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'
    # check rhe word and remove it from args
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''
    word='--version';  [[ " $args " == *" $word "* ]] && echo -e "\n      $ln_version\n" && exit 0

    args=$(echo $args) # remove BLANKs
    g_Args=$(echo $args) # remove BLANKs

}


########################################
#
########################################
function displayDiff() {
    local new_crontab=$1
    local temp_crontab='/tmp/_crontab_tmp.conf'

    local saved_EXECUTE=$g_fEXECUTE
    $CRONTAB_BIN -l >${temp_crontab}

    echo
    echo -e "${cyanH}----------- diff result ------------------------------------"
    diff_options='--ignore-case --ignore-space-change --ignore-blank-lines --text'
    diff_options='--ignore-space-change --ignore-blank-lines --text'
    # /usr/bin/diff $diff_options "${temp_crontab}" "${crontab_dir}/crontab.conf"
    echo -e "${TABgreen}diff "${temp_crontab}" "${new_crontab}"${green}"
    /usr/bin/diff $diff_options "${temp_crontab}" "${new_crontab}"; diff_rcode=$?
    # xx=$(/usr/bin/diff $diff_options "${temp_crontab}" "${new_crontab}"); diff_rcode=$?
    # echo $xx
    echo -e "${TAByellowH}rcode: $diff_rcode"
    echo -e "$cyanH------------------------------------------------------------"
    echo -e $colorReset
    g_fEXECUTE=$saved_EXECUTE
}

#############################################
# esegui con pause
#############################################
function esegui() {
    local _cmd_descr=$1
    local _cmd=$2


    echo -e "${colorReset}"
    echo -e "${TABgray}------[${hostname_lc}]------------------------"
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




#################################################
# M A I N
# 1. Save current crontab in .ln/config
# 2. display differences of new crontab with current
# 2. if diff != 0 load new crontab
#################################################
    host_name=$(hostname -s) && hostname_lc=${host_name,,}

    base_vars
    parseInput "$@"

    source_crontab_file="${ln_HOST_CONFIG_DIR}/crontab/crontab.conf"
    [[ ! -f "$source_crontab_file" ]] && echo -e "${TABredH}file ${source_crontab_file} not found!" && exit 1

    crontab_backup_file="/tmp/crontab/crontab_${now}.conf"
    mkdir -p $(dirname $crontab_backup_file)

    backup_dir=$(dirname $crontab_backup_file)
    [[ ! -d "$backup_dir" ]] && echo -e "${TABredH}directory ${backup_dir} not exists!" && exit 1

    CRONTAB_BIN=$(which crontab)
    esegui "save current crontab" "$CRONTAB_BIN -l >${crontab_backup_file}"
    displayDiff "${source_crontab_file}" "${crontab_backup_file}"
    if [[ "$diff_rcode" -ne "0" ]]; then
        esegui "load new crontab" "$CRONTAB_BIN ${source_crontab_file}"
    else
        echo -e "${TABgreen}No differences found...crontab is not changed"
        echo
    fi