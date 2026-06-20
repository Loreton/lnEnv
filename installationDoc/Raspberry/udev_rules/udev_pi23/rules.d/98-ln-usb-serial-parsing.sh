#!/bin/bash
# udevadm info --attribute-walk -n /dev/ttyUSB0
# parm="/devices/platform/bcm2708_usb/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/ttyUSB0/tty/ttyUSB0"
# parm="/devices/platform/soc/3f980000.usb/usb1/1-1/1-1.5/1-1.5.2/1-1.5.2:1.0/ttyUSB0/tty/ttyUSB0"
# DEVNUM_STRIPPED=113210
# PORTNUM=0
# PRODUCT=USB2.0-Serial
# udevadm info --attribute-walk -n /dev/ttyUSB1
# parm="/devices/platform/bcm2708_usb/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/ttyUSB1/tty/ttyUSB1"
# DEVNUM_STRIPPED=113410
# PORTNUM=0
# PRODUCT=USB2.0-Serial
# ----------
# vedi /home/pi/GIT-REPO/Scripts/shellScripts/99-ln-usb-serial-parsing_TEST.sh
# ----------
# exit
line=$1
    # - get 1-1.5.2
DEVNUM=$(echo "${line}" | rev | cut -d'/' -f5 | rev)
echo "$DEVNUM $line" >>/tmp/a


    [[ "${DEVNUM}" == "1-1.5.4.3" ]]   && NEWID="Pi_RS485_03"      && echo "$NEWID" && exit
    [[ "${DEVNUM}" == "1-1.5.4.2" ]]   && NEWID="Pi_RS485_02"      && echo "$NEWID" && exit
    [[ "${DEVNUM}" == "1-1.5.4.1" ]]   && NEWID="Pi_RS485_01"      && echo "$NEWID" && exit
    [[ "${DEVNUM}" == "1-1.5.9" ]]     && NEWID="arduino_Slave02"  && echo "$NEWID" && exit
    [[ "${DEVNUM}" == "1-1.5.2" ]]     && NEWID="arduino_Slave01"  && echo "$NEWID" && exit


# Se non è nessuno di quelli sopra ignoriamo
exit
