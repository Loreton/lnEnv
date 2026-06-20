# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-05-2024 08.06.13
# ------------------------------------

[Unit]
Description=telegrambot used to capture data from telegram groups for tasmota and shelly devices
After=multi-user.target


[Service]
Type=simple
User=%i
# per gestire i child
KillMode=process

# Environment="ln_SECRET_DIR=/home/pi/lnprofile/envars"
# Environment="ln_RUNTIME_DIR=/home/pi/ln_runtime"
# Environment="ln_SET_LORETO_ENVIRONMENT=/home/pi/lnprofile/init/setLoretoEnvironment"

# StandardOutput=append:/tmp/lncasettabot/stdout.log"
# StandardError=append:/tmp/lncasettabot/stderr.log"

ExecStart=/usr/bin/python /home/pi/lnprofile/liveProduction/telegramBot.zip \
                            --console-logger-level error \
                            --file-logger-level warning \
                            --logging-dir /tmp/lnbevebot \
                            --broker-name LnMqtt \
                            --telegram-group-name LnBeveBot_Client \
                            --systemd



# Restart=always
Restart=always
RestartSec=60


[Install]
WantedBy=multi-user.target

