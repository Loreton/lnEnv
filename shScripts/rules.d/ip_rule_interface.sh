#!/bin/bash

#------------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 27-08-2023 17.25.26
#
#  https://www.thegeekstuff.com/2014/08/add-route-ip-command/
#  https://www.baeldung.com/linux/destination-source-routing
#------------------------------------------


source "${ln_SET_LORETO_ENVIRONMENT}" "$0" "variables colors" >/dev/null



function @local_esegui() {
    local stacklevel=$1
    local CMD_DESCR=$2
    local cmd=$3
    local indent=$TAB
    # set +x
    caller="${FUNCNAME[stacklevel+1]}:${BASH_LINENO[stacklevel]}"
    printf "\n${indent}[${caller}]"
    printf "\n${indent}${cyanH} ${CMD_DESCR}${colorReset}\n"
    if [[ "$g_fEXECUTE" -eq "1" || "$g_fEXECUTE" == "go" ]]; then
        printf "${indent}${purpleH} [executing]$yellowH: ${cmd}${colorReset}\n"
        eval '$cmd'
        rCode=$?
        [[ ! "$rCode" -eq 0 ]] && printf "${indent}${redH} ${rCode}${colorReset}\n" && exit $rCode
    else
        printf "${indent}${purpleH} [dry-run]$yellowH: ${cmd}${colorReset}\n"
    fi
}




#############################################
#
#############################################
function parseInput() {
    local args=$*
    # echo "${TAB}command line: $args"
    # [[ -z $args ]] && syntax
    g_fEXECUTE=0
    g_DRY_RUN='--dry-run'


    # check rhe word and remove it from args
    word='-h';         [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--help';     [[ " $args " == *" $word "* ]] && args=${args//$word/} && syntax 1 && exit 1
    word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''



    g_IFC=$(echo $args | cut -d' ' -f1)
    args=${args//$g_IFC/}
    g_TABLE_ID=$(echo $args | cut -d' ' -f1)
    args=${args//$g_TABLE_ID/}
    g_rest_arguments=$(echo $args) # strip text
}

#############################################
#
#############################################
function syntax() {
    # printf "\n${TAByellowH}syntax %s\n" $(basename $BASH_SOURCE)
    printf "\n${TAByellowH}Enter interface name:${cyanH}
        eth0 wlan0 ...
        enp2s0f0 wlp3s0 ...\n"
    printf "\n${TAByellowH}Options:${cyanH}
        -h|--help    this help
        --go         execute commands
        ${colorReset}\n "
    echo
    exit 1
}


##########################################
# Legge i nomi delle interfacce di rete e crea
# una array: ifc_name:ifc_addr
##########################################
function getIfcData() {
    local ifc_name=$1
    # printf "${TAByellowH}
    # -----------------------------------
    # --- checking internal interfaces
    # --- and IP addresses
    # -----------------------------------${colorReset}\n"

    ### capture internal IP
    inet_line=( $(ip addr show dev ${ifc_name}  | grep 'inet '))
    IFS='/' read -r g_IFC_ADDR _mask <<< ${inet_line[1]} # get just IP address

    third_octet=$(echo $g_IFC_ADDR | cut -d'.' -f3)
    g_TABLE_ID=$((11100+${third_octet}))

    ### capture subnet for internal IP
    g_SUBNET_24=$(ip route | grep "src ${g_IFC_ADDR}" | grep -v "default"| head -1 | awk '{print $1}')
    SUBNET_0=$(ip route | grep "src ${g_IFC_ADDR}" | grep -v "default"| cut -d'/' -f 1 | head -1)
    suffix='.0'
    SUBNET=${SUBNET_0/%$suffix}

    ### capture gateway for subent
    g_GW_ADDR=$(ip route show | grep default | awk '{print $3}' |grep "$SUBNET")
    g_GW_ADDR="${SUBNET}.1"

    printf "${yellowH}
        $TAB -----------------------------------
        $TAB -  IFC       :   $ifc_name
        $TAB -  IFC_ADDR  :   ${g_IFC_ADDR}

        $TAB -  TABLE     :   ${g_TABLE_ID}
        $TAB -  GW_ADDR   :   ${g_GW_ADDR}
        $TAB -  SUBNET_24 :   ${g_SUBNET_24}
        $TAB -  SUBNET    :   $SUBNET
        $TAB -  SUBNET_0  :   $SUBNET_0
        $TAB -----------------------------------
        ${colorReset}\n"
}





#####################################################################
# 1. adding subnet 192.168.3.0 with a netmask 255.255.255.0 with the source IP address 192.168.3.176 & device $IFC to the  table.
# 2. adding the route 192.168.3.1 to the ${g_TABLE_ID} table.
#      This way all the rules defined in ${g_TABLE_ID} table routes traffic through device $IFC.
#####################################################################
function add_route() {
    local ifc=$1
    set +x
    exists=$(ip route show table ${g_TABLE_ID} | grep "${g_SUBNET_24} dev $ifc" | wc -l)
    if [ "$exists" -eq "0" ]; then
        @local_esegui 0 "adding route for ${g_SUBNET_24}" "sudo ip route add ${g_SUBNET_24} dev $ifc src ${g_IFC_ADDR} table ${g_TABLE_ID}"
    fi

    exists=$(ip route show table ${g_TABLE_ID} | grep "default via ${g_GW_ADDR} dev $ifc" | wc -l)
    if [ "$exists" -eq "0" ]; then
        @local_esegui 0 "adding default route for ${g_SUBNET_24}" "sudo ip route add default via ${g_GW_ADDR} dev $ifc table ${g_TABLE_ID}"
    fi
    set +x
    @local_esegui 0 "show route table" "ip route show table ${g_TABLE_ID}"
}


#####################################################################
# instruct the OS how to use this table
# All the rules are executed in the ascending order.
# So, we will add rule entries above the ${g_TABLE_ID} table.
#####################################################################
function add_rules() {
    local ifc=$1
    # --------------------
    # 1. adds the rule that all the outgoing traffic from $IFC IP needs to use the "${g_TABLE_ID}" routing table instead of "main" one.
    # --------------------
    set +x
    exists=$(ip rule | grep "from all to ${g_IFC_ADDR}/24 lookup ${g_TABLE_ID}" | wc -l)
    if [ $exists -eq 0 ]; then
        @local_esegui 0 "adding rule for all traffic out-going from $ifc" "sudo ip rule add to ${g_IFC_ADDR}/24 table ${g_TABLE_ID}"
    fi


    # --------------------
    # 2. adds the rule that all the traffic going to $IFC IP needs to use the "${g_TABLE_ID}" routing table instead of "main" one.
    # --------------------
    exists=$(ip rule | grep "from ${g_IFC_ADDR}/24 lookup ${g_TABLE_ID}"| wc -l)
    if [ $exists -eq 0 ]; then
        @local_esegui 0 "adding rule for all traffic coming from $ifc" "sudo ip rule add from ${g_IFC_ADDR}/24 table ${g_TABLE_ID}"
    fi
    set +x

    # --------------------
    # 3. commit all these changes in the previous commands
    # --------------------
    @local_esegui 0 "commit changes" "sudo ip route flush cache"

}


###########################################################################
#            M A I N
###########################################################################
    parseInput "$@"
    set -u

    ### -------------------------
    ### wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    ###     link/ether 90:00:4e:96:7f:4b brd ff:ff:ff:ff:ff:ff
    ### -------------------------
    ifcs=$(ip a s | grep -i "state up" | grep -i "multicast" | cut -d' ' -f2 |cut -d':' -f1)
    for ifc_name in $ifcs; do
        g_IFC_ADDR=
        getIfcData $ifc_name
        if [[ -z "$g_IFC_ADDR" ]]; then
            printf "${TABredH} L'interfaccia richiesta [%s] non ha l'indirizzo ip\n" $ifc_name
            continue
        fi
        ip rule show
        add_route $ifc_name
        add_rules $ifc_name
        ip rule show
        echo
    done

