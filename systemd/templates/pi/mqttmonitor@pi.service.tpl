# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-07-2024 18.23.22
# ------------------------------------

[Unit]
Description=MqttMonitor used to capture data from mqtt_broker for tasmota and shelly devices
After=multi-user.target


[Service]
Type=simple
# User=%i
User=pi
# EnvironmentFile=/etc/sysconfig/customsyslog
# ExecStartPre=/bin/mkdir -m 740 -p /home/%i/ln_runtime
# per gestire i child
KillMode=process

Environment="ln_SECRET_DIR=/home/pi/lnprofile/envars"
Environment="ln_RUNTIME_DIR=/home/pi/ln_runtime"
# Environment="ln_SET_LORETO_ENVIRONMENT=/home/pi/lnprofile/init/setLoretoEnvironment"
# ExecStart=/bin/bash /home/pi/lnprofile/systemd/scripts/mqttmonitor-service.sh --systemd_start --go


ExecStart=/home/pi/.lnVenv/mqttmonitor312/bin/python3.12 /home/pi/lnprofile/liveProduction/mqttMonitor.zip \
                        --console-logger-level error \
                        --file-logger-level warning \
                        --logging-dir /tmp/mqttmonitor \
                        --broker-name LnMqtt \
                        --db-version-dir D20240626 \
                        --telegram-group-name Ln_MqttMonitor_Client \
                        --topics +/# \
                        --systemd




# Restart=always
Restart=always
RestartSec=60


[Install]
WantedBy=multi-user.target

