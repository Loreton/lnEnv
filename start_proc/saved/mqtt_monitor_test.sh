#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 19-03-2023 19.07.44
#


function TEST_direct() {
    device_name=$1
    commands=$2
    for command in ${commands}; do
        mosquitto_pub -d -u Loreto -P LoretoMqtt -h 192.168.1.22 -t cmnd/${device_name}/backlog -m ${command}
        sleep 2
    done
}


function TEST_telegram() {
    device_name=$1
    commands=$2
    for command in ${commands}; do
        mosquitto_pub -d -u Loreto -P LoretoMqtt -h 192.168.1.22 -t LnTelegram/${device_name}/alias -m "{ \
                                                                                    \"command\": null, \
                                                                                    \"payload\": null, \
                                                                                    \"debug\": false, \
                                                                                    \"host\": \"LnPi31\", \
                                                                                    \"bot_name\": \"LnCasettaBot\", \
                                                                                    \"alias\": \"${command}\" \
                                                                                    }"


        sleep 2
    done
}



TEST_telegram "FaroLetto" "firmware ipaddress mqtt net_status power poweronstate pulsetime ssid summary status timers version"
