#!/bin/bash
scriptFPath="$(readlink -f ${BASH_SOURCE[0]})"       # OTTIMA
scriptFPath="$(basename  ${BASH_SOURCE[0]})"       # mi interessa il nome del logical_link
scriptName="$(basename $scriptFPath .sh)" # remove extension
scriptName="$(basename $scriptName .lnk)" # remove extension

listFiles='/tmp/tarFile.conf'
echo >$listFiles
LISTA='
        /etc/network/
        /etc/dnsmasq*
        /etc/ssh/
        /etc/udev/
        /etc/wpa_supplicant/
        /etc/iproute2/
        /etc/default/
        /etc/minidlna.conf
        /etc/dhcpcd.conf
        /etc/fstab
        /etc/hostname
        /home/pi/.ssh
        /home/pi/.vimrc
        /home/pi/.bashrc
        /home/pi/.aMule
     '


EXCLUDE='--exclude=/home/pi/.aMule/copied/* --exclude=/home/pi/.aMule/Incoming/* --exclude=/home/pi/.aMule/Temp/*'
for file in $LISTA; do
    if [ -e $file ]; then
        echo $file >>$listFiles
    else
        echo "skipping $file"
    fi
done
cat $listFiles

DATE=$(date +'%Y-%m-%d')
hostname=$(hostname -s)
tarFile="${HOME}/${hostname}_${DATE}.tgz"
echo
echo "creating file: $tarFile"
echo
# Make sure to put --exclude before the source and destination items.
# sudo tar --exclude='/home/pi/PiProd/.git' -czf $tarFile --absolute-names --files-from=$listFiles
sudo tar --absolute-names $EXCLUDE -czvf $tarFile  --files-from=$listFiles
sudo chown pi:pi $tarFile
tar -tzvf $tarFile
echo
echo "$tarFile has been created"
echo