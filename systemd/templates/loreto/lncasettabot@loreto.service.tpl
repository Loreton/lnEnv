# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 21-05-2024 09.34.32
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
                            --console-logger-level error \
                            --file-logger-level warning \
                            --logging-dir /tmp/lncasettabot \
                            --broker-name LnMqtt \
                            --project-env mqtt \
                            --telegram-group-name LnCasettaBot_Client \
                            --systemd

# Restart=always
Restart=always
RestartSec=60


[Install]
WantedBy=multi-user.target

