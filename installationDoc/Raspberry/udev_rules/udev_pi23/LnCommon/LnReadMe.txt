
# Configura le interfacce se manual o DHCP
/etc/network/interfaces

# imposta il nome della wlanx in base al MAC della scheda
/etc/udev/rules.d/70-ln-network.rules

# funzioni personali per semplificare comandi di configurazione di rete.
/home/pi/Loreto/etc/LnCommon/LnNetFunctions

# opera per la corretta attivazione dell'interfaccia e...
# ... fa uso del file: /home/pi/Loreto/etc/LnCommon/LnNetFunctions
/etc/network/if-up.d/rtTable_mptcp_up




Comandi utili di rete:

# https://wireless.wiki.kernel.org/en/users/documentation/iw
sudo apt-get install iw

iw list
iw dev wlan0 link
iw wlan1 connect Telecom-22394331

wpa_cli status
    Selected interface 'wlan1'
    bssid=c4:ea:1d:41:77:db
    ssid=Telecom-22394331
    id=0
    id_str=Pina
    mode=station
    pairwise_cipher=CCMP
    group_cipher=TKIP
    key_mgmt=WPA2-PSK
    wpa_state=COMPLETED
    ip_address=192.168.1.123
    address=e8:de:27:09:1b:48


wpa_cli scan && sleep 10 && wpa_cli scan_results
    Selected interface 'wlan1'
    OK
    Selected interface 'wlan1'
    bssid / frequency / signal level / flags / ssid
    c4:ea:1d:41:77:db       2412    -63     [WPA-PSK-TKIP][WPA2-PSK-CCMP][WPS][ESS] Telecom-22394331
    62:b0:5d:60:20:8b       2447    -59     [WPA2-PSK-CCMP][ESS]    NG-Guest
    2c:b0:5d:60:20:8a       2447    -62     [WPA2-PSK-CCMP][WPS][ESS]       NG-Ln
    a4:99:47:4a:09:58       2462    -69     [WPA-PSK-TKIP+CCMP][WPA2-PSK-TKIP+CCMP][WPS][ESS]       InfostradaWiFi-812786
    00:1c:a2:ed:78:75       2412    -74     [WPA-PSK-TKIP][ESS]     Alice-88972046
    e0:91:f5:fb:29:f4       2437    -82     [WPA2-PSK-CCMP][WPS][ESS]       Telecom-64048834
    e8:74:e6:2d:2b:a2       2412    -90     [WPA-PSK-TKIP+CCMP][WPA2-PSK-TKIP+CCMP][ESS]    FASTWEB-1-1hFR13pilb04
