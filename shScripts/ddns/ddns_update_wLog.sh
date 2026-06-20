#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 28-11-2025 18.28.16
#========================================

# Carica i dati dal seguente file:
config_yaml_file="${ln_SECRET_DIR}/yaml/ddns_domains.yaml"


function _set_yq() {
    arch=$(uname -m)
    if [[ "$arch" == *"x86_64"* ]]; then
        yq_bin="${ln_LINUX_PORTABLE_DIR}/bin/yq_linux_amd64"
    else
        yq_bin="${ln_LINUX_PORTABLE_DIR}/bin/yq_linux_arm"
    fi
    alias ".yq=${yq_bin}"
    sudo ln -sf "${yq_bin}" "/usr/bin/lnYQ"
    ln -sf "${yq_bin}" "${ln_LINUX_PORTABLE_DIR}/bin/lnYQ"
}
_set_yq


#############################################
#
#############################################
function syntax() {
    printf
    printf "${TAByellowH}syntax %s\n" $(basename $BASH_SOURCE)
    printf "${TABcyanH}Will read configuration file and try to update all domains\n"
    printf "${TABpurpleH}   $config_yaml_file\n"
    printf "${TABcyanH}regarding this hostname and relative network interface\n"
    echo
    printf "${TAByellowH}Options:\n"
    printf "${TAB}${TABcyanH}-h|--help    this help\n"
    printf "${TAB}${TABcyanH}--verbose    show more details\n"
    printf "${TAB}${TABcyanH}--go         execute commands\n"
    printf "${colorReset}\n"
    echo
    exit 1
}

#############################################
#
#############################################
function @_esegui() {
    local indent=$1
    local CMD_DESCR=$2
    local cmd=$3

    @lnLog "${indent}${cyanH} ${run_time} ${CMD_DESCR}${colorReset}"
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        @lnLog "${indent}${purpleH} [executing]$yellowH: ${cmd}${colorReset}"
        eval '$cmd'
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && { @lnLog "${indent}${redH} ${rCode}${colorReset}"; exit $rCode; }
    else
        @lnLog "${indent}${purpleH} [dry-run]$yellowH: ${cmd}${colorReset}"
    fi
    echo
}


##########################################
# Legge i nomi delle interfacce di rete e crea
# una array: ifc_name:ifc_addr
##########################################
function getExtIntAddresses() {
    g_interfaces=()
    @lnLog "${yellowH}-----------------------------------${colorReset}"
    @lnLog "${yellowH}--- ${run_time}${colorReset}"
    @lnLog "${yellowH}--- checking internal interfaces${colorReset}"
    @lnLog "${yellowH}--- and IP addresses${colorReset}"
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

        ### capture external IP
        local _cmd="--connect-timeout 5 --interface ${ifc_name}  --silent http://icanhazip.com/"
        @lnLog "${cyan}executing: $g_curlBIN $_cmd"
        local ifc_external_IP=$($g_curlBIN $_cmd)

        g_interfaces+=("${hostname_lc,,}:${ifc_name}:${ifc_internal_IP}:${ifc_external_IP}") # create array_entry
        @lnLog "${green}interface_name: $ifc_name"
        @lnLog "${green}internal_IP:    $ifc_internal_IP"
        @lnLog "${green}external_IP:    $ifc_external_IP"
        echo
    done
}




##########################################
# domain: domain name
# g_interfaces: eth0:ip_address ....
##########################################
function process_serverLine() {
    local domain="$1"
    local url="$2"
    local server_line="$3"

    local ifc_name # nome interfaccia prelevata dal file di configurazione
    local ifc      # nome interfaccia della macchina che stiamo processando
    local curr_domain_address="$(host ${domain} 1.1.1.1 | grep "has address" |cut -d' ' -f4)"

    indent="${TAB}${TAB}"
    [[ $g_VERBOSE -eq "1" ]] && @lnLog "${indent}${purpleH}server_line: ${yellowH} $server_line"

    ### split server
    local server_name="${server_line%.*}"            # server_name or "ssid"
    if [[ "$server_name" == 'ssid' ]]; then
        local ssid="${server_line##*.}"            # SSID
        local activeSSID=$($IWGETID | cut -d':' -f2 | cut -d'"' -f2)
        if [[ "$ssid" != "$activeSSID" ]]; then
            [[ $g_VERBOSE -eq "1" ]] && @lnLog "${greenH}skipping"
            return ### non riguarda questa ssid
        fi
        local ifc_name=$($IWGETID | cut -d' ' -f1)
        local server_name=$hostname_lc
    else
        if [[ "$server_name" != "$hostname_lc" ]]; then
            [[ $g_VERBOSE -eq "1" ]] && @lnLog "${greenH}$server_name is not this server - skipping"
            return ### non riguarda questo server
        fi
        local ifc_name="${server_line##*.}"            # interface_name
        local ssid=""            # SSID
    fi


    for interface in ${g_interfaces[@]}; do
        IFS=':' read -r hostname ifc internal_IP external_IP _rest <<< ${interface}
        [[ -z $external_IP ]] && external_IP='NOT RESOLVED'

        [[ $g_VERBOSE -eq "1" ]] && @lnLog "${indent}${purpleH}ifc_name: ${yellowH} $ifc_name"

        # if [[ "$ifc" == "$ifc_name" ]]; then
        if [[ "$ifc" =~ ^"$ifc_name" ]]; then  ### starts_with
            url=${url//'__DOMAIN__'/${domain}} ### replace __DOMAIN__
            url=${url//'__NEW_IP_ADDR__'/${external_IP}} ### replace __EXT_IP_ADDR__

            [[ $g_VERBOSE -eq "0" ]] && @lnLog "${indent}${purpleH}server_line: ${yellowH} $server_line"
            [[ $g_VERBOSE -eq "0" ]] && @lnLog "${indent}${purpleH}interface:   ${yellowH} $ifc"
            @lnLog "${indent}${purpleH}ssid:        ${yellowH} $ssid"
            @lnLog "${indent}${purpleH}curr_ip:     ${yellow}  $curr_domain_address"
            @lnLog "${indent}${purpleH}new_ip:      ${yellow}  $external_IP"


            if  [[ -z "${curr_domain_address}" ]]; then
                @_esegui "${indent}" "${cyanH}updating" "$g_curlBIN --interface ${ifc} $(echo $url)"

            elif [[ "${curr_domain_address}" == "${external_IP}" ]]; then
                @lnLog "${cyanH} - nothing to be changed"

            elif [[ "${curr_domain_address}" == *"192.168.1."* ]]; then
                @lnLog "${indent}${cyanH}it's a local IP. skipping..."

            else
                @lnLog "${cyanH} - updating"
                @_esegui "${indent}" "" "$g_curlBIN --interface ${ifc} $(echo $url)"
            fi
        else
            [[ $g_VERBOSE -eq "2" ]] && @lnLog "${indent}${cyanH}it's not managed $hostname_lc"

        fi

    done

}




#############################################
#
#############################################
function parseInput() {
    local args=$*
    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'
    g_VERBOSE=0

    # check the word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax
    word='--verbose';  [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_VERBOSE=1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN='executing'
    printf -v g_Args "%s" $args # remove BLANKs

}



############################################################
#     M A I N
############################################################
    run_time=$(date "+%d.%m.%Y %H:%M:%S")
    source "${ln_SET_LORETO_ENVIRONMENT}" 0
    fLOG=1
    # source ln_log.functions

    hostname=$(hostname -s); hostname_lc=${hostname,,}
    IWGETID=$(which iwgetid)




    set -u
    parseInput "$@"

    g_curlBIN=$(which curl)
    DQ='"'


    # --------------------------------------------
    # ref: https://mikefarah.gitbook.io/yq/operators/traverse-read#nested-special-characters
    # --------------------------------------------
    getExtIntAddresses ### return g_interfaces

    domains=$(lnYQ '.domains | keys'  $config_yaml_file); ### echo $domains
    for domain in ${domains[@]}; do
        [[ $domain == '-' ]] && continue


            url=$(lnYQ ".domains[${DQ}${domain}${DQ}][${DQ}url${DQ}]"       $config_yaml_file); #echo $url
          token=$(lnYQ ".domains[${DQ}${domain}${DQ}][${DQ}token${DQ}]"     $config_yaml_file); #echo $token
        servers=$(lnYQ ".domains[${DQ}${domain}${DQ}][${DQ}servers${DQ}][]" $config_yaml_file); #echo $servers
        [[ $servers == '' ]] && continue
        @lnLog "${cyanH}Processing domain: ${yellowH} $domain"

        [[ $url == '' ]] && continue
        [[ $token == '' ]] && continue

        for server in $servers; do
            url=${url//'__TOKEN__'/${token}} ### replace __TOKEN__ with token
            process_serverLine "$domain" "$url" "$server"
        done

    done
    echo -e "\ncompleted!"

