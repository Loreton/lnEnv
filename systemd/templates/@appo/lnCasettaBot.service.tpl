; ------------------------------------

[Unit]
Description=telegrambot used to capture data from telegram groups for tasmota and shelly devices
After=multi-user.target


[Service]
Type=simple
User=pi
# per gestire i child
# KillMode=process

ExecStart=${HOME}/lnprofile/systemd/scripts/lnCasettaBot.sh systemd_start --prod
ExecStop=${HOME}/lnprofile/systemd/scripts/lnCasettaBot.sh systemd_stop --prod

Restart=always
# Restart=on-failure
RestartSec=60


[Install]
WantedBy=multi-user.target

