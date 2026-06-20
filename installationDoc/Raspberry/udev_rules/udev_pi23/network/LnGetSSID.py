#!/usr/bin/env python3
# -*- coding: iso-8859-1 -*-

import sys

import subprocess


if len(sys.argv) < 2:
    print('immettere il nome della wlan')
    sys.exit()

WLAN = sys.argv[1]
# scanoutput = check_output(["iwlist", "wlan1", "scan"])
scanoutput = subprocess.check_output(["sudo", "iwlist", WLAN, "scan"], stderr=subprocess.STDOUT)  # ritorna <class 'bytes'>
scanoutput = scanoutput.decode('utf-8')       # converti in STRing
# print(scanoutput)

ssid = "WiFi not found"

Address = ''
print ("ESSID: {0:<30} {1:<40} {2}".format('ESSID', 'Address', 'Freq'))
for line in scanoutput.split('\n'):

    if "Address:" in line:
        if Address:
            print ("ESSID: {0:<30} {1:<40} {2}".format(ESSID, Address, Freq))
            Address = ''
            ESSID = ''
            Freq = ''

        Address = line.strip().split("Address:")[1]
    elif "ESSID:" in line:
        ESSID = line.strip().split("ESSID:")[1]
    elif "Frequency:" in line:
        Freq = line.strip().split("Frequency:")[1]

    # print (line)


# dev <devname> connect [-w] <SSID> [<freq in MHz>] [<bssid>] [key 0:abcde d:1:6162636465]
#         Join the network with the given SSID (and frequency, BSSID).
#         With -w, wait for the connect to finish or fail.


# sudo iw dev wlan0 connect <ESSID> <Frequency> <BSSID>
# sudo iw dev wlan0 connect <ESSID> <Frequency> <BSSID>

# sudo iw dev wlan1 connect "Infostrada-8F9F21"
'''

    Cell 07 - Address: 5C:E2:8C:8F:9F:21 2.452
            Channel:9
            Frequency:2.452 GHz (Channel 9)
            Quality=65/70  Signal level=-45 dBm
            Encryption key:on
            ESSID:"Infostrada-8F9F21"
            Bit Rates:1 Mb/s; 2 Mb/s; 5.5 Mb/s; 11 Mb/s; 18 Mb/s
                      24 Mb/s; 36 Mb/s; 54 Mb/s
            Bit Rates:6 Mb/s; 9 Mb/s; 12 Mb/s; 48 Mb/s
            Mode:Master
            Extra:tsf=000000082f5d27f1
            Extra: Last beacon: 560ms ago
            IE: Unknown: 0011496E666F7374726164612D384639463231
            IE: Unknown: 010882848B962430486C
            IE: Unknown: 030109
            IE: Unknown: 2A0100
            IE: Unknown: 32040C121860
            IE: IEEE 802.11i/WPA2 Version 1
                Group Cipher : TKIP
                Pairwise Ciphers (2) : CCMP TKIP
                Authentication Suites (1) : PSK
            IE: Unknown: 0B0500000C0000
            IE: Unknown: 42020000
            IE: Unknown: 2D1ABC081BFFFF000000000000000000000000000000000000000000
            IE: Unknown: 3D1609080000000000000000000000000000000000000000
            IE: Unknown: 7F080400080000000040
            IE: Unknown: DD9F0050F204104A0001101044000102103B00010310470010DAFD91D5BB88C2ED67C2D1F0CB0AAF00102100055A7958454C1023000C564D47383832332D423530421024000C564D47383832332D423530421042000D533138325630333030363636371054000800060050F204000110110019564D47383832332D42353042205A7958454C415020322E344710080002200C103C0001031049000600372A000120
            IE: Unknown: DD090010180200001C0000
            IE: WPA Version 1
                Group Cipher : TKIP
                Pairwise Ciphers (2) : CCMP TKIP
                Authentication Suites (1) : PSK
            IE: Unknown: DD180050F2020101840003A4000027A4000042435E0062322F00



    Cell 08 - Address: C0:4A:00:BC:03:CC
            Channel:13
            Frequency:2.472 GHz (Channel 13)
            Quality=62/70  Signal level=-48 dBm
            Encryption key:on
            ESSID:"Ln.Adsl"
            Bit Rates:1 Mb/s; 2 Mb/s; 5.5 Mb/s; 11 Mb/s; 6 Mb/s
                      9 Mb/s; 12 Mb/s; 18 Mb/s
            Bit Rates:24 Mb/s; 36 Mb/s; 48 Mb/s; 54 Mb/s
            Mode:Master
            Extra:tsf=000002f20e6530bd
            Extra: Last beacon: 50ms ago
            IE: Unknown: 00074C6E2E4164736C
            IE: Unknown: 010882848B960C121824
            IE: Unknown: 03010D
            IE: Unknown: 0706495420010D14
            IE: Unknown: 2A0100
            IE: IEEE 802.11i/WPA2 Version 1
                Group Cipher : CCMP
                Pairwise Ciphers (1) : CCMP
                Authentication Suites (1) : PSK
            IE: Unknown: 32043048606C
            IE: Unknown: 2D1A2C0103FF00000000000000000000000000000000000000000000
            IE: Unknown: 3D160D080400000000000000000000000000000000000000
            IE: Unknown: DD180050F2020101820003A4000027A4000042435E0062322F00
            IE: Unknown: DD1E00904C332C0103FF00000000000000000000000000000000000000000000
            IE: Unknown: DD1A00904C340D080400000000000000000000000000000000000000
            IE: Unknown: DD0900037F01010000FF7F
            IE: Unknown: DD800050F204104A0001101044000102103B0001031047001000000000000010000000C04A00BC03101021000754502D4C494E4B10230009544C2D4D523332323010240003322E3010420003312E301054000800060050F204000110110000100800020086103C000101104900140024E26002000101600000020001600100020001
'''