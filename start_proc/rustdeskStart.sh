#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 21-11-2025 13.00.18
#


myApplicationLog='/tmp/rustdesk_start.log'

DATE=$(date +'%d-%m-%Y %H:%M:%S')

set -u
echo -e "\n\n--- $DATE - start" >>"$myApplicationLog" 2>&1

# verifica che flatpak sia presente
if ! command -v flatpak >/dev/null 2>&1; then
  echo "flatpak non trovato nel PATH" >>"$myApplicationLog" 2>&1
  exit 1
fi

# definisco il comando come array (corretto per argomenti con spazi)
myApplication=(flatpak run com.rustdesk.RustDesk)

echo -e "launching: [${myApplication[*]}]" >>"$myApplicationLog" 2>&1

# eseguo il comando passando eventuali argomenti ($@) e redirect di stdout/stderr su logfile
"${myApplication[@]}" "$@" >>"$myApplicationLog" 2>&1 &

pid=$!
echo -e "Lanciato PID ${pid}\n" >>"$myApplicationLog" 2>&1
echo -e "\n\n--- program output --------\n" >>"$myApplicationLog" 2>&1