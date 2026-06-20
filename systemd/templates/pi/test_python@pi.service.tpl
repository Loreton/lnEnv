# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-05-2024 08.06.13
# ------------------------------------

[Unit]
Description=test python venv
After=multi-user.target


[Service]
Type=simple
User=%i
KillMode=process


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

