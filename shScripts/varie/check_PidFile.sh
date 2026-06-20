#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 17-11-2022 10.43.27
#

# cd ~/lnprofile/liveProduction
# ln -s ~/lnprofile/sh_scripts/varie/check_PidFile.sh check_PidFile.lnk

#############################################
# M A I N
#############################################
filename=$1 # name of file containing pid number
kill_elapsed="${2:-60}" # elapsed threschold after kill command will be executed
restart_command="${3:-}" # command to restart process


DATE=$(date +'%Y-%m-%d %H:%M:%S')
now_epoch_time=$(date -d "${DATE}" +"%s")

# filename='/tmp/mqttmonitor/mqttmonitor.pid'
if [[ -f ${filename} ]]; then
    pid=$(<$filename)
    file_timestamp=$(stat -c %y $filename)
    file_epoch_time=$(date -d "${file_timestamp}" +"%s")
    elapsed_secs=$((${now_epoch_time} - ${file_epoch_time}))
    echo "  filename:         ${filename}"
    echo "  kill_elapsed:     ${kill_elapsed}"
    echo "  pid:              ${pid}"
    echo "  now:              ${DATE}"
    echo "  file timestamp:   ${file_timestamp}"
    echo "  esapsed (secs):   ${elapsed_secs}"
else
    echo "File $filename NOT exists"
    exit 1
fi


if [[ ${elapsed_secs} -gt $kill_elapsed ]]; then
    echo "killing $pid"
    echo $restart_command
else
    echo "nothing to do"
fi

