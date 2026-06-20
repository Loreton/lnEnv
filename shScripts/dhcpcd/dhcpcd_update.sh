#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 29-08-2023 09.19.27
#========================================
# /home/loreto/lnprofile/scripts/ddns/DDNS_updates.sh

# WLAN
# sudo iwlist wlan0 scan
# sudo ifconfig wlan0 up
# sudo iwlist wlan0 scan

# iwgetid  - get current SSID
# iwconfig - get current SSID and configuration

# ---- wpa_cli
# wpa_cli -i wlan0 reconfigure      - reload wpa_supplicant
# wpa_cli -i wlan0 list_networks    - list of configured networks
# wpa_cli -i wlan0 select_network 2 - select network 2 WARNING Using select_network disables until next boot all other Wifis.


source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null

#############################################
#
#############################################
function @_esegui() {
    CMD_DESCR=$1
    cmd=$2

    echo -e "${TABcyanH} ${CMD_DESCR}${colorReset}"
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        echo -e "${TABpurpleH} [executing]$yellowH: $cmd ${colorReset}"
        eval $cmd
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && echo "rcode=$rCode" && exit $rCode
    else
        echo -e "${TABpurpleH} [dry-run]$yellowH: $cmd ${colorReset}"
    fi
    echo
    CMD_DESCR=
}



set +u
function syntax() {
    echo
    echo '  Syntax:'
    echo '     configuration type:'
    echo '          - arping_fallback' # try arping else fallback to static
    echo '          - dhcp_fallback'    # try dhcp else fallback to static
    echo '          - dhcp'
    echo '          - static'
    echo '          - eth0_subs'
    echo
    echo '     action:         --go'
    echo
    echo '  Ex.: static --go'
    echo
    exit
}




function create_dhcpcd_link() {
    filename=$1
    _dir=$PWD
    cd /etc
    CMD="sudo ln -sf "${filename}" "/etc/dhcpcd.conf""
    @_esegui "create dhcpcd link" "$CMD"
    cd $_dir
}

function dhcpcd_files() {
    local key=$1

    if [[ "$key" == "arping_fallback" ]]; then
        fname='arping_fallback.conf'
        src_file="${host_CONFIG_DIR}/${fname}"; dst_file="/etc/ln_${fname}"
        CMD="sudo cp -pv "${src_file}" "${dst_file}""
        @_esegui "copy arping_fallback file" "$CMD"
        create_dhcpcd_link "${dst_file}"

    elif [[ "$key" == "dhcp_fallback" ]]; then
        fname='dhcp_fallback.conf'
        src_file="${host_CONFIG_DIR}/dhcp_fallback.conf"; dst_file="/etc/ln_${fname}"
        CMD="sudo cp -pv "${src_file}" "${dst_file}""
        @_esegui "copy dhcp_fallback file" "$CMD"
        create_dhcpcd_link "${dst_file}"

    elif [[ "$key" == "dhcp" ]]; then
        fname='dhcp.conf'
        csrc_file="${host_CONFIG_DIR}/dhcp.conf"; dst_file="/etc/ln_${fname}"
        CMD="sudo cp -pv "${src_file}" "${dst_file}""
        @_esegui "copy dhcp file" "$CMD"
        create_dhcpcd_link "${dst_file}"

    elif [[ "$key" == "static" ]]; then
        fname='static.conf'
        src_file="${host_CONFIG_DIR}/${fname}"; dst_file="/etc/ln_${fname}"
        CMD="sudo cp -pv "${src_file}" "${dst_file}""
        @_esegui "copy static file" "$CMD"
        create_dhcpcd_link "${dst_file}"


    elif [[ "$key" == "eth0_subs" ]]; then
        fname='eth0-subs'
        src_file="${host_CONFIG_DIR}/${fname}"; dst_file="/etc/network/interfaces.d/eth0-subs"
        CMD="sudo cp -pv "${src_file}" "${dst_file}""
        @_esegui "copy eth0_subs file" "$CMD"
    else
        syntax
    fi

}





##################################################ÃÂ 
#
##################################################ÃÂ 
    args="$@"
    set -u
    hostname=$(hostname -s)
    host_name=${hostname,,}
    g_fEXECUTE=0
    word='--go';   [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1
    g_Args=$(echo $args) # remove BLANKs

    nargs=$#
    [[ $nargs -lt 1 ]] && syntax

    host_CONFIG_DIR="${ln_HOST_CONFIG_DIR}/dhcpcd"
    dhcpcd_files $g_Args

    echo -e "${TABpurpleH}
        -----------------------------------------
        sudo systemctl restart dhcpcd.service
        sudo journalctl --boot --unit dhcpcd
        grep eth /var/log/syslog
        tail -f /tmp/dhcpcd.log
        ip -br a
        -----------------------------------------
        ${colorReset}"
