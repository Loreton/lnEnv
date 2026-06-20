#!/bin/bash
# *   *  * * * /bin/bash /home/pi/Loreto/proc/myRoute eth0 wlan0 wlan1

# 01. verificare le interfacce attive
# 02. verificare le interfacce attive

# imposta alcune funzioni di base

# ---------------------------------------------------------------
# /etc/iproute2/rt_tables
#       200     eth0
#       201     wlan0
#       202     wlan1
#       211     eth0_Pina
#       212     eth0_Loreto
# ---------------------------------------------------------------
# sudo ip rule add from 192.168.1.23/24 table eth0_Pina
# sudo ip rule add from 192.168.0.23/24 table eth0_Loreto
# ---------------------------------------------------------------

# ==================================================
# definisce le seguenti funzioni:
#   lnLogger
#   bringUPInterface
#   bringDOWNInterface
#   setWlan0
#   setWlan1
#   setEth0
thisSCRIPT=$(basename $0)
thisDIR=$(dirname $0)
now=$(date +"%Y/%m/%d %H:%M:%S")
source $thisDIR/LnNetFunctions $thisSCRIPT

# ==================================================



##########################################################
# -
##########################################################
function processInterface {

    lastSTATUS=""

        # verifichiamo che esista l'interfaccia

    if [[ "$interfaceExists" -gt "0" ]]; then      # Se esiste allora vediamo se ha l'indirizzo previsto

        if [[ "$FORCE" == "true" ]]; then
            bringUPInterface
            return
        fi

        # echo .$isUP. .$lastSTATUS.
        if [[ "$isUP" -eq 0 ]]; then                   # Se non e' attiva allora tentiamo di attivarla.
            if [[ "$lastSTATUS" != "$isUP" ]]; then
                bringDOWNInterface

                sleep 3

                bringUPInterface
            fi
        fi

    fi
}


##########################################################
# -  M A I N
##########################################################

    nowMin=$(date +"%M")
    FORCE=$1
    [[ $((nowMin%5)) == 0 ]] && FORCE=true          # ogni 10 minuti
    FORCE=true

    setWlan1;[[ "$?" -eq "0" ]] && processInterface
    # setWlan0;[[ "$?" -eq "0" ]] && processInterface
    # setEth0;[[ "$?" -eq "0" ]] && processInterface

exit 0

