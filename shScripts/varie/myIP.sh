#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-11-2025 18.27.16
#

##########################################
# Legge i nomi delle interfacce di rete e crea
# una array: ifc_name:ifc_addr
##########################################
function getInterfaces() {
    g_interfaces=()

    NMCLI=$(which nmcli_xxx)
    if [[ ! -z $NMCLI ]]; then
        local ifcs=$(nmcli -g DEVICE,TYPE,STATE device status)
        for ifc in $ifcs; do
            IFS=: read -r ifc_name ifc_type ifc_state <<< $ifc
            if [[ $ifc_state == 'connected' ]]; then
                #--- inet 192.168.1.42/24 brd 192.168.1.255 scope global noprefixroute enp2s0f0
                inet_line=( $(ip addr show dev ${ifc_name}  | grep 'inet ')) # create array for the line
                IFS='/' read -r ip_addr _mask <<< ${inet_line[1]} # get just IP address
                g_interfaces+=("${ifc_name}:${ip_addr}") # create array_entry
                # echo ${g_interfaces[@]}
            fi
        done

    else
        local ifcs=$(ip link show | grep -i 'LOWER_UP' |grep -i 'MULTICAST' | cut -d' ' -f2 |cut -d':' -f1)
        for ifc_name in $ifcs; do
            #--- inet 192.168.1.42/24 brd 192.168.1.255 scope global noprefixroute enp2s0f0
            inet_line=( $(ip addr show dev ${ifc_name}  | grep 'inet ')) # create array for the line
            IFS='/' read -r ip_addr _mask <<< ${inet_line[1]} # get just IP address
            g_interfaces+=("${ifc_name}:${ip_addr}") # create array_entry
            # echo ${g_interfaces[@]}
        done

    fi
}




##########################################
#
##########################################
function getExternalIPs() {

    for i in ${!g_interfaces[@]}; do
        IFS=':' read -r ifc_name ifc_addr _rest <<< ${g_interfaces[$i]} # get just IP address
        local _cmd="--connect-timeout 5 --interface ${ifc_name}  --silent http://icanhazip.com/"
        echo -e "${TABcyan}executing: $g_curlCMD $_cmd"

        local external_IP=$($g_curlCMD $_cmd)
        g_interfaces[$i]="${ifc_name}:${ifc_addr}:${external_IP}"
            # g_EXTERNAL_IP='212.69.137.124' # DEBUG
        echo -e "${TAByellowH}interface_name: ${ifc_name}
                internal_IP: ${ifc_addr}
                esternal_IP: ${external_IP}"
        echo
    done

}

function saveMyIpAddresses() {
    local _logfile="/tmp/myIP_${hostname_lc}"

    echo >${_logfile}
    echo " ------------ ${hostname_lc} - $DATE ------------------" >>${_logfile}
    echo >>${_logfile}


    for interface in ${g_interfaces[@]}; do
        IFS=':' read -r ifc_name ifc_addr ext_ip _rest <<< ${interface}
        echo "interface ${ifc_name}:" >>${_logfile}
        echo "      - Internal_IP: ${ifc_addr}" >>${_logfile}
        echo "      - External_IP: ${ext_ip}" >>${_logfile}
        echo >>${_logfile}
    done


    for server in ${g_DestServers[@]}; do
        echo
        echo -e "${TABcyanH} sending myIP to $server${colorReset}"
        local _cmd="/usr/bin/scp -o ConnectTimeout=10 -i $g_ssh_key ${_logfile} ${server}:" # scrive nella HOME
        echo -e "${TABcyanH} $_cmd"
        $_cmd
        echo
    done
}






#############################################
# M A I N
#############################################
    source "${ln_SET_LORETO_ENVIRONMENT}" 0
    host_name=$(hostname -s); hostname_lc=${host_name,,}

    DATE=$(date +'%d-%m-%Y %H:%M:%S')
    echo "\n\n\n"
    echo -e "${TABcyanH}-------------------------------------------------"
    echo -e "${TABcyanH}------------------- [${DATE}]"
    echo -e "${TABcyanH}-------------------------------------------------"
    echo

    g_DestServers=('loreton@ssh-loreton.alwaysdata.net' 'loreto@tty.sdf.org')
    g_ssh_key="$HOME/.ssh/ln_tunnel_ed25519"
    g_curlCMD=$(which curl)
    getInterfaces
    getExternalIPs
    saveMyIpAddresses