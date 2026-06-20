# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-07-2024 18.22.01
# ------------------------------------

[Unit]
Description=telegrambot used to capture data from telegram groups for tasmota and shelly devices
After=multi-user.target


[Service]
Type=simple
User=%i
# per gestire i child
KillMode=process

Environment="ln_SECRET_DIR=/home/pi/lnprofile/envars"
Environment="ln_RUNTIME_DIR=/home/pi/ln_runtime"
# Environment="ln_PROFILE_DIR=/home/pi/lnprofile"
# Environment="ln_SET_LORETO_ENVIRONMENT=/home/pi/lnprofile/init/setLoretoEnvironment"

# StandardOutput=append:/tmp/lncasettabot/stdout.log"
# StandardError=append:/tmp/lncasettabot/stderr.log"

ExecStart=/home/pi/.lnVenv/telegrambot311/bin/python3.11  /home/pi/lnprofile/liveProduction/telegramBot.zip \
                            --console-logger-level error \
                            --file-logger-level warning \
                            --logging-dir /tmp/lncasettabot \
                            --broker-name LnMqtt \
                            --db-version-dir D20240626 \
                            --telegram-group-name LnCasettaBot_Client \
                            --systemd



# Restart=always
Restart=always
RestartSec=60


[Install]
WantedBy=multi-user.target

