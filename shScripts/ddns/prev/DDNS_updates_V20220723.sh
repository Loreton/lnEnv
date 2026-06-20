#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 29-07-2022 16.43.49
#========================================
# /home/loreto/lnprofile/scripts/ddns/ddns_update.sh

# duckdns: https://www.duckdns.org/spec.jsp
    # You can update your domain(s) with a single HTTPS get to DuckDNS
    # https://www.duckdns.org/update?domains={YOURVALUE}&token={YOURVALUE}[&ip={YOURVALUE}][&ipv6={YOURVALUE}][&verbose=true][&clear=true]
    # The domain can be a single domain - or a comma separated list of domains.
    # The domain does not need to include the .duckdns.org part of your domain, just the subname.
    # If you do not specify the IP address, then it will be detected - this only works for IPv4 addresses
    # You can put either an IPv4 or an IPv6 address in the ip parameter
    # If you want to update BOTH of your IPv4 and IPv6 records at once, then you can use the optional parameter ipv6
    # to clear both your records use the optional parameter clear=true


# Q: can I script my own update?
# A: yes you can do this on http or https.
    # you can comma separate the domains if you want to update more than one,
    # the ip parameter is optional, if you leave it blank we detect your gateway ip
    # https://www.duckdns.org/update?domains=ben&token=064a0540-864c-4f0f-8bf5-23857452b0c1&ip=
    # see the spec page for all the details and options.

my_ddns_domains='
    MACHINE         IFC_NAME    PROVIDER    DOMAIN_NAME                 TOKEN
    sample          -           freedns     casettaHA.crabdance.com     http://freedns.afraid.org/dynamic/update.php?NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjE5OTkxMjAy
    sample          -           freedns     beverinoA07.crabdance.com   https://freedns.afraid.org/dynamic/update.php?NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTcw

    router_pina     eth0        freedns     beverinoA09.crabdance.com   NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTY3
    router_wind     eth0        freedns     beverinoA07.crabdance.com   NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTcw
    router_silvia   eth0        freedns     nsilvia.crabdance.com       NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjMy

    lnpi31          eth0        duckdns     lncasetta.duckdns.org       98fa7c37-21c7-43b2-92d2-822560984579
    lnpi31          eth0        duckdns     lnmqtt.duckdns.org          98fa7c37-21c7-43b2-92d2-82256098457

    ubuntu-silvia   enp2s0f0    freedns     casettaHA.crabdance.com     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTgzODcz
    lnpi41          eth0        freedns     casettaHA.crabdance.com     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTgzODcz
    xxxxxx          eth0        freedns     lhivemqn.crabdance.com      NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjE5OTkxMjAy
    lnpi23          eth0        freedns     lncasetta.crabdance.com     NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjM2
    lnpi23          eth0        freedns     lnmqtt.crabdance.com        NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4Njgx
    lnpi23          eth0        freedns     lncasetta.mooo.com          NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4NjIy
    lnpi23          eth0        freedns     nloreto.mooo.com            NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjY5
'


#########################################################
# trap ctrl-c and call ctrl_c()
#########################################################
trap ctrl_c INT
function ctrl_c() {
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


#############################################
#
#############################################
function syntax() {
    echo -e "$TAByellowH    syntax $(basename $BASH_SOURCE) profile_name [options..]"
    echo -e "${cyanH}"
    echo "${TAB}Options:"
    echo "${TAB}${TAB}-h|--help    this help"
    echo "${TAB}${TAB}--go         execute commands"
    # echo "${TAB}${TAB}--eth0       use eth0 interface"
    # echo "${TAB}${TAB}--wlan0      use wlan0 interface"
    echo -e "${colorReset}"
    displayProfiles '@_'
    echo
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
    g_ETH0_IP=$(hostname -I | cut -d' ' -f1)
    # local host_name=$(hostname -s | tr '[:upper:]' '[:lower:]')
    local this_hostname=$(hostname -s)
    g_hostname=${this_hostname,,}
    # g_hostname='lnpi41'
    DATE=$(date +'%d-%m-%Y %H:%M:%S')


    #-------------------------------
    # -  P R O F I L E S
    #-------------------------------
    # profile_data="${scriptDir}/${scriptName}_profiles.sh"
    # [[ ! -f "$profile_data" ]] && echo "profile $profile_data not found!" && exit 1
    # source $profile_data
}



#############################################
#
#############################################
function getProfilesList() {
    prefix_str='@_'
    suffix_str=''
    # declare -F| egrep "${prefix_str}" | cut -d' ' -f 3 | cut -d'_' -f 2- | xargs -I % sh -c "echo -n \"${TAB}${TAB}profile: \"; echo %"
    funcsList=$(declare -F | egrep  ${prefix_str} | cut -d' ' -f 3)

    profilesList=''
    for func_name in $funcsList; do
        profile_name=${func_name#"${prefix_str}"}
        profile_name=${profile_name#"${suffix_str}"}
        profilesList="$profilesList $profile_name"
    done
    echo $profilesList
}

#############################################
#
#############################################
function displayProfiles() {
    echo -e "${cyanH}"
    echo "${TAB}Valid Profiles:"
    for profile_name in $g_PROFILES; do
        echo "${TAB}${TAB}${profile_name}"
    done
    echo -e "${colorReset}"
    echo
}


#############################################
#
#############################################
function parseInput() {
    local args=$*
    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'
    g_VERBOSE=0

# sudo lshw -C network | grep "logical name"
# ip a s| grep "MULTICAST"


    # check rhe word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--verbose';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_VERBOSE=1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''

    g_Args=$(echo $args) # remove BLANKs
    echo
}






#############################################
# esegui con pause
#############################################
function getPause() {
    local _pause=$1
    if [[ "$_pause" -eq "1" ]]; then
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
function displayCommand() {
    local _pause=$1
    local _cmd_descr=$2
    local cmd=$3

    echo -e "${colorReset}"
    echo -e "${TABgray}------------------------------"

    echo -e "${TABcyanH}${_cmd_descr}${colorReset}"
    echo -e "${TABpurpleH}[$g_DRY_RUN]$cyanH: $cmd ${colorReset}"
    getPause $_pause
}


#############################################
# esegui con pause
#############################################
function eseguiCMD() {
    local _pause=$1
    local _cmd_descr=$2
    local _cmd=$3

    displayCommand "$_pause" "$_cmd_descr" "$_cmd"

    eseguiCMD_retVal=
    eseguiCMD_rcode=

    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        ret_val=$($_cmd); rcode=$?
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






##########################################
# Legge i nomi delle interfacce di rete e crea
# una array: ifc_name:ifc_addr
##########################################
function getInterfaces() {
    g_interfaces=()

    NMCLI=$(which nmcli)
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
    local _logfile="/tmp/myIP_ddns_${g_hostname}"

    echo >${_logfile}
    echo " ------------ ${g_hostname} - $DATE ------------------" >>${_logfile}
    echo >>${_logfile}


    for interface in ${g_interfaces[@]}; do
        IFS=':' read -r ifc_name ifc_addr ext_ip _rest <<< ${interface}
        echo "interface ${ifc_name}:" >>${_logfile}
        echo "      - Internal_IP: ${ifc_addr}" >>${_logfile}
        echo "      - External_IP: ${ext_ip}" >>${_logfile}
        echo >>${_logfile}
    done


    for server in ${g_DestServers[@]}; do
        local _cmd="/usr/bin/scp -o ConnectTimeout=10 -i $g_ssh_key ${_logfile} ${server}:" # scrive nella HOME
        eseguiCMD 0 "sending myIP to $server" "$_cmd"
    done
}

##########################################
#
# Non passo l'indirizzo IP perchÃÂ© uso l'interfaccia per inviare il curl
# DuckDns prende dinamicamente l'indirizzo IPv4
##########################################
function process_duckdns_provider() {
    local _ifc=$1
    local _domain=$2
    local _token=$3
    local forceIP='no'
    local _cmd=''

    local URL="https://www.duckdns.org/update?token=${_token}&domains=${_domain}"

    if [ "$forceIP" == "no" ]; then
        _cmd="--connect-timeout 5 --interface ${_ifc} --silent --show-error ${URL}"
    else
        _cmd="--connect-timeout 5                     --silent --show-error ${URL}&ip=${external_IP}"
    fi

    eseguiCMD 0 "DuckDns ${_domain} update" "$g_curlCMD $(echo $_cmd)"
    # echo -e "${TAByellowH}rCode:   $eseguiCMD_rcode"
    # echo -e "${TAByellowH}ret_val: $eseguiCMD_retVal"
}


##########################################
#
##########################################
function process_freedns_provider() {
    local line=$@
    # sul sito RICORDARSI di mettere: DynamicDNS -> Link supdates of the same IP together? Currently UN-Linked OFF
    # sul sito RICORDARSI di mettere: DynamicDNS -> Link updates of the same IP together? Currently UN-Linked OFF
    # sul sito RICORDARSI di mettere: DynamicDNS -> Link updates of the same IP together? Currently UN-Linked OFF
    # sul sito altrimenti con uno qualsiasi si aggiornano tutti
    local _ifc _domain _token _ext_ip_addr

    IFS=' ' read -r _ifc _domain _token _ext_ip_addr <<< $line
    # local _ifc=$1
    # local _domain=$2
    # local _hash=$3
    local forceIP='yes'
    local _cmd=''
    local URL="https://freedns.afraid.org/dynamic/update.php?${_token}" # hash ÃÂ¨ specifico del dominio
    
    [[ "$forceIP" == "no" ]] &&  _cmd="--connect-timeout 5 --interface ${_ifc}  --silent --show-error $URL"
    [[ "$forceIP" == "yes" ]] && _cmd="--connect-timeout 5 --silent --show-error ${URL}&address=${_ext_ip_addr}"
    eseguiCMD 0 "FreeDns ${_domain} update" "$g_curlCMD $(echo $_cmd)"
}







##################################################
# process line of mydata
#   provider       domain              token
#   -------       --------              --------
#   duckdns    rm-pina.duckdns.org    98fa7c37-21c7-43b2-92d2-822560984579
##################################################
function processLine() {
    local _domain_line=$@
    # split line
    IFS=' ' read -r _ifc _provider _domain _token _ip_addr _ext_ip_addr <<< $_domain_line


    # utilizzo alwaysdata per risolvere il nome per non incorrene in nomi locali....
    local _host_cmd="ssh -i $g_ssh_key ${g_DestServers[0]} host ${_domain}"
    local curr_domain_address=$($_host_cmd  | grep "has address" | cut -d' ' -f4)

    echo
    if   [[ -z "${curr_domain_address}" ]]; then
        echo -e "${TABpurpleH}${provider} ${_domain} not resolved"
        echo -e "${TABpurpleH}${provider} ${_domain} curr: ${_ext_ip_addr} - new: ${curr_domain_address} - going to update"
        process_${provider}_provider ${_ifc} ${_domain} ${_token}

    elif [[ "${curr_domain_address}" == "${_ext_ip_addr}" ]]; then
        echo -e "${TABpurpleH}${_provider} ${_domain} curr: ${_ext_ip_addr} - not to be changed"

    elif [[ "${curr_domain_address}" == *"192.168.1."* ]]; then
        echo -e "${TABpurpleH}${_provider} ${_domain} ${curr_domain_address} - it's a local IP. skipping..."

    else
        echo -e "${TABpurpleH}${_provider} ${_domain} curr: ${curr_domain_address} - new: ${_ext_ip_addr} - going to update"
        process_${_provider}_provider "${_ifc} ${_domain} ${_token} ${_ext_ip_addr}"
    fi
}



##########################################
#    M A I N
##########################################
    base_vars
    # echo $g_hostname
    g_DestServers=('loreton@ssh-loreton.alwaysdata.net' 'loreto@tty.sdf.org')
    g_ssh_key="$HOME/.ssh/ln_tunnel_ed25519"
    g_curlCMD=$(which curl)

    parseInput $*


    # ---------------------------------------------------------
    # - Reading data
    # ---------------------------------------------------------
    getInterfaces
    set -u
    getExternalIPs
    saveMyIpAddresses



    # ---- M A I N    L O O P -----
    readarray arrayDomains < <(printf '%s\n' "$my_ddns_domains")

    for line in "${arrayDomains[@]}"; do
        line=$(echo $line) # trim BLANKs
        [[ -z $line ]] && continue
        #IFS=: read -r domain_line machine ifc provider domain _token _rest <<< $line

        IFS=' ' read -r machine ifc provider domain token _rest <<< $line
        # [[ $machine != "$g_hostname" ]] && echo -e "${TABgray}skipping line: $line" && continue
        if [[ $machine != "$g_hostname" ]]; then
            [[ $g_VERBOSE -eq 1 ]] && echo -e "${TABgray}skipping line: $line"
            continue
        fi

        [[ $g_VERBOSE -eq 1 ]] && echo -e "${TABgrayH}processing line: $line"
        for interface in ${g_interfaces[@]}; do
            IFS=':' read -r ifc_name ifc_addr ext_ip _rest <<< ${interface}
            if [[ "$ifc_name" == "$ifc" ]]; then
                # [[ ! -z $line ]] && processLine $line
                processLine "$ifc $provider $domain $token $ifc_addr $ext_ip"
            fi
        done


    done

    exit


