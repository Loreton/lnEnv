#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 16-10-2022 08.38.40
#

#############################################
# M A I N
# args: None
#############################################
    hostname=$(hostname -s); hostname_lower=${hostname,,}
    ip_addresses=$(hostname -I)
    DATE=$(date +'%d-%m-%Y %H:%M:%S')

    set -u
    case $hostname_lower in
        lnpi41)
            IP="192.168.1.41"
            restart_command="sudo systemctl restart dhcpcd.service"
        ;;
        lnpi31)
            IP="192.168.1.31"
            restart_command="sudo systemctl restart dhcpcd.service"
        ;;
        lnpi23)
            IP="192.168.1.23"
            restart_command="sudo systemctl restart dhcpcd.service"
        ;;
        lnpi22)
            IP="192.168.1.22"
            restart_command="sudo systemctl restart dhcpcd.service"
        ;;

        ubuntu-silvia)
            IP="192.168.1.xx"
            restart_command="echo scoprire il comando per $hostname "
        ;;

        *)
            IP="-1"
            restart_command="echo Host non definito"
        ;;

    esac

    if [[ " $ip_addresses " != *" $IP "* ]]; then
        echo "$DATE - $restart_command"
        $restart_command
    else
        echo "$DATE - $IP is right: $ip_addresses"
    fi