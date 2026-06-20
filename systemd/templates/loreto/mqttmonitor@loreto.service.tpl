# ------------------------------------
# updated by ...: pi Notarantonio
# Date .........: 29-11-2022 20.29.29
# ------------------------------------

[Unit]
Description=MqttMonitor used to capture data from mqtt_broker for tasmota and shelly devices
After=multi-user.target


[Service]
Type=simple
# User=%i
User=loreto
# EnvironmentFile=/etc/sysconfig/customsyslog
# ExecStartPre=/bin/mkdir -m 740 -p /home/%i/ln_runtime
# per gestire i child
KillMode=process

Environment="ln_SECRET_DIR=/home/loreto/lnprofile/envars"
Environment="ln_RUNTIME_DIR=/home/loreto/ln_runtime"
# Environment="ln_SET_LORETO_ENVIRONMENT=/home/loreto/lnprofile/init/setLoretoEnvironment"
# ExecStart=/bin/bash /home/pi/lnprofile/systemd/scripts/mqttmonitor-service.sh --systemd_start --go


# ExecStart="/home/loreto/.lnVenv/mqttmonitor312/bin/python3.12" /home/loreto/lnprofile/liveProduction/mqttMonitor.zip \
ExecStart="/home/loreto/.lnVenv/mqttmonitor312/bin/python3.12" /tmp/compiled/mqttMonitor.zip \
                        --console-logger-level info \
                        --file-logger-level debug \
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

