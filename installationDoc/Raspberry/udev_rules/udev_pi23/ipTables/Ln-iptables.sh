#!/bin/bash

# nohup sudo bash /home/pi/Loreto/conf/Ln-iptables.sh

currTime=$(date +"%Y%m%d_%H%M%S")
SLEEP_TIME=10


savedFName=/home/pi/Loreto/conf/iptables_${currTime}
newFName=/home/pi/Loreto/conf/Ln-iptables.txt
# save current

echo "saving current to ${savedFName}"
iptables-save > ${savedFName}; rCode=$?; echo $rCode; [[ ! "$rCode" == "0" ]] && echo "ERROR" && exit

echo "flashing current"
iptables -F

echo "loading ${newFName}"
iptables-restore < ${newFName}; rCode=$?; echo $rCode; [[ ! "$rCode" == "0" ]] && echo "ERROR" && exit
iptables -L

echo "sleeping for $SLEEP_TIME. At the end the previuos iptable will be restored."
sleep $SLEEP_TIME
echo "restorung saved iptable."
iptables-restore < ${savedFName}; rCode=$?; echo $rCode; [[ ! "$rCode" == "0" ]] && echo "ERROR" && exit

# Per renderla definitiva
# iptables-save
