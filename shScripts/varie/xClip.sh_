#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 17-12-2025 08.43.31
#
# Funzione per eseguire editor (nano in questo esempio) sulla stringa selezionata
# Assicurati che 'xclip' sia installato
editor_sel() {
    FILE_PATH=$(xclip -o -selection primary)
    if [ -n "$FILE_PATH" ]; then
        echo "$FILE_PATH"
    else
        echo "Nessuna stringa negli appunti di selezione (primary)."
    fi
}

editor_sel

