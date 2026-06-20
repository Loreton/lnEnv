# ------------------------------------
# updated by ...: Loreto Notarantonio
# Date .........: 14-05-2024 08.06.13
# ------------------------------------
#!/usr/bin/env python3

ref:
https://serverfault.com/questions/1052218/executing-a-command-before-starting-a-systemd-service
https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html (search for drop-in per vedere come aggiungere xxfilees.conf al systemd service)


come usare le variabili
https://dailystuff.nl/blog/2019/environment-variables-set-by-systemd

import os

if os.environ.get('VAR1'):
    var1 = os.environ['VAR1']
else:
    var1 = 'default'

print(var1)