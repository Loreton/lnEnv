#!/bin/bash
# udevadm info --attribute-walk -n /dev/ttyUSB0
# parm="/devices/platform/bcm2708_usb/usb1/1-1/1-1.3/1-1.3.2/1-1.3.2:1.0/ttyUSB0/tty/ttyUSB0"
# DEVNUM_STRIPPED=113210
# PORTNUM=0
# PRODUCT=USB2.0-Serial
# udevadm info --attribute-walk -n /dev/ttyUSB1
# parm="/devices/platform/bcm2708_usb/usb1/1-1/1-1.3/1-1.3.4/1-1.3.4:1.0/ttyUSB1/tty/ttyUSB1"
# DEVNUM_STRIPPED=113410
# PORTNUM=0
# PRODUCT=USB2.0-Serial

line=$1
DEVNUM=$(echo "${line}" | rev | cut -d'/' -f4 | rev)
DEVNUM_STRIPPED=$(echo "${line}" | rev | cut -d'/' -f4 | rev | tr -d '-' | tr -d '.' | tr -d ':')
PORTNUM=$(/sbin/udevadm info -a --path=${line} | grep "ATTRS{port_number}" | head -1 | cut -d'"' -f2)
PRODUCT=$(/sbin/udevadm info -a --path=${line} | grep "ATTRS{product}" | head -1 | cut -d'"' -f2 | tr -d '/' | tr ' ' '_')
echo "PRODUCT:      $PRODUCT"
echo "PORTNUM:      $PORTNUM"

USBnum="${line: -1}"
# echo $DEVNUM_STRIPPED
# echo $DEVNUM


NEWID="TTYUSBs/ttyUSB_${PRODUCT}${PORTNUM}_${DEVNUM_STRIPPED}"
# Arduino con hub usb da 7 porte
    # [[ "${DEVNUM_STRIPPED}" == "....1133410" ]] && NEWID="arduino${USBnum}"
    # [[ "${DEVNUM_STRIPPED}" == "....1133310" ]] && NEWID="arduino${USBnum}"
    # [[ "${DEVNUM_STRIPPED}" == "1133410" ]] && NEWID="arduinoMaster"
    # [[ "${DEVNUM_STRIPPED}" == "1133310" ]] && NEWID="arduinoSlave01"
# Arduino con hub usb da 10 porte
    # [[ "${DEVNUM_STRIPPED}" == "....1134410" ]] && NEWID="arduino${USBnum}"
    # [[ "${DEVNUM_STRIPPED}" == "....113710" ]] && NEWID="arduino${USBnum}"
    # [[ "${DEVNUM_STRIPPED}" == "1134410" ]] && NEWID="arduinoMaster"
    # [[ "${DEVNUM_STRIPPED}" == "113710" ]] && NEWID="arduinoSlave01"
    # [[ "${DEVNUM}"          == "1-1.3.4.3:1.0" ]] && NEWID="arduinoMaster"
    # [[ "${DEVNUM}"          == "1-1.3.4.4:1.0" ]] && NEWID="arduinoSlave01"

    [[ "${DEVNUM}"          == "1-1.3.4.4:1.0" ]] && NEWID="arduinoRS485_Master"
    [[ "${DEVNUM}"          == "1-1.3.4.3:1.0" ]] && NEWID="arduinoRS485_Slave01"
    [[ "${DEVNUM}"          == "1-1.3.7:1.0" ]]   && NEWID="arduinoWiFi_Slave01"



# [[ "${NEWID}" == "ttyUSB_USB2.0-Serial_11334100" ]] && NEWID="${NEWID}-Arduino"
# [[ "${NEWID}" == "ttyUSB_USB2.0-Serial_11333100" ]] && NEWID="${NEWID}-Arduino"

# echo "${line}" >>/tmp/DEBUG_udev.txt
# echo "${NEWID} :: $1" >> /tmp/DEBUG_udev.txt

echo "$NEWID"