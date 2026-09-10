#!/bin/bash
FILE="$1"

if [ -z "$FILE" ]; then
    exit 1
fi

# Controlla se il proprietario ha i permessi di scrittura (w)
if [ -w "$FILE" ]; then
    # Rimuove il permesso di scrittura per tutti (Read-Only)
    chmod a-w "$FILE"
else
    # Aggiunge il permesso di scrittura per il proprietario (Read-Write)
    chmod u+w "$FILE"
fi
