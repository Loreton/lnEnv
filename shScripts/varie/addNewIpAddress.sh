#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 30-11-2025 09.54.52
#

source ${HOME}/filu/lnEnv/init/main/setLoretoEnvironment
fLOG=1
# /home/loreto/filu/lnEnv/init/commonFunctions/colors.functions
# /home/loreto/filu/lnEnv/init/commonFunctions/ln_log.functions
# /home/loreto/filu/lnEnv/init/commonFunctions/esegui.functions
# source "${ln_SET_LORETO_ENVIRONMENT}" 



#========================================
#
#========================================
function validate_ipaddress() {
    local ip=${1:-1.2.3.4}

    if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
      echo "success"
    else
      echo "fail"
    fi
}


#========================================
#
#========================================
function add_ipaddress() {
    # local req_ip='192.168.1.22'
    local ifc=$1
    local req_ip=$2

    addresses=$(hostname -I)

    if [[ " $addresses " == *" ${req_ip} "* ]]; then
        CMD='ip -br a'
         @lnEsegui "$CMD"
    else
        CMD="sudo /sbin/ip addr add ${req_ip}/24 dev ${ifc} label ${ifc}:5"
         @lnEsegui "$CMD"
         @lnEsegui "$CMD"
        CMD="sudo systemctl restart dhcpcd.service"
         @lnEsegui "$CMD"
    fi
}


#############################################
# -
#############################################
function parseInput() { # solo per console
    args=$@

    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && fEXECUTE="--go"

    g_rest_arguments=$(echo $args) # strip text
}


###########################################################
#  M A I N
#  input:
#       interface name:  eth0, enp2s0f0, ...
#       ip address:      192.168.1.99
###########################################################
    export fEXECUTE="dry-run"
    ifc="${1:-enxd0c0bf2f6bf1}"
    new_ip="${2:-1.2.3.4}"

    DATE=$(date +'%d-%m-%Y %H:%M:%S')
    echo "\n\n\n"
    @lnLog "${cyanH}-------------------------------------------------"
    @lnLog "${cyanH}---------- [${DATE}]"
    @lnLog "${cyanH}-------------------------------------------------"
    echo
    parseInput "$@"
    set -u
    # ifc=$1
    # new_ip=$2
    isValid=$(validate_ipaddress $new_ip)
    if [[ $isValid == 'fail' ]]; then
        echo
        @lnLog "${redH}[${new_ip}] is not a valid ip address"
        echo
        exit 1
    fi

    add_ipaddress $ifc $new_ip