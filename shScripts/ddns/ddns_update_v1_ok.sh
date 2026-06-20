#!/bin/bash

#========================================
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.27.46
#========================================

# Carica i dati dal seguente file:
yaml_file="${HOME}/lnprofile/secret/yaml/ddns_domains_v1_ok.yaml"

#############################################
#
#############################################
function syntax() {
    printf
    printf "${TAByellowH}syntax %s\n" $(basename $BASH_SOURCE)
    printf "${TABcyanH}Will read configuration file and try to update all domains\n"
    printf "${TABpurpleH}   $yaml_file\n"
    printf "${TABcyanH}regarding this hostname and relative network interface\n"
    echo
    printf "${TAByellowH}Options:\n"
    printf "${TAB}${TABcyanH}-h|--help    this help\n"
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

    printf "\n${indent}${cyanH} ${CMD_DESCR}${colorReset}\n"
    if [[ "$g_fEXECUTE" -eq "1" ]]; then
        printf "${indent}${purpleH} [executing]$yellowH: ${cmd}${colorReset}"
        eval '$cmd'
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && printf "${indent}${redH} ${rCode}${colorReset}\n" && exit $rCode
    else
        printf "${indent}${purpleH} [dry-run]$yellowH: ${cmd}${colorReset}\n"
    fi
    echo
}


##########################################
# Legge i nomi delle interfacce di rete e crea
# una array: ifc_name:ifc_addr
##########################################
function getExtIntAddresses() {
    g_interfaces=()
    printf "${TAByellowH}
    -----------------------------------
    --- checking internal interfaces
    --- and IP addresses
    -----------------------------------${colorReset}\n"

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
        printf "\n${TABcyan}executing: %s %s\n\n" "$g_curlBIN" "$_cmd"
        local ifc_external_IP=$($g_curlBIN $_cmd)

        g_interfaces+=("${g_hostname,,}:${ifc_name}:${ifc_internal_IP}:${ifc_external_IP}") # create array_entry
        # echo ${g_interfaces[@]}
        printf "${TABgreen}interface_name: %s
            internal_IP: %s
            external_IP: %s\n" "$ifc_name" "$ifc_internal_IP" "$ifc_external_IP"
        echo
    done
}




##########################################
# g_domain: domain name
# g_interfaces: eth0:ip_address ....
##########################################
function processDomain() {
    local servers=$1
    local url=$2

    local curr_domain_address="$(host ${g_domain} 1.1.1.1 | grep "has address" |cut -d' ' -f4)"

    for interface in ${g_interfaces[@]}; do
        IFS=':' read -r hostname ifc_name internal_IP external_IP _rest <<< ${interface}
        [[ -z $external_IP ]] && external_IP='NOT RESOLVED'
        myScope="${hostname,,}.${ifc_name}"
        [[ $g_VERBOSE -eq "1" ]] && printf "\n${TAByellowH}%s" ${g_domain}

        indent="${TAB}${TAB}${TAB}"
        if [[ "$servers" == *"$myScope"* ]]; then
            [[ $g_VERBOSE -eq "0" ]] && printf "\n${TABpurpleH}[%-8s] ${yellowH}%-30s" ${ifc_name} ${g_domain}
            url=${url//'__DOMAIN__'/${g_domain}} ### replace __DOMAIN__
            url=${url//'__NEW_IP_ADDR__'/${external_IP}} ### replace __EXT_IP_ADDR__
            # printf "${TABpurpleH}
            # curr_ip: %s
            # new_ip:  %s" "$curr_domain_address" "$external_IP"
            printf "${TABpurpleH} ${purpleH}curr_ip: ${yellow}%s     ${purpleH}new_ip: ${yellow}%s" "$curr_domain_address" "$external_IP"
            # tab_last_line="${TAB}${TAB}${TABcyanH}"

            if  [[ -z "${curr_domain_address}" ]]; then
                @_esegui "${indent}" "${cyanH}updating" "$g_curlBIN --interface ${ifc_name} $(echo $url)"

            elif [[ "${curr_domain_address}" == "${external_IP}" ]]; then
                printf "${cyanH} - not to be changed\n"

            elif [[ "${curr_domain_address}" == *"192.168.1."* ]]; then
                printf "${indent}${cyanH}it's a local IP. skipping..."

            else
                printf "${cyanH} - updating"
                @_esegui "${indent}" "" "$g_curlBIN --interface ${ifc_name} $(echo $url)"
                # @_esegui "${indent}" "${cyanH}updating" "$g_curlBIN $(echo $url)"
            fi
        else
            [[ $g_VERBOSE -eq "1" ]] && printf "${indent}${cyanH}it's not managed by %s\n" "$g_hostname"
            # printf "${indent}${cyanH}it's not managed by %s\n" "$g_hostname"

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
    source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null

    hostname=$(hostname -s); g_hostname=${hostname,,}



    set -u
    parseInput "$@"
    # YQ="${ln_BIN}/yq"
    YQ="/usr/local/bin/yq"
    g_curlBIN=$(which curl)
    DQ='"'


    # --------------------------------------------
    # ref: https://mikefarah.gitbook.io/yq/operators/traverse-read#nested-special-characters
    # --------------------------------------------


    getExtIntAddresses ### return g_interfaces

    # domains=$(${YQ} 'comments="" | .domains | keys'  $yaml_file); ### echo $domains
    domains=$(${YQ} '.domains | keys'  $yaml_file); ### echo $domains
    for g_domain in ${domains[@]}; do
        [[ $g_domain == '-' ]] && continue
        # [[ "${g_domain:0:1}" == '#' ]] && continue
        # echo $g_domain
        # continue

            url=$($YQ ".domains[${DQ}${g_domain}${DQ}][${DQ}url${DQ}]"       $yaml_file); #echo $url
          token=$($YQ ".domains[${DQ}${g_domain}${DQ}][${DQ}token${DQ}]"     $yaml_file); #echo $token
        servers=$($YQ ".domains[${DQ}${g_domain}${DQ}][${DQ}servers${DQ}][]" $yaml_file); #echo $servers
        [[ $url == '' ]] && continue
        [[ $token == '' ]] && continue
        [[ $servers == '' ]] && continue


        url=${url//'__TOKEN__'/${token}} ### replace __TOKEN__ with token

        processDomain "$servers" "$url"
    done
