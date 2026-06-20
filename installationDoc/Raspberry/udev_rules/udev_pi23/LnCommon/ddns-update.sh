#!/bin/bash


thisSCRIPT=$(basename $0)
moduleName=$(basename $0)
source /home/pi/Loreto/etc/LnCommon/LnNetFunctions $thisSCRIPT

CURL_PROGRAM='/opt/curl'
CURL_PROGRAM='curl'


function noip {
    DDNS_hostName=$1
    userNAME="loretoip"
    userPSW="NoIpDNS"
    DDNS_URL="http://${userNAME}:${userPSW}@dynupdate.no-ip.com/nic/update?hostname=${DDNS_hostName}&myip=$NEWIP"
}

function duckdns {
    DDNS_hostName=$1
    USERToken='98fa7c37-21c7-43b2-92d2-822560984579'                                                # attivo con l'utenza di twitter pidgin
    DDNS_hostName=$(echo "$DDNS_hostName" | cut -d\. -f1)
    DDNS_URL="https://www.duckdns.org/update?domains=${DDNS_hostName}&token=${USERToken}&ip="       # ---- non vuole il dominio nel comando
}

function execDnsUpdate {
        # --- esecuzione comando
    wrLog "$moduleName" "$LINENO" "${DDNS_URL}"
    # return
    [[ "$RUN" == "true" ]] && CURLOUT=$($CURL_PROGRAM --interface ${interfaceName} --silent $DDNS_URL)
    wrLog "$moduleName" "$LINENO" "rCode: $CURLOUT"
    echo $CURLOUT | egrep -i -w "good|nochg|ok"; rCode=$?
    if [ $rCode -eq 0 ]; then
        LASTIP=$NEWIP
        echo $LASTIP >$LASTIP_File
        wrLog "$moduleName" "$LINENO" "Successful update for name:$DDNS_hostName   IP:$LASTIP"
    else
        wrLog "$moduleName" "$LINENO" "ERRORE durante l'aggiornamento."
    fi
}


function updateRemoteIP {
    [[ "$NEWIP" == "" ]] && return 0
    if [[ "$NEWIP" != "$LASTIP" ]]; then                      # --- Se diverso dal precedente
        wrLog "$moduleName" "$LINENO" "IP has changed from: $LASTIP to: $NEWIP"
        execDnsUpdate
    else
        wrLog "$moduleName" "$LINENO" "IP Address NOT changed. NO Update."
    fi
}



function processRecord {
    record=$*
    hostName=$(echo  "$record" | cut -d\  -f1)
    provider=$(echo  "$record" | cut -d\  -f2)
    interface=$(echo "$record" | cut -d\  -f3)
    [[ -z "$interface" ]] && return 0
    wrLog "$moduleName" "$LINENO" "--- working on record: $record"

    if [[ "$interface" == 'eth0' ]]; then                      # --- Se diverso dal precedente
        setEth0;[[ "$?" -ne "0" ]] && return 1
        NEWIP=$eth0_NEWIP
        LASTIP=$eth0_LASTIP
        LASTIP_File=$eth0_LASTIP_File
        $provider $hostName
        updateRemoteIP
    fi

    if [[ "$interface" == 'wlan0' ]]; then
        setWlan0;[[ "$?" -ne "0" ]] && return 1
        NEWIP=$wlan0_NEWIP
        LASTIP=$wlan0_LASTIP
        LASTIP_File=$wlan0_LASTIP_File
        $provider $hostName
        updateRemoteIP
    fi

    if [[ "$interface" == 'wlan1' ]]; then
        setWlan1;[[ "$?" -ne "0" ]] && return 1
        NEWIP=$wlan1_NEWIP
        LASTIP=$wlan1_LASTIP
        LASTIP_File=$wlan1_LASTIP_File
        $provider $hostName
        updateRemoteIP
    fi


}



################################################
# M A I N
################################################


    FORCE_UPDATE='false'

    RUN='false'
    RUN='true'

        # ----- impostazione dei nomi file
    eth0_LASTIP_File='/tmp/PrevIPeth0'
    wlan0_LASTIP_File='/tmp/PrevIPwlan0'
    wlan1_LASTIP_File='/tmp/PrevIPwlan1'

        # --- otteniamo l'indirizzo remoto attuale
    eth0_NEWIP=$(getRemoteIP eth0)
    wlan0_NEWIP=$(getRemoteIP wlan0)
    wlan1_NEWIP=$(getRemoteIP wlan1)

    [[ $(date +"%M") == '30' ]] && FORCE_UPDATE='true'
    if [[ "$FORCE_UPDATE" == "true" ]]; then
        eth0_LASTIP=''
        wlan0_LASTIP=''
        wlan1_LASTIP=''
    else
            # --- lettura del prcedente indirizzo IP
        eth0_LASTIP='';  [[ -s $eth0_LASTIP_File ]]  && read -r eth0_LASTIP<$eth0_LASTIP_File
        wlan0_LASTIP=''; [[ -s $wlan0_LASTIP_File ]] && read -r wlan0_LASTIP<$wlan0_LASTIP_File
        wlan1_LASTIP=''; [[ -s $wlan1_LASTIP_File ]] && read -r wlan1_LASTIP<$wlan1_LASTIP_File
    fi

    # --- salviamo il corrente indirizzo sul PrevFile
    echo $eth0_NEWIP    >$eth0_LASTIP_File
    echo $wlan0_NEWIP   >$wlan0_LASTIP_File
    echo $wlan1_NEWIP   >$wlan1_LASTIP_File



    wrLog "$moduleName" "$LINENO" "[eth0]  - last remote IP: [$eth0_LASTIP]  - new remote IP: [$eth0_NEWIP]"
    wrLog "$moduleName" "$LINENO" "[wlan0] - last remote IP: [$wlan0_LASTIP] - new remote IP: [$wlan0_NEWIP]"
    wrLog "$moduleName" "$LINENO" "[wlan1] - last remote IP: [$wlan1_LASTIP] - new remote IP: [$wlan1_NEWIP]"

    DOMINI_NOIP_LORETO='https://www.noip.com/members/dns/
                        lnpina.noip.me              ,
                        lnloreto.noip.me            ,
                '

    DOMINI_DUCK_LORETO='http://www.duckdns.org/ login con Twitter pidgin
                        lnloreto.duckdns.org            ,
                        lnpina.duckdns.org          ,
                        lncasetta.duckdns.org       ,
                '

    # --- se siamo a cavallo della mezz'ora forziamo l'aggiornamento
    DDNS_hosts='lncasetta.duckdns.org       duckdns     eth0,
                lnloreto.noip.me            noip        eth0,
                lnloreto.duckdns.org        duckdns     eth0,
                lnpina.duckdns.org          duckdns     wlan0,
                lnpina.duckdns.org          duckdns     wlan1,
                lnpina.noip.me              noip        wlan0,
                lnpina.noip.me              noip        wlan1,
                '

    # DDNS_hosts='lnloreto.noip.me            noip        eth0,
                # '

    # echo $DDNS_hosts


    while IFS=',' read -ra hostArray; do
        for record in "${hostArray[@]}"; do
            processRecord $record       # inviarlo senza doppi apici
            wrLog "$moduleName" "$LINENO" ""
        done
    done <<< "$DDNS_hosts"

    exit 0

