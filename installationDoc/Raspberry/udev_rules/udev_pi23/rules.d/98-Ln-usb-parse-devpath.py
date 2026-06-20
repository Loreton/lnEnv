#!/usr/bin/env python
import sys


parm3='/devices/platform/soc/3f980000.usb/usb1/1-1/1-1.5/1-1.5.3/1-1.5.3:1.0/ttyUSB1/tty/ttyUSB1'

# sudo udevadm control --reload-rules
# sudo udevadm trigger

def processLine(line, fDEBUG=False):
    token = line.split('/')
    arduinoKernels = {
                # Arduino con hub usb da 9 porte
                '1-1.5.1':   "arduino10",
                '1-1.5.2':   "arduino12",
                '1-1.5.3':   "arduino11",
                '1-1.5.4.1': "rs485_01",
                '1-1.5.4.2': "rs485_02",
                '1-1.5.4.3': "rs485_03",
                }


    for kernel, linkName in arduinoKernels.items():
        if kernel in token:
            # print (linkName)
            return linkName

    return None


if __name__ == "__main__":
    if len(sys.argv) > 1:
        line = sys.argv[1]
        retVal = processLine(line)

    if retVal:
        print (retVal)

