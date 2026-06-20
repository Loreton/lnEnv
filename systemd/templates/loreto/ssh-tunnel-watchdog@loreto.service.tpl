# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 09-04-2026 18.13.11
# ------------------------------------

[Unit]
Description=SSH Reverse Tunnel Watchdog
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/ssh-watchdog/ssh_watchdog.py
WorkingDirectory=/opt/ssh-watchdog
Restart=always
RestartSec=5
User=tuo_utente

# importante per logging immediato
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target

##############################################
# Attivazione:
# 	sudo systemctl daemon-reexec
# 	sudo systemctl daemon-reload
# 	sudo systemctl enable ssh-tunnel-watchdog
# 	sudo systemctl start ssh-tunnel-watchdog
##############################################