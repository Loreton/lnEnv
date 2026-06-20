# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 05-12-2022 17.30.36
# ------------------------------------

[Unit]
Description=telegrambot used to capture data from telegram groups for tasmota and shelly devices
After=multi-user.target


[Service]
Type=simple
User=%i
# per gestire i child
KillMode=process

Environment="ln_SECRET_DIR=/home/loreto/lnprofile/envars"
Environment="ln_RUNTIME_DIR=/home/loreto/ln_runtime"


# StandardOutput=append:/tmp/lncasettabot/stdout.log"
# StandardError=append:/tmp/lncasettabot/stderr.log"



# ExecStart=/bin/bash /home/loreto/lnprofile/systemd/scripts/lncasettabot-service.sh --systemd_start
ExecStart=/usr/bin/python /home/loreto/lnprofile/liveProduction/telegramBot.zip \
                            --console-logger-level info \
                            --file-logger-level warning \
                            --logging-dir /tmp/lnbot \
                            --pid-file /tmp/lnbot/lnbot.pid \
                            --broker-name LnMqtt \
                            --telegram-group-name LnBot_Client \
                            --systemd



# Restart=always
Restart=always
RestartSec=60


[Install]
WantedBy=multi-user.target

