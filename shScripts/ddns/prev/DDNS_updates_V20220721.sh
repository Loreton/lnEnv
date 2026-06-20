#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 21-07-2022 16.53.46
#========================================

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
    echo "${TAB}${TAB}--eth0       use eth0 interface"
    echo "${TAB}${TAB}--wlan0      use wlan0 interface"
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
    ETH0_IP=$(hostname -I | cut -d' ' -f1)
    host_name=$(hostname -s | tr '[:upper:]' '[:lower:]')
    this_hostname=$(hostname -s); host_name=${host_name,,}
    DATE=$(date +'%d-%m-%Y %H:%M:%S')


    #-------------------------------
    # -  P R O F I L E S
    #-------------------------------
    profile_data="${scriptDir}/${scriptName}_profiles.sh"
    [[ ! -f "$profile_data" ]] && echo "profile $profile_data not found!" && exit 1
    source $profile_data
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
    # echo "${TAB}command line: $args"
    [[ -z $args ]] && syntax
    g_FORCE=0
    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'
    g_IFC=
    g_DestServers=('loreton@ssh-loreton.alwaysdata.net' 'loreto@tty.sdf.org')
    g_ssh_key='/home/pi/.ssh/ln_tunnel_ed25519'


    # check rhe word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''
    word='--force';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_FORCE=1
    word='--eth0';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_IFC='eth0'
    word='--wlan0';    [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_IFC='wlan0'

    g_Args=$(echo $args) # remove BLANKs
    # echo "${TAB}input args:   $g_Args"
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
#
##########################################
function getMyIPs() {
    local _ifc=$1

    g_INTERNAL_IP=$(ip addr show ${_ifc} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

    if [ "$g_INTERNAL_IP" != "" ]; then
        local _cmd="--connect-timeout 5 --interface ${_ifc}  --silent http://icanhazip.com/"
        echo -e "${TABcyan}executing: /usr/bin/curl $_cmd"
        g_EXTERNAL_IP=$(/usr/bin/curl $_cmd)
        # g_EXTERNAL_IP='212.69.137.124' # DEBUG

    fi
    echo -e "${TAByellowH}current internal ${_ifc} ip address: ${g_INTERNAL_IP}"
    echo -e "${TAByellowH}current external ${_ifc} ip address: ${g_EXTERNAL_IP}"
    echo

}




function backupMyIpAddresses() {
    local _logfile="/tmp/myIP_ddns_${this_hostname}"
    local _ifc=$1

    # --------------- get external IP for specific interface

    echo >${_logfile}
    echo " ------------ ${this_hostname}-${_ifc} $DATE ------------------" >>${_logfile}
    echo >>${_logfile}

    # echo " --- check external IP address for interface: ${_ifc}" >>${_logfile}
    # echo >>${_logfile}
    # ip addr show ${_ifc} >>${_logfile}
    # echo >>${_logfile}

    echo "$Interface $_ifc" >>${_logfile}
    echo "      - Internal_IP: ${g_INTERNAL_IP}" >>${_logfile}
    echo "      - External_IP: ${g_EXTERNAL_IP}" >>${_logfile}
    echo >>${_logfile}


    for server in ${g_DestServers[@]}; do
        # echo -e "${TABgray}------------------------------"
        local _cmd="/usr/bin/scp -o ConnectTimeout=10 -i $g_ssh_key ${_logfile} ${server}:" # scrive nella HOME
        eseguiCMD 0 "sending myIP to $server" "$_cmd"
    done
}

##########################################
#
# Non passo l'indirizzo IP perchÃ© uso l'interfaccia per inviare il curl
# DuckDns prende dinamicamente l'indirizzo IPv4
##########################################
function duckdns_provider() {
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

    eseguiCMD 0 "DuckDns ${_domain} update" "/usr/bin/curl $(echo $_cmd)"
    # echo -e "${TAByellowH}rCode:   $eseguiCMD_rcode"
    # echo -e "${TAByellowH}ret_val: $eseguiCMD_retVal"
}


##########################################
#
##########################################
function freedns_provider() {
    # sul sito RICORDARSI di mettere: DynamicDNS -> Link supdates of the same IP together? Currently UN-Linked OFF
    # sul sito RICORDARSI di mettere: DynamicDNS -> Link updates of the same IP together? Currently UN-Linked OFF
    # sul sito RICORDARSI di mettere: DynamicDNS -> Link updates of the same IP together? Currently UN-Linked OFF
    # sul sito altrimenti con uno qualsiasi si aggiornano tutti
    # Dynamic DNS ->

    freedns_domains='
        sample          beverinoA07.crabdance.com https://freedns.afraid.org/dynamic/update.php?NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTcw
        router_wind     beverinoA07.crabdance.com      NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTcw
        router_pina     beverinoA09.crabdance.com      NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTY3
        xxxxxx          lhivemqn.crabdance.com         NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjE5OTkxMjAy
        lnpi23          lncasetta.crabdance.com        NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjM2
        lnpi23          lnmqtt.crabdance.com           NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4Njgx
        router_silvia   nsilvia.crabdance.com          NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjMy
        lnpi23          lncasetta.mooo.com             NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4NjIy
        lnpi23          nloreto.mooo.com               NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjY5
    '


    local _ifc=$1
    local _domain=$2
    local _hash=$3
    local forceIP='yes'
    local _cmd=''
    local URL="https://freedns.afraid.org/dynamic/update.php?${_hash}" # hash Ã¨ specifico del dominio
    
    [[ "$forceIP" == "no" ]] &&  _cmd="--connect-timeout 5 --interface ${_ifc}  --silent --show-error $URL"
    [[ "$forceIP" == "yes" ]] && _cmd="--connect-timeout 5 --silent --show-error ${URL}&address=${external_IP}"
    eseguiCMD 0 "FreeDns ${_domain} update" "/usr/bin/curl $(echo $_cmd)"
    # echo -e "${TAByellowH}rCode:   $eseguiCMD_rcode"
    # echo -e "${TAByellowH}ret_val: $eseguiCMD_retVal"
}







##################################################
# process line of mydata
#   provider       domain              token
#   -------       --------              --------
#   duckdns    rm-pina.duckdns.org    98fa7c37-21c7-43b2-92d2-822560984579
##################################################
function processLine() {
    local cur_line=$@
    firstChar="${cur_line:0:1}"
    # echo -e "${colorReset}"
    echo
    echo -e "${TABgray}------------------------------"
    [[ $firstChar == '#' ]] && echo -e "${TABgray}skipping line: $cur_line" && return

    local provider=$1
    local domain=$2
    local token=$3


    # utilizzo alwaysdata per risolvere il nome per non incorrene in nomi locali....
    local _host_cmd="ssh -i $g_ssh_key ${g_DestServers[0]} host ${domain}"
    local curr_domain_address=$($_host_cmd  | grep "has address" | cut -d' ' -f4)
    # echo


    if   [[ -z "$curr_domain_address" ]]; then
        echo -e "${TABpurpleH}${provider} ${domain} not resolved"
        echo -e "${TABpurpleH}$provider $domain curr: ${g_EXTERNAL_IP} - new: $curr_domain_address - going to update"
        ${provider}_provider $g_IFC $domain $token
        # echo

    elif [[ "$curr_domain_address" == "${g_EXTERNAL_IP}" ]]; then
        # echo -e "${TABgray}------------------------------"
        echo -e "${TABpurpleH}${provider} ${domain} curr: ${g_EXTERNAL_IP} - not to be changed"
        # echo

    elif [[ "$curr_domain_address" == *"192.168.1."* ]]; then
        # echo -e "${TABgray}------------------------------"
        echo -e "${TABpurpleH}${provider} ${domain} $curr_domain_address - it's a local IP. skipping..."
        # echo

    else
        echo -e "${TABpurpleH}$provider $domain curr: ${g_EXTERNAL_IP} - new: $curr_domain_address - going to update"
        ${provider}_provider $g_IFC $domain $token
        # echo
    fi
}



##########################################
#    M A I N
##########################################

    base_vars
    g_PROFILES=$(getProfilesList)
    echo $g_PROFILES
    parseInput $*


    # ----------------------
    # Read profile_name
    # --------------------------
    my_profile_name="@_${host_name}_${g_IFC}_domains"
    "${my_profile_name}" >/dev/null 2>&1;rcode=$?
    if [[ "$rcode" -ne "0" ]]; then
        echo -e "${TABredH}Function $my_profile_name NOT found in profile list. (rcode: $rcode)"
        displayProfiles
        exit $rcode
    fi


    # ---------------------------------------------------------
    # - Reading data
    # ---------------------------------------------------------
    # getExternalIP $g_IFC
    getMyIPs $g_IFC
    backupMyIpAddresses $g_IFC



    # ---- M A I N    L O O P -----
    readarray arrayDomains < <(printf '%s\n' "$_valid_domains")
    for line in "${arrayDomains[@]}"; do
        line=$(echo $line) # trim BLANKs
        [[ ! -z $line ]] && processLine $line
    done

    exit


