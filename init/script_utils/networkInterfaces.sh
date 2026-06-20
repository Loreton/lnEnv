#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 28-11-2025 18.48.41
# /home/loreto/lnprofile/shDevel/crontab/crontab_update.sh
#========================================

if ! declare -F @lnLog      > /dev/null; then source ln_log.functions; fi
if ! declare -F @setColors  > /dev/null; then source colors.functions; fi


##########################################
# Legge i nomi delle interfacce di rete e crea
# una array: g_interfaces = ifc_name:ifc_addr
# utile nel caso qualcuno ne avesse bisogno
##########################################
function getExternalInternalAddresses() {
    g_curlBIN=$(which curl)
    run_time=$(date "+%d.%m.%Y %H:%M:%S")

    g_interfaces=()
    @lnLog "${yellowH}-----------------------------------${colorReset}"
    @lnLog "${yellowH}--- ${run_time}${colorReset}"
    @lnLog "${yellowH}--- checking network interfaces${colorReset}"
    @lnLog "${yellowH}--- and internal/external IP addresses${colorReset}"
    @lnLog "${yellowH}-----------------------------------${colorReset}"

    ### -------------------------
    ### wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    ###     link/ether 90:00:4e:96:7f:4b brd ff:ff:ff:ff:ff:ff
    ### -------------------------
    local ifcs=$(ip a s | grep -i "state up" | grep -i "multicast" | cut -d' ' -f2 |cut -d':' -f1)

    for ifc_name in $ifcs; do
        ### capture internal IP
        inet_line=( $(ip addr show dev ${ifc_name}  | grep 'inet '))
        IFS='/' read -r ifc_internal_IP _mask <<< ${inet_line[1]} # get just IP address

        @lnLog "${green}interface_name: $ifc_name"
        @lnLog "${green}internal_IP:    $ifc_internal_IP"
        ### capture external IP
        local _cmd="--connect-timeout 5 --interface ${ifc_name}  --silent http://icanhazip.com/"
        @lnLog "${cyan}executing: $g_curlBIN $_cmd"
        local ifc_external_IP=$($g_curlBIN $_cmd)

        g_interfaces+=("${hostname_lc,,}:${ifc_name}:${ifc_internal_IP}:${ifc_external_IP}") # create array_entry
        @lnLog "${green}external_IP:    $ifc_external_IP"


        # data=$(nmcli --pretty device show ${ifc_name})
        data=$(nmcli device show ${ifc_name})
        while IFS= read -r line; do
            # echo -e "\t\t\t$line ..."
            @lnLog "${purpleH}${line}"
        done <<< "$data"
        # echo $data
        echo
    done
}
getExternalInternalAddresses