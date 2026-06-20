#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 21-10-2022 08.39.35
#
#



create_private_key:
    cd /etc/lighttpd/cert
    cd /etc/nginx/cert

    name='lighttpd'
    name='loreto.domain'
    SUBJECT="/C=IT/ST=Italy/L=Rome/O=LoretoNet/OU=root/CN=loreto.domain/emailAddress=loreto.n@gmil.com"
    sudo openssl req -x509 -newkey rsa:2048 -nodes -days 365 -keyout $name.key -out $name.crt -subj $SUBJECT


    CA:
    sudo openssl req -new  -newkey rsa:2048 -nodes -days 365 -keyout $name.key -out $name.csr
    cert:
    sudo openssl x509 -req -days 365 -in $name.csr -signkey $name.key -out $name.crt

    combine the certificates with key:
    sudo cat $name.key $name.crt > $name.pem
    se da errore:
        sudo cat $name.key $name.crt > /tmp/$name.pem
        sudo cp /tmp/$name.pem .


