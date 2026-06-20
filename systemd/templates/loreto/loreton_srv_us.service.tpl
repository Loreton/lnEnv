# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 04-10-2022 16.15.38
# ------------------------------------

[Service]
# ExecStart=ssh srv.us -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=5 -T -R 1:localhost:3000 -R 2:192.168.0.1:80
# ExecStart=ssh loreton.gh.srv.us -i /home/loreto/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=5 -T -R 1:localhost:5000
ExecStart=ssh loreton.gh.srv.us -i /home/loreto/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=5 -T -R 1:localhost:8443
User=loreto
Restart=on-failure
RestartSec=1s

[Unit]
After=network.target

[Install]
WantedBy=multi-user.target
