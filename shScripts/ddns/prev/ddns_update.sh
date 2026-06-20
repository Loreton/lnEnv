#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.27.55
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

function my_Domains() { # mantenere almeno una riga BLANK tra un record e l'altro
        # DOMAIN_NAME             PROVIDER    TOKEN                                   MACHINE.IFC_NAME ...

    my_ddns_domains="
        lncasetta.duckdns.org   duckdns     98fa7c37-21c7-43b2-92d2-822560984579
                    ubuntu-silvia.enp2s0f0
                    lnpi41.eth0
                    lnpi31.eth0
                    lnpi23.eth0
                    lnpi22.eth0

        lnmqtt.duckdns.org      duckdns     98fa7c37-21c7-43b2-92d2-82256098457 \
                    ubuntu-silvia.enp2s0f0 \
                    lnpi41.eth0 \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0

        "
}
function my_Domains_full() {
    # important DQuote altrimenti non viene interpretato il '\'

    # per lncasetta, lnmqtt, rm-pina, rmloreto, rmpina
    duck_dns_TOKEN_529170567_twitter_loreto_pg='98fa7c37-21c7-43b2-92d2-822560984579'
    # ancora nulla...
    duck_dns_TOKEN_261207877_twitter_tw_loreto='98fa7c37-21c7-43b2-92d2-822560984579'

    windtre_pina_beverino07='user: Loreto, psw: Loreto.WindTre, domain: beverino.dyndns.it' # automatico dal router

        # DOMAIN_NAME             PROVIDER    TOKEN                                   MACHINE.IFC_NAME ...
    casetta_ddns_domains="


        lncasetta.duckdns.org   duckdns     ${duck_dns_TOKEN_529170567_twitter_loreto_pg} \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0 \
                    ubuntu-silvia.enp2s0f0

        lnmqtt.duckdns.org      duckdns     ${duck_dns_TOKEN_529170567_twitter_loreto_pg} \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0 \
                    ubuntu-silvia.enp2s0f0

        casettaHA.crabdance.com      freedns     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTgzODcz \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0 \
                    xxxu_buntu-silvia.enp2s0f0

        lncasetta.crabdance.com      freedns     NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjM2 \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0 \
                    ubuntu-silvia.enp2s0f0

        lnmqtt.crabdance.com      freedns     NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4Njgx \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0 \
                    ubuntu-silvia.enp2s0f0

        lncasetta.mooo.com      freedns     NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4NjIy \
                    lnpi31.eth0 \
                    lnpi23.eth0 \
                    lnpi22.eth0 \
                    ubuntu-silvia.enp2s0f0
        "

    beverino_ddns_domains="

        rmpina.duckdns.org   duckdns     ${duck_dns_TOKEN_529170567_twitter_loreto_pg} \
                    lnpi41.eth0 \
                    xxxu_buntu-silvia.wlp3s0

        rm-pina.duckdns.org   duckdns     ${duck_dns_TOKEN_529170567_twitter_loreto_pg} \
                    lnpi41.eth0 \
                    xxxu_buntu-silvia.wlp3s0

        rmloreto.duckdns.org   duckdns     ${duck_dns_TOKEN_529170567_twitter_loreto_pg} \
                    lnpi41.eth0 \
                    xxxu_buntu-silvia.wlp3s0

        beverinoA07.crabdance.com      freedns     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTcw \
                    lnpi41.eth0 \
                    xxxu_buntu-silvia.enp2s0f0

        beverinoA09.crabdance.com      freedns     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTY3 \
                    lnpi41.eth0 \
                    xxxu_buntu-silvia.enp2s0f0


        lhivemqn.crabdance.com      freedns     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjE5OTkxMjAy \
                    lnpi41.eth0 \
                    xxxxxu_buntu-silvia.enp2s0f0


        nloreto.mooo.com      freedns     NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjY5 \
                    lnpi41.eth0 \
                    xxxxu_buntu-silvia.enp2s0f0
        "

        my_ddns_domains="$casetta_ddns_domains $beverino_ddns_domains"
}




    # nsilvia.crabdance.com      freedns     NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjMy router_silvia.wan

    # beverinoA07.crabdance.com      freedns     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTcw router_wind_loreto.wan
    # beverinoA09.crabdance.com      freedns     NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTY2MTY3 router_wind_pina.wan


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
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null
    DATE=$(date +'%d-%m-%Y %H:%M:%S')

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


    # check the word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--verbose';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_VERBOSE=1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN='executing'

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

    echo -e "${TAByellowH}-----------------------------------"
    echo -e "${TAByellowH}--- checking eternal IP address ---"
    echo -e "${TAByellowH}-----------------------------------"

    for i in ${!g_interfaces[@]}; do
        IFS=':' read -r ifc_name ifc_addr _rest <<< ${g_interfaces[$i]} # get just IP address
        local _cmd="--connect-timeout 5 --interface ${ifc_name}  --silent http://icanhazip.com/"
        echo -e "${TABcyan}executing: $g_curlBIN $_cmd"

        local external_IP=$($g_curlBIN $_cmd)
        g_interfaces[$i]="${ifc_name}:${ifc_addr}:${external_IP}"
            # g_EXTERNAL_IP='212.69.137.124' # DEBUG
        echo -e "${TABgreen}interface_name: ${ifc_name}
                internal_IP: ${ifc_addr}
                esternal_IP: ${external_IP}"
        echo
    done
    echo

}




function saveMyIpAddresses() {
    local _workfile="/tmp/myIP_ddns_${g_hostname_lower}"

    echo >${_workfile}
    echo " ------------ ${g_hostname_lower} - $DATE ------------------" >>${_workfile}
    echo >>${_workfile}


    for interface in ${g_interfaces[@]}; do
        IFS=':' read -r ifc_name ifc_addr ext_ip _rest <<< ${interface}
        echo "interface ${ifc_name}:" >>${_workfile}
        echo "      - Internal_IP: ${ifc_addr}" >>${_workfile}
        echo "      - External_IP: ${ext_ip}" >>${_workfile}
        echo >>${_workfile}
    done


    for server in ${g_DestServers[@]}; do
        local _cmd="/usr/bin/scp -o ConnectTimeout=10 -i $g_ssh_key ${_workfile} ${server}:" # scrive nella HOME
        eseguiCMD 0 "sending myIP to $server" "$_cmd"
    done
}

##########################################
#
# Non passo l'indirizzo IP perché uso l'interfaccia per inviare il curl
# DuckDns prende dinamicamente l'indirizzo IPv4
##########################################
function process_duckdns_provider() {
    local line=$@
    local _ifc _domain _token _ext_ip_addr
    IFS=',' read -r _ifc _domain _token _ext_ip_addr <<< $line

    local forceIP='no'
    local _cmd=''

    local URL="https://www.duckdns.org/update?token=${_token}&domains=${_domain}&verbose&ip=${_ext_ip_addr}"

    if [ "$forceIP" == "no" ]; then
        _cmd="--connect-timeout 5 --interface ${_ifc} --silent --show-error ${URL}"
    else
        _cmd="--connect-timeout 5                     --silent --show-error ${URL}&ip=${_ext_ip_addr}"
    fi

    eseguiCMD 0 "DuckDns ${_domain} update" "$g_curlBIN $(echo $_cmd)"

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
    IFS=',' read -r _ifc _domain _token _ext_ip_addr <<< $line


    local forceIP='yes'
    local _cmd=''
    local URL="https://freedns.afraid.org/dynamic/update.php?${_token}" # hash è specifico del dominio

    [[ "$forceIP" == "no" ]] &&  _cmd="--connect-timeout 5 --interface ${_ifc}  --silent --show-error $URL"
    [[ "$forceIP" == "yes" ]] && _cmd="--connect-timeout 5 --silent --show-error ${URL}&address=${_ext_ip_addr}"
    eseguiCMD 0 "FreeDns ${_domain} update" "$g_curlBIN $(echo $_cmd)"
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
    local _ifc _provider _domain _token _ip_addr _ext_ip_addr
    IFS=' ' read -r _ifc _provider _domain _token _ip_addr _ext_ip_addr <<< $_domain_line


    # utilizzo tty.sdf per risolvere il nome per non incorrene in nomi locali....alwaysdata è lento nell'aggiornamento
    # local _host_cmd="ssh -i $g_ssh_key ${g_DestServers[0]} host ${_domain}"
    # local curr_domain_address=$($_host_cmd  | grep "has address" | cut -d' ' -f4)
    local curr_domain_address="$(host ${_domain} 1.1.1.1 | grep "has address" |cut -d' ' -f4)"


    echo
    if  [[ -z "${curr_domain_address}" ]]; then
        echo -e "${TABpurpleH}${provider} ${_domain} not resolved"
        echo -e "${TABpurpleH}${provider} ${_domain} curr: ${_ext_ip_addr} - new: ${curr_domain_address} - going to update"
        process_${provider}_provider "${_ifc},${_domain},${_token},${_ext_ip_addr}"

    elif [[ "${curr_domain_address}" == "${_ext_ip_addr}" ]]; then
        echo -e "${TABpurpleH}${_provider} ${_domain} curr: ${_ext_ip_addr} - not to be changed"

    elif [[ "${curr_domain_address}" == *"192.168.1."* ]]; then
        echo -e "${TABpurpleH}${_provider} ${_domain} ${curr_domain_address} - it's a local IP. skipping..."

    else
        echo -e "${TABpurpleH}${_provider} ${_domain} curr: ${curr_domain_address} - new: ${_ext_ip_addr} - going to update"
        process_${_provider}_provider "${_ifc},${_domain},${_token},${_ext_ip_addr}"

    fi
}


function join_lines() {
    last_line=''
    for line in "${arrayDomains[@]}"; do
        line=$(echo $line) # trim BLANKs

        if [[ ! -z $line ]]; then # se la linea non è vuota aggiungiamola a last_line
            last_line="$last_line $line"
            continue
        elif [[ -z $last_line ]]; then
            continue
        fi
        IFS=' ' read -r domain provider token machines_ifc <<< $last_line

        echo
        echo -e "processing:
        ${yellowH}$last_line${gray}
            domain:        $domain
            provider:      $provider
            token:         $token
            machines_ifc:  $machines_ifc${colorReset}"
        last_line='' # clean last_line
    done
}



##########################################
#    M A I N
##########################################
    base_vars
    DATE=$(date +'%d-%m-%Y %H:%M:%S')
    echo "\n\n\n"
    echo -e "${TABcyanH}-------------------------------------------------"
    echo -e "${TABcyanH}------------------- [${DATE}]"
    echo -e "${TABcyanH}-------------------------------------------------"
    echo
    # echo $g_hostname
    # g_DestServers=('loreton@ssh-loreton.alwaysdata.net' 'loreto@tty.sdf.org')
    g_DestServers=('loreto@tty.sdf.org' 'loreton@ssh-loreton.alwaysdata.net')
    g_ssh_key="$HOME/.ssh/ln_tunnel_ed25519"
    g_curlBIN=$(which curl)

    # echo "...1 $@" >a
    parseInput "$@"
    # echo "...2 $g_DRY_RUN" >>a
    # echo "...3 $g_Args" >>a
    # exit


    # ---------------------------------------------------------
    # - Reading data
    # ---------------------------------------------------------
    getInterfaces
    set -u
    getExternalIPs
    # saveMyIpAddresses


    echo -e "${TAByellowH}-----------------------------------"
    echo -e "${TAByellowH}--- Processing domains          ---"
    echo -e "${TAByellowH}-----------------------------------"


    # ---- M A I N    L O O P -----
    # sample line: DOMAIN_NAME PROVIDER    TOKEN MACHINE1.IFC_NAME MACHINE2.IFC_NAME ...
    my_Domains_full
    readarray arrayDomains < <(printf '%s\n' "$my_ddns_domains")
    # mapfile -t arrayDomains <<< "$my_ddns_domains"

    # ------------------------------------------
    # - leggiamo le righe e facciamo join fino ad una riga vuota
    # ------------------------------------------
    last_line=''
    for line in "${arrayDomains[@]}"; do
        line=$(echo $line) # trim BLANKs
        [[ -z $line ]] && continue
        IFS=' ' read -r domain provider token machines_ifc <<< $line

        # echo "domain: $domain"
        if [[ $g_VERBOSE -eq 1 ]]; then
            # echo -e "${TABgrayH}processing line: $line"
            echo
            # ${yellowH}$line${gray}
            echo -e "${TAByellowH}processing:
                domain:        $domain
                provider:      $provider
                token:         $token
                machines_ifc:  $machines_ifc${colorReset}"
        fi

        for machine_ifc in $machines_ifc; do
            machine="${machine_ifc%.*}"
            ifc="${machine_ifc##*.}"

            if [[ ${machine} != "${g_hostname_lower}" ]]; then
                [[ $g_VERBOSE -eq 1 ]] && echo -e "${TABgray}skipping machine_ifc: $machine_ifc"
                continue
            fi

            # [[ $g_VERBOSE -eq 1 ]] && echo -e "${TABgray}validating machine_ifc: $machine_ifc"
            for interface in ${g_interfaces[@]}; do
                IFS=':' read -r ifc_name ifc_addr ext_ip _rest <<< ${interface}
                if [[ "$ifc_name" == "$ifc" ]]; then
                    # [[ ! -z $line ]] && processLine $line
                    processLine "$ifc $provider $domain $token $ifc_addr $ext_ip"
                fi
            done

        done

    done

    exit


