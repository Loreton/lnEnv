#!/bin/bash
# updated by ...: Loreto Notarantonio
# Date .........: 31-12-2024 12.02.22
#
###############################################


function from_bev41_to_casetta51 {
    REMOTE_HOST='lncasetta.duckdns.org'
    SSH_DEST_ACCESS_PORT=51022
    SSH_USER=pi
    SSH_REMOTE_REVERSE_PORT=41051
    SSH_KEY="-i ${HOME}/.ssh/ln_tunnel_ed25519"
    LOGNAME='/tmp/ssh_rom_bev41_to_casetta51.log'
}



function getRemoteIpAddress {
    wrLog "$LINENO" "getting remote ip address..."
    CMD="$SSH_BASE \"hostname -I | cut -d' ' -f1\""
    wrLog "$LINENO" "$CMD"
    remoteIP=$(eval $CMD)
    rCode=$?
    wrLog "$LINENO" "rCode: $rCode"
    wrLog "$LINENO" "remoteIP: $remoteIP"

    if [ -z $remoteIP ] ; then
        wrLog "$LINENO" "Error getting remote ip address"
        exit 1
    fi
}


# se sono qui vuol dire che il test del tunnel Ã¨ fallito
# pulisce le vecchie e troppe connessioni... se esistono
function clean_ExistingConnections {
    wrLog "$LINENO" "Cleaning older sessions... if existing"
    # -t elimina la linea di titolo.
    LSOF_CMD="lsof -t -i :${SSH_REMOTE_ACCESS_PORT}"

    wrLog "$LINENO" "$LSOF_CMD"
    n_conn=$($LSOF_CMD | wc -l)
    wrLog "$LINENO" "found $n_conn connections"
    if [ $n_conn -gt 0 ]; then # too much, so close all
        wrLog "$LINENO" "too much connections, cleanig up"
        KILL_TCP="$LSOF_CMD| tr -s ' ' |  cut -f2 -d' ' |sudo xargs kill"
        # tr -s " " elimina multiple spaces
        wrLog "$LINENO" "$KILL_TCP"
        eval $KILL_TCP 1>>$LOGNAME 2>&1
        n_conn=$($LSOF_CMD | wc -l)
        wrLog "$LINENO" "found $n_conn connections after clenup"
    fi
}

# Establish tunnel
function create_ReverseTunnel {
    EXECUTE=$1
    # wrLog "$LINENO" "$COMMAND"
    # -g indica che deve fare il bind su tutte le interfacce
    #    per fare ciÃ², bisogna anche che il parametro
    #   "GatewayPorts yes" (sul server /etc/ssh/sshd_config)
    #   sia presente, altrimenti fa il bind solo su localhost
    COMMAND="$SSH_BASE -g -NR ${remoteIP}:${SSH_REMOTE_REVERSE_PORT}:localhost:22"
    COMMAND="$SSH_BASE -g -NR 0.0.0.0:${SSH_REMOTE_REVERSE_PORT}:localhost:22"


    wrLog "$LINENO" "starting tunnel..."
    wrLog "$LINENO" "$COMMAND"
    if [ "$EXECUTE" == "--go" ]; then
        pkill -f -x "$COMMAND"
        eval $COMMAND 1>>$LOGNAME 2>&1 &
        rCode=$?
        wrLog "$LINENO" "rCode: $rCode"
    else
        for i in {1..5};  do
            wrLog "$LINENO" "DRY-RUN mode, command was NOT executed" --console
        done
        wrLog "$LINENO" "add --go argument to execute!" --console
    fi
}


function isHostReachable() {
    # verifichiamo che il server sia raggiungibile.....
    # nc -w 5 -z rm-pina.duckdns.org 8024
    wrLog "$LINENO" "check if remote server ${REMOTE_HOST} is reachable..."
    cmd="nc -w $gCONN_TIMEOUT -z ${REMOTE_HOST} ${SSH_REMOTE_ACCESS_PORT}"

    wrLog "$LINENO"  "$cmd"
    eval $cmd 1>>$LOGNAME 2>&1
    rCode=$?

    if [ $rCode -eq 0 ] ; then
        wrLog "$LINENO" "Server ${REMOTE_HOST}:${SSH_REMOTE_ACCESS_PORT} is reachable..."
    else
        wrLog "$LINENO" "Server ${REMOTE_HOST}:${SSH_REMOTE_ACCESS_PORT} is not reachable..."
        exit 1
    fi
}

    # verifichiamo se il tunnel sia giÃ  in piedi.....
function check_Tunnel() {
    REMOTE_CHECK_CMD="netstat -an |  egrep \"tcp.*:$SSH_REMOTE_REVERSE_PORT.*LISTEN\""
    REMOTE_CHECK_CMD="nc -w 5 -z 127.0.0.1 64032"
    REMOTE_CHECK_CMD="nc -w 5 -z $remoteIP $SSH_REMOTE_REVERSE_PORT"
    REMOTE_CHECK_CMD="ssh $SSH_OPTs $SSH_KEY pi@127.0.0.1 -p $SSH_REMOTE_REVERSE_PORT ls -la /etc/ssh/ssh_config"

    CHECK_CMD="$SSH_BASE $REMOTE_CHECK_CMD"
    wrLog "$LINENO" "checking tunnel..."
    wrLog "$LINENO" "$CHECK_CMD"
    eval $CHECK_CMD 1>>$LOGNAME 2>&1
    rCode=$?
    wrLog "$LINENO" "rCode: $rCode"

    # - errori che comunque comportano una connessione riuscita
    # [ $rCode -eq 2 ] && rCode=0    # file not found
    # [ $rCode -eq 127 ] && rCode=0  # comando non trovato
}




######### M A I N ##########
######### M A I N ##########
######### M A I N ##########
######### M A I N ##########
######### M A I N ##########
######### M A I N ##########
# Sample call:
#    /bin/bash /home/pi/PiProd/shProc/ssh_Reverse_tunnel.sh rmpina_8023_64032 --go
############################
    scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    scriptDir="$(dirname $scriptFPath)"
    cd $scriptDir
    source "wrLog.sh"

    gCONN_TIMEOUT=5

    remServer=$1    # function to be called... rmpina_8023_64032 steve_60022_64032
    GO=$2           # --go

    ${remServer}
    if [ -z "$REMOTE_HOST" ]; then
        echo "server profile [$remServer] NOT found!"
        echo "please enter one of the following:"
        echo "-   rmpina_pi23"
        echo "-   rmpina_pi41"
        exit 1
    fi

    echo "LOGNAME   : $LOGNAME"
    echo "remServer : $remServer"

    # ------------------
    # - include LOG
    # ------------------
    if [ -f ${scriptDir}/wrLog.sh ]; then
        . ${scriptDir}/wrLog.sh $scriptFPath $LOGNAME
        echo "logfile: $LOGNAME"
        wrLog  $LINENO --init

    else
        echo "${scriptDir}/wrLog.sh NOT FOUND"
        exit 1
    fi



    readonly scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
    readonly scriptDir="$(dirname $scriptFPath)"



    ETH0_IP=$(hostname -I | cut -d' ' -f1)

    SSH_OPTs="-o ConnectTimeout=$gCONN_TIMEOUT -o BatchMode=yes -o StrictHostKeyChecking=no "


    # - create base ssh command
    SSH_BASE="/usr/bin/ssh $SSH_KEY $SSH_OPTs -l ${SSH_USER} -p ${SSH_REMOTE_ACCESS_PORT} ${REMOTE_HOST}"

    # - check if remote server is reachable
    isHostReachable


    # - get remote IP address ($remoteIP)
    getRemoteIpAddress

    check_Tunnel

    # create Reverse tunnel
    if [ $rCode -eq 0 ] ; then
        wrLog "$LINENO" "tunnel is already established..."  --console
    else
        wrLog "$LINENO" "tunnel is NOT active, trying..."  --console
        clean_ExistingConnections
        if [ $n_conn -eq 0 ]; then
            create_ReverseTunnel $GO
        else
            wrLog "$LINENO" "connections active $n_conn. Should not occur!!"  --console
        fi
    fi

    exit

