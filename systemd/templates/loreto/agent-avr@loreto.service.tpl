# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 24-08-2022 08.10.24
# ------------------------------------

[Unit]
Description=AgentDVR

[Service]
# see https://www.ispyconnect.com/userguide-agent-service.aspx for instructions
# systemd will run this executable to start the service. AGENT_LOCATION needs to be the absolute path
# DOT_NET_LOCATION should point to where the dotnet executable is - this might be different on your computer.
# For Raspberry Pi YOUR_USERNAME is usually pi
#
# eg for Raspberry Pi:  ExecStart=/usr/share/dotnet/dotnet /home/pi/Desktop/Agent/Agent.dll
# eg for Linux:         ExecStart=/usr/bin/dotnet /home/sean/Desktop/Agent/Agent.dll

ExecStart=DOT_NET_LOCATION AGENT_LOCATION/Agent.dll

# to query logs using journalctl, set a logical name here
SyslogIdentifier=AgentDVR

# Use your username to keep things simple.
# If you pick a different user, make sure dotnet and all permissions are set correctly to run the app
# To update permissions, use 'chown YOUR_USERNAME -R AGENT_LOCATION' to take ownership of the folder and files

User=loreto

# ensure the service automatically restarts
Restart=always
# amount of time to wait before restarting the service
RestartSec=5

[Install]
WantedBy=multi-user.target



