#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-10-2026 16.26.36
#


#!/bin/bash

# Riceve la directory da Double Commander come primo argomento
TARGET_DIR="$1"

# Se non viene passata una directory, usa quella corrente
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="."
fi

echo "=== Avvio conversione in: $TARGET_DIR ==="
echo ""

# Conta i file trovati per un feedback iniziale
COUNT=$(find "$TARGET_DIR" -maxdepth 1 -type f -iname "*.epub" | wc -l)
echo "Trovati $COUNT file .epub da convertire."
echo "----------------------------------------"

# Trova ed esegue la conversione per ogni file epub
find "$TARGET_DIR" -maxdepth 1 -type f -iname "*.epub" -exec sh -c '
    for file do
        # Genera il nome del file di output (stessa posizione, estensione .txt)
        output="${file%.epub}.txt"
        echo "Conversione: $(basename "$file") -> $(basename "$output")"

        # Esegue la conversione (usando il comando flatpak che funziona per te)
        /usr/bin/flatpak run --command=ebook-convert com.calibre_ebook.calibre "$file" "$output"

        if [ $? -eq 0 ]; then
            echo "  -> Completato."
        else
            echo "  -> ERRORE durante la conversione."
        fi
        echo ""
    done
' sh {} +

echo "----------------------------------------"
echo "=== Conversione terminata ==="
