# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-07-2024 18.23.56
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
                            --console-logger-level critical \
                            --file-logger-level debug \
                            --logging-dir /tmp/lnbot \
                            --broker-name LnMqtt \
                            --db-version-dir D20240626 \
                            --telegram-group-name LnBot_Client \
                            --systemd



# Restart=always
Restart=always
RestartSec=60


[Install]
WantedBy=multi-user.target

