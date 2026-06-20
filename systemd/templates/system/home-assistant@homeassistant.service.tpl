# https://community.home-assistant.io/t/autostart-using-systemd/199497
# If you’ve setup Home Assistant in virtualenv following our manual installation guide for Raspberry Pi 1.1k (or the Python # installation guide 520), the following template should work for you. If Home Assistant install is not located at /srv/# homeassistant, please modify the ExecStart= line appropriately. YOUR_USER should be replaced by the user account that # Home # Assistant will run as (e.g homeassistant).
# The file will be called /etc/systemd/system/home-assistant@YOUR_USER.service

[Unit]
Description=Home Assistant
After=network-online.target
# After=network.target mosquitto.service


[Service]
Type=simple
User=%i
WorkingDirectory=/home/%i/.homeassistant
ExecStart=/srv/homeassistant/bin/hass -c "/home/%i/.homeassistant"
RestartForceExitStatus=100
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target